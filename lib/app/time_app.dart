import 'package:flutter/material.dart';
import 'package:gts_01/app/app_debug.dart';
import 'package:gts_01/app/app_dependencies.dart';
import 'package:gts_01/ui/screens/timeline_screen.dart';

class TimeApp extends StatelessWidget {
  const TimeApp({super.key, required this.enablePreferences});

  final bool enablePreferences;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geological Time Scale',
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
  late final Future<AppDependencies> _dependenciesFuture;

  @override
  void initState() {
    super.initState();
    _dependenciesFuture = AppDependencies.build();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppDependencies>(
      future: _dependenciesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unable to start the app.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (snapshot.hasError && AppDebug.enabled) ...[
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        snapshot.error.toString(),
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
        return TimelineScreen(
          dependencies: snapshot.data!,
          enablePreferences: widget.enablePreferences,
        );
      },
    );
  }
}
