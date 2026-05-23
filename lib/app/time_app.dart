import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import 'package:deep_time/app/app_debug.dart';
import 'package:deep_time/app/app_dependencies.dart';
import 'package:deep_time/ui/screens/timeline_screen.dart';

class TimeApp extends StatelessWidget {
  const TimeApp({super.key, required this.enablePreferences});

  final bool enablePreferences;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deep Time',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6F74)),
        useMaterial3: true,
      ),
      home: _BootstrapScreen(enablePreferences: enablePreferences),
    );
  }
}

class _BootstrapScreen extends StatefulWidget {
  const _BootstrapScreen({required this.enablePreferences});

  final bool enablePreferences;

  @override
  State<_BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<_BootstrapScreen> {
  static const _minimumSplashDuration = Duration(seconds: 5);
  static const _splashWindowSize = Size(400, 400);
  static const _expandDuration = Duration(milliseconds: 500);
  late final Future<AppDependencies> _dependenciesFuture;
  late final Future<void> _splashDelayFuture;
  bool _windowExpanded = false;
  AppDependencies? _dependencies;
  Object? _loadError;
  bool _ready = false;
  bool _firstFrameCommitted = false;
  int _buildCount = 0;

  @override
  void initState() {
    super.initState();
    _dependenciesFuture = AppDependencies.build();
    _splashDelayFuture = Future<void>.delayed(_minimumSplashDuration);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _firstFrameCommitted = true;
      await _hideWindowWhileSizing();
      await _setSplashWindowSize();
      await _showWindow();
    });
    _prepareApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppDebug.log('Splash: didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant _BootstrapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    AppDebug.log('Splash: didUpdateWidget');
  }

  Future<void> _hideWindowWhileSizing() async {
    try {
      AppDebug.log('Splash: hiding window for sizing');
      await windowManager.hide();
      final isVisible = await windowManager.isVisible();
      final size = await windowManager.getSize();
      AppDebug.log(
        'Splash: hidden? visible=$isVisible size=${size.width}x${size.height}',
      );
    } catch (_) {}
  }

  Future<void> _showWindow() async {
    try {
      AppDebug.log('Splash: showing window after sizing');
      await windowManager.show();
      await windowManager.focus();
      final isVisible = await windowManager.isVisible();
      final size = await windowManager.getSize();
      AppDebug.log(
        'Splash: shown? visible=$isVisible size=${size.width}x${size.height}',
      );
    } catch (_) {}
  }

  Future<void> _prepareApp() async {
    try {
      AppDebug.log('Splash: start loading dependencies');
      final results = await Future.wait<Object?>([
        _dependenciesFuture,
        _splashDelayFuture,
      ]);
      if (!mounted) {
        return;
      }
      AppDebug.log('Splash: dependencies + delay completed');
      _dependencies = results.first as AppDependencies;
      await _expandWindow();
      if (!mounted) {
        return;
      }
      setState(() {
        AppDebug.log('Splash: ready -> showing main screen');
        _ready = true;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppDebug.log('Splash: error while preparing app', error: error);
      setState(() {
        _loadError = error;
      });
    }
  }

  Future<void> _setSplashWindowSize() async {
    if (!_firstFrameCommitted) {
      return;
    }
    try {
      AppDebug.log('Splash: set window size to 400x400');
      await windowManager.setMinimumSize(_splashWindowSize);
      await windowManager.setMaximumSize(_splashWindowSize);
      await windowManager.setSize(_splashWindowSize);
      await windowManager.center();
      final size = await windowManager.getSize();
      AppDebug.log('Splash: size after set ${size.width}x${size.height}');
    } catch (_) {}
  }

  Future<void> _expandWindow() async {
    if (_windowExpanded) {
      return;
    }
    _windowExpanded = true;
    try {
      AppDebug.log('Splash: expanding window for main screen');
      await windowManager.setMinimumSize(const Size(300, 300));
      await windowManager.setMaximumSize(const Size(10000, 10000));
      final startSize = await windowManager.getSize();
      final display = await screenRetriever.getPrimaryDisplay();
      final targetSize = display.visibleSize ?? display.size;
      await _animateResize(startSize, targetSize, _expandDuration);
      await windowManager.center();
      final size = await windowManager.getSize();
      AppDebug.log('Splash: size after expand ${size.width}x${size.height}');
    } catch (_) {}
  }

  Future<void> _animateResize(Size from, Size to, Duration duration) async {
    const steps = 48;
    final stepDuration = Duration(
      milliseconds: (duration.inMilliseconds / steps).round(),
    );
    final startPosition = await windowManager.getPosition();
    final center = Offset(
      startPosition.dx + from.width / 2,
      startPosition.dy + from.height / 2,
    );
    final sizes = <Size>[];
    final positions = <Offset>[];
    for (var i = 1; i <= steps; i += 1) {
      final t = Curves.easeInOutCubic.transform(i / steps);
      final width = from.width + (to.width - from.width) * t;
      final height = from.height + (to.height - from.height) * t;
      sizes.add(Size(width, height));
      positions.add(Offset(center.dx - width / 2, center.dy - height / 2));
    }
    for (var i = 0; i < steps; i += 1) {
      await windowManager.setSize(sizes[i]);
      await windowManager.setPosition(positions[i]);
      await Future<void>.delayed(stepDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    AppDebug.log(
      'Splash: build #$_buildCount '
      'ready=$_ready deps=${_dependencies != null} '
      'error=${_loadError != null}',
    );
    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unable to start the app.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (AppDebug.enabled) ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    _loadError.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (!_ready || _dependencies == null) {
      AppDebug.log('Splash: showing splash (_ready=$_ready)');
      return const Scaffold(body: _AppSplash());
    }
    AppDebug.log('Splash: building main screen');
    return TimelineScreen(
      dependencies: _dependencies!,
      enablePreferences: widget.enablePreferences,
    );
  }
}

class _AppSplash extends StatelessWidget {
  const _AppSplash();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: SizedBox(
        width: 400,
        height: 400,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logos/logo2.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  'Please wait...',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
