import 'package:flutter/material.dart';
import 'package:gts_01/ui/screens/timeline/timeline_selection.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';

class TimelineSelectionPanel extends StatelessWidget {
  const TimelineSelectionPanel({super.key, required this.selection});

  final SelectedDivision selection;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            '${selection.label} · '
            '${selection.startMa.toStringAsFixed(2)}–'
            '${selection.endMa.toStringAsFixed(2)} Ma · '
            '${selection.durationMa.toStringAsFixed(2)} Ma',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: DeepTimePalette.panelText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
