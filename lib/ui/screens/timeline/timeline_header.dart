import 'package:flutter/material.dart';
import 'package:gts_01/ui/models/time_label_mode.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';

class TimelineHeader extends StatelessWidget {
  const TimelineHeader({
    super.key,
    required this.labelMode,
    required this.onLabelModeChanged,
    required this.onSettings,
  });

  final TimeLabelMode labelMode;
  final ValueChanged<TimeLabelMode> onLabelModeChanged;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Geological Time Scale',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
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
            selected: {labelMode},
            onSelectionChanged: (values) {
              onLabelModeChanged(values.first);
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Settings',
            onPressed: onSettings,
            icon: const Icon(Icons.settings),
            color: DeepTimePalette.panelText,
          ),
        ],
      ),
    );
  }
}
