import 'package:flutter/material.dart';
import 'package:deep_time/domain/models/clade_display_group.dart';
import 'package:deep_time/ui/models/clade_view_mode.dart';
import 'package:deep_time/ui/models/time_label_mode.dart';

class TimelineSettingsDialog extends StatefulWidget {
  const TimelineSettingsDialog({
    super.key,
    required this.labelMode,
    required this.onScaleChanged,
    required this.cladeViewMode,
    required this.cladeCategoryId,
    required this.cladeDisplayGroups,
    required this.onCladeViewModeChanged,
    required this.onCladeCategoryChanged,
  });

  final TimeLabelMode labelMode;
  final ValueChanged<double> onScaleChanged;
  final CladeViewMode cladeViewMode;
  final String cladeCategoryId;
  final List<CladeDisplayGroup> cladeDisplayGroups;
  final ValueChanged<CladeViewMode> onCladeViewModeChanged;
  final ValueChanged<String> onCladeCategoryChanged;

  @override
  State<TimelineSettingsDialog> createState() => _TimelineSettingsDialogState();
}

class _TimelineSettingsDialogState extends State<TimelineSettingsDialog> {
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
              'Clade view',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 4),
          RadioGroup<CladeViewMode>(
            groupValue: widget.cladeViewMode,
            onChanged: (value) {
              if (value != null) {
                widget.onCladeViewModeChanged(value);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: CladeViewMode.values
                  .map(
                    (mode) => RadioListTile<CladeViewMode>(
                      title: Text(mode.label),
                      value: mode,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Category',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: widget.cladeCategoryId,
            items: [
              const DropdownMenuItem<String>(value: 'all', child: Text('All')),
              ...widget.cladeDisplayGroups.map(
                (group) => DropdownMenuItem<String>(
                  value: group.id,
                  child: Text(group.label),
                ),
              ),
            ],
            onChanged: widget.cladeViewMode == CladeViewMode.byCategory
                ? (value) {
                    if (value != null) {
                      widget.onCladeCategoryChanged(value);
                    }
                  }
                : null,
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
