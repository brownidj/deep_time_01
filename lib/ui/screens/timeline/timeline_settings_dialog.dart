import 'package:flutter/material.dart';
import 'package:gts_01/app/app_debug.dart';
import 'package:gts_01/ui/models/time_label_mode.dart';

class TimelineSettingsDialog extends StatefulWidget {
  const TimelineSettingsDialog({
    super.key,
    required this.labelMode,
    required this.onScaleChanged,
  });

  final TimeLabelMode labelMode;
  final ValueChanged<double> onScaleChanged;

  @override
  State<TimelineSettingsDialog> createState() => _TimelineSettingsDialogState();
}

class _TimelineSettingsDialogState extends State<TimelineSettingsDialog> {
  late double _localScale;

  @override
  void initState() {
    super.initState();
    _localScale = AppDebug.timelineScale.clamp(
      AppDebug.minTimelineScale,
      AppDebug.maxTimelineScale,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Timescale settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioGroup<TimeLabelMode>(
            groupValue: widget.labelMode,
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
              'Timeline scale (${_localScale.toStringAsFixed(1)}×)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Slider(
            min: AppDebug.minTimelineScale,
            max: AppDebug.maxTimelineScale,
            divisions: 12,
            value: _localScale,
            label: _localScale.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _localScale = value;
              });
              widget.onScaleChanged(value);
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
  }
}
