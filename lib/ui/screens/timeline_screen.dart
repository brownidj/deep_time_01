import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gts_01/app/app_debug.dart';
import 'package:gts_01/app/app_dependencies.dart';
import 'package:gts_01/application/services/timeline_layout_service.dart';
import 'package:gts_01/application/services/timeline_service.dart';
import 'package:gts_01/ui/models/time_label_mode.dart';
import 'package:gts_01/ui/screens/timeline/timeline_body.dart';
import 'package:gts_01/ui/screens/timeline/timeline_header.dart';
import 'package:gts_01/ui/screens/timeline/timeline_selection_panel.dart';
import 'package:gts_01/ui/screens/timeline/timeline_selection.dart';
import 'package:gts_01/ui/screens/timeline/timeline_settings_dialog.dart';
import 'package:gts_01/ui/screens/timeline/timeline_state_views.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({
    super.key,
    required this.dependencies,
    required this.enablePreferences,
  });

  final AppDependencies dependencies;
  final bool enablePreferences;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  static const _labelModeKey = 'time_label_mode';
  static const _timelineScaleKey = 'timeline_scale';

  late final Future<TimelineSnapshot> _snapshotFuture;
  final TimelineLayoutService _layoutService = TimelineLayoutService();
  final ScrollController _timelineScrollController = ScrollController();
  SelectedDivision? _selectedDivision;
  TimeLabelMode _labelMode = TimeLabelMode.geologicTime;
  bool _labelModeRetryScheduled = false;
  int _labelModeRetryCount = 0;
  static const int _maxLabelModeRetries = 2;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = widget.dependencies.timelineService.loadSnapshot();
    if (widget.enablePreferences) {
      _loadPreferences();
    }
  }

  @override
  void dispose() {
    _timelineScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    if (!widget.enablePreferences) {
      return;
    }
    if (_labelModeRetryCount >= _maxLabelModeRetries) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_labelModeKey);
      final storedScale = prefs.getDouble(_timelineScaleKey);
      if (!mounted) {
        return;
      }
      setState(() {
        _labelMode = parseTimeLabelMode(stored);
        if (storedScale != null) {
          AppDebug.timelineScale = storedScale;
        }
      });
    } on PlatformException catch (error, stackTrace) {
      _scheduleLabelModeRetry(error);
      AppDebug.log(
        'Failed to load preferences',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to load preferences',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _saveLabelMode(TimeLabelMode mode) async {
    if (!widget.enablePreferences) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_labelModeKey, mode.id);
    } on PlatformException catch (error, stackTrace) {
      _scheduleLabelModeRetry(error);
      AppDebug.log(
        'Failed to save label mode',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to save label mode',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _saveTimelineScale(double scale) async {
    if (!widget.enablePreferences) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_timelineScaleKey, scale);
    } on PlatformException catch (error, stackTrace) {
      _scheduleLabelModeRetry(error);
      AppDebug.log(
        'Failed to save timeline scale',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to save timeline scale',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _scheduleLabelModeRetry(PlatformException error) {
    if (_labelModeRetryScheduled || !widget.enablePreferences) {
      return;
    }
    if (error.code != 'channel-error') {
      return;
    }
    if (_labelModeRetryCount >= _maxLabelModeRetries) {
      return;
    }
    _labelModeRetryCount += 1;
    _labelModeRetryScheduled = true;
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted || !widget.enablePreferences) {
        return;
      }
      _labelModeRetryScheduled = false;
      _loadPreferences();
    });
  }

  Future<void> _showLabelSettings(BuildContext context) async {
    final selected = await showDialog<TimeLabelMode>(
      context: context,
      builder: (context) {
        return TimelineSettingsDialog(
          labelMode: _labelMode,
          onScaleChanged: (value) {
            setState(() {
              AppDebug.timelineScale = value;
            });
            _saveTimelineScale(value);
          },
        );
      },
    );

    if (selected == null || selected == _labelMode) {
      return;
    }

    setState(() {
      _labelMode = selected;
    });
    await _saveLabelMode(selected);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TimelineSnapshot>(
      future: _snapshotFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const TimelineLoadingView();
        }
        if (snapshot.hasError) {
          return TimelineErrorView(error: snapshot.error!);
        }
        if (!snapshot.hasData) {
          return const TimelineEmptyView();
        }

        final divisions = snapshot.data!.divisions;
        final palette = DeepTimePalette(snapshot.data!.palette);
        final markers = snapshot.data!.markers;
        final layout = _layoutService.build(divisions, markers);
        _primeSelection(
          layout.periodSegments,
          layout.epochSegments,
          layout.stageSegments,
        );
        final selected = _selectedDivision;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DeepTimePalette.appBackgroundAccent,
                  DeepTimePalette.appBackground,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TimelineHeader(
                    labelMode: _labelMode,
                    onLabelModeChanged: (mode) {
                      setState(() {
                        _labelMode = mode;
                      });
                      _saveLabelMode(mode);
                    },
                    onSettings: () => _showLabelSettings(context),
                  ),
                  if (selected != null)
                    TimelineSelectionPanel(selection: selected),
                  TimelineBody(
                    layout: layout,
                    palette: palette,
                    markers: markers,
                    labelMode: _labelMode,
                    scrollController: _timelineScrollController,
                    selectedId: selected?.id,
                    onBandSelect: (segment) {
                      setState(() {
                        _selectedDivision =
                            SelectedDivision.fromBand(segment);
                      });
                    },
                    onSelect: (segment) {
                      setState(() {
                        _selectedDivision = SelectedDivision.fromRow(segment);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _primeSelection(
    List<TimelineRowSegment> periods,
    List<TimelineRowSegment> epochs,
    List<TimelineRowSegment> stages,
  ) {
    final firstSegment =
        periods.firstNonGap ?? epochs.firstNonGap ?? stages.firstNonGap;
    if (_selectedDivision != null || firstSegment == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedDivision = SelectedDivision.fromRow(firstSegment);
      });
    });
  }
}
