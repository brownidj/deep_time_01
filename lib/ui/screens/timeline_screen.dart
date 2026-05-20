import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gts_01/app/app_debug.dart';
import 'package:gts_01/app/app_dependencies.dart';
import 'package:gts_01/application/services/timeline_layout_service.dart';
import 'package:gts_01/application/services/timeline_service.dart';
import 'package:gts_01/ui/models/time_label_mode.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';
import 'package:gts_01/ui/widgets/continuous_timeline.dart';
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
  _SelectedDivision? _selectedDivision;
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
        var localScale = AppDebug.timelineScale.clamp(
          AppDebug.minTimelineScale,
          AppDebug.maxTimelineScale,
        );
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Timescale settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioGroup<TimeLabelMode>(
                    groupValue: _labelMode,
                    onChanged: (value) {
                      Navigator.of(context).pop(value);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: TimeLabelMode.values
                          .map(
                            (mode) => RadioListTile<TimeLabelMode>(
                              title: Text(mode.displayName),
                              value: mode,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Timeline scale (${localScale.toStringAsFixed(1)}×)',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Slider(
                    min: AppDebug.minTimelineScale,
                    max: AppDebug.maxTimelineScale,
                    divisions: 12,
                    value: localScale,
                    label: localScale.toStringAsFixed(1),
                    onChanged: (value) {
                      setLocalState(() {
                        localScale = value;
                      });
                      setState(() {
                        AppDebug.timelineScale = value;
                      });
                      _saveTimelineScale(value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load timeline data.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (AppDebug.enabled) ...[
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
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(
                'No timeline data available.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          );
        }

        final divisions = snapshot.data!.divisions;
        final palette = DeepTimePalette(snapshot.data!.palette);
        final layout = _layoutService.build(divisions);
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Geological Time Scale',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: DeepTimePalette.panelText,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SegmentedButton<TimeLabelMode>(
                          segments: TimeLabelMode.values
                              .map(
                                (mode) => ButtonSegment<TimeLabelMode>(
                                  value: mode,
                                  label: Text(mode.displayName),
                                ),
                              )
                              .toList(),
                          selected: {_labelMode},
                          onSelectionChanged: (values) {
                            final mode = values.first;
                            setState(() {
                              _labelMode = mode;
                            });
                            _saveLabelMode(mode);
                          },
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: 'Settings',
                          onPressed: () => _showLabelSettings(context),
                          icon: const Icon(Icons.settings),
                          color: DeepTimePalette.panelText,
                        ),
                      ],
                    ),
                  ),
                  if (selected != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: DeepTimePalette.panelBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: DeepTimePalette.frameBorder,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            '${selected.label} · '
                            '${selected.startMa.toStringAsFixed(2)}–'
                            '${selected.endMa.toStringAsFixed(2)} Ma · '
                            '${selected.durationMa.toStringAsFixed(2)} Ma',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: DeepTimePalette.panelText,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const labelWidth = 96.0;
                          const eonHeight = 44.0;
                          const eraHeight = 52.0;
                          const rowHeight = 110.0;
                          const subRowHeight = 72.0;
                          const stageRowHeight = 120.0;
                          const rlifeRowHeight = 72.0;
                          const minUnitWidth = 96.0;
                          final totalUnits = layout.eonSegments.fold<double>(
                            0.0,
                            (sum, segment) => sum + segment.unitSpan,
                          );
                          final scale = AppDebug.timelineScale.clamp(
                            AppDebug.minTimelineScale,
                            AppDebug.maxTimelineScale,
                          );
                          final scrollWidth = math.max(
                            constraints.maxWidth * scale,
                            totalUnits * minUnitWidth,
                          );

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: labelWidth,
                                child: _RowLabels(
                                  eonHeight: eonHeight,
                                  eraHeight: eraHeight,
                                  rowHeight: rowHeight,
                                  subRowHeight: subRowHeight,
                                  stageRowHeight: stageRowHeight,
                                  rlifeRowHeight: rlifeRowHeight,
                                  labelMode: _labelMode,
                                ),
                              ),
                              Expanded(
                                child: Scrollbar(
                                  controller: _timelineScrollController,
                                  child: SingleChildScrollView(
                                    controller: _timelineScrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: scrollWidth,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          TimelineBands(
                                            eonSegments: layout.eonSegments,
                                            eraSegments: layout.eraSegments,
                                            palette: palette,
                                            onTapSegment: (segment) {
                                              setState(() {
                                                _selectedDivision =
                                                    _SelectedDivision.fromBand(
                                                  segment,
                                                );
                                              });
                                            },
                                          ),
                                          ContinuousTimelineRow(
                                            segments: layout.periodSegments,
                                            selectedId: selected?.id,
                                            palette: palette,
                                            rowHeight: subRowHeight,
                                            onTapSegment: (segment) {
                                              setState(() {
                                                _selectedDivision =
                                                    _SelectedDivision.fromRow(
                                                  segment,
                                                );
                                              });
                                            },
                                          ),
                                          ContinuousTimelineRow(
                                            segments: layout.epochSegments,
                                            selectedId: selected?.id,
                                            palette: palette,
                                            rowHeight: subRowHeight,
                                            onTapSegment: (segment) {
                                              setState(() {
                                                _selectedDivision =
                                                    _SelectedDivision.fromRow(
                                                  segment,
                                                );
                                              });
                                            },
                                          ),
                                          ContinuousTimelineRow(
                                            segments: layout.stageSegments,
                                            selectedId: selected?.id,
                                            palette: palette,
                                            rowHeight: stageRowHeight,
                                            verticalLabels: true,
                                            onTapSegment: (segment) {
                                              setState(() {
                                                _selectedDivision =
                                                    _SelectedDivision.fromRow(
                                                  segment,
                                                );
                                              });
                                            },
                                          ),
                                          ContinuousTimelineRow(
                                            segments: layout.rlifeSegments,
                                            selectedId: selected?.id,
                                            palette: palette,
                                            rowHeight: rlifeRowHeight,
                                            onTapSegment: (segment) {
                                              setState(() {
                                                _selectedDivision =
                                                    _SelectedDivision.fromRow(
                                                  segment,
                                                );
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
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
        _selectedDivision = _SelectedDivision.fromRow(firstSegment);
      });
    });
  }
}

extension SegmentList on List<TimelineRowSegment> {
  TimelineRowSegment? get firstNonGap {
    for (final segment in this) {
      if (!segment.isGap) {
        return segment;
      }
    }
    return null;
  }
}

class _SelectedDivision {
  const _SelectedDivision({
    required this.id,
    required this.label,
    required this.startMa,
    required this.endMa,
  });

  factory _SelectedDivision.fromRow(TimelineRowSegment segment) {
    return _SelectedDivision(
      id: segment.id,
      label: segment.label,
      startMa: segment.startMa,
      endMa: segment.endMa,
    );
  }

  factory _SelectedDivision.fromBand(TimelineBandSegment segment) {
    return _SelectedDivision(
      id: segment.label.hashCode,
      label: segment.label,
      startMa: segment.startMa,
      endMa: segment.endMa,
    );
  }

  final int id;
  final String label;
  final double startMa;
  final double endMa;

  double get durationMa => startMa - endMa;
}

class _RowLabels extends StatelessWidget {
  const _RowLabels({
    required this.eonHeight,
    required this.eraHeight,
    required this.rowHeight,
    required this.subRowHeight,
    required this.stageRowHeight,
    required this.rlifeRowHeight,
    required this.labelMode,
  });

  final double eonHeight;
  final double eraHeight;
  final double rowHeight;
  final double subRowHeight;
  final double stageRowHeight;
  final double rlifeRowHeight;
  final TimeLabelMode labelMode;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: DeepTimePalette.panelText,
      fontWeight: FontWeight.w700,
    );
    return Column(
      children: [
        _RowLabel(
          text: labelMode.labelForRank('eon'),
          height: eonHeight,
          style: labelStyle,
        ),
        _RowLabel(
          text: labelMode.labelForRank('era'),
          height: eraHeight,
          style: labelStyle,
          backgroundColor: DeepTimePalette.frameBorder,
        ),
        _RowLabel(
          text: labelMode.divisionRowLabel(),
          height: subRowHeight,
          style: labelStyle,
        ),
        _RowLabel(
          text: labelMode.seriesRowLabel(),
          height: subRowHeight,
          style: labelStyle,
        ),
        _RowLabel(
          text: labelMode.stageRowLabel(),
          height: stageRowHeight,
          style: labelStyle,
        ),
        _RowLabel(
          text: 'RLife',
          height: rlifeRowHeight,
          style: labelStyle,
        ),
      ],
    );
  }
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({
    required this.text,
    required this.height,
    required this.style,
    this.backgroundColor,
  });

  final String text;
  final double height;
  final TextStyle? style;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? DeepTimePalette.panelBackground,
          border: Border.all(color: DeepTimePalette.frameBorder),
        ),
        child: Center(child: Text(text, style: style)),
      ),
    );
  }
}
