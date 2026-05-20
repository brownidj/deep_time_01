import 'package:flutter/material.dart';
import 'package:gts_01/application/services/timeline_layout_service.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';
import 'package:gts_01/ui/widgets/timeline_band_row.dart';
import 'package:gts_01/ui/widgets/timeline_segment_label.dart';

class ContinuousTimelineRow extends StatelessWidget {
  const ContinuousTimelineRow({
    super.key,
    required this.segments,
    required this.selectedId,
    required this.onTapSegment,
    required this.palette,
    required this.rowHeight,
    this.verticalLabels = false,
    this.multiLineLabels = false,
    this.maxLabelLines = 1,
  });

  final List<TimelineRowSegment> segments;
  final int? selectedId;
  final ValueChanged<TimelineRowSegment> onTapSegment;
  final DeepTimePalette palette;
  final double rowHeight;
  final bool verticalLabels;
  final bool multiLineLabels;
  final int maxLabelLines;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: verticalLabels ? FontWeight.w500 : FontWeight.w700,
      color: DeepTimePalette.darkLabel,
      fontSize: verticalLabels
          ? (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) - 2
          : Theme.of(context).textTheme.titleMedium?.fontSize,
    );
    final detailStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: DeepTimePalette.darkLabel,
      fontWeight: FontWeight.w600,
    );

    return SizedBox(
      width: double.infinity,
      child: TimelineBandRow(
        segments: segments
            .map(
              (segment) => TimelineBandSegment(
                label: segment.label,
                rank: segment.rank,
                startMa: segment.startMa,
                endMa: segment.endMa,
                colorKey: segment.colorKey,
                isGap: segment.isGap,
                unitSpan: segment.unitSpan,
              ),
            )
            .toList(),
        height: rowHeight,
        colorForSegment: (segment) => segment.isGap
            ? const Color(0xFF2A2E2E)
            : palette.colorForKey(segment.colorKey),
        borderColor: DeepTimePalette.periodDivider,
        labelStyle: labelStyle,
        overlayBuilder: (context, index, width) {
          final segment = segments[index];
          final isSelected = selectedId == segment.id;
          final showSecondary = width >= 160 && segment.secondaryLabel != null;
          final isGap = segment.isGap;
          final borderColor = isSelected && !isGap
              ? DeepTimePalette.selectedOutline
              : DeepTimePalette.periodDivider;
          Color baseColor;
          try {
            baseColor = isGap
                ? const Color(0xFF2A2E2E)
                : palette.colorForKey(segment.colorKey);
          } catch (error) {
            baseColor = const Color(0xFF7A1F1F);
          }

          final content = AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: verticalLabels
                ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
                : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: baseColor,
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (verticalLabels) {
                  return SizedBox.expand(
                    child: TimelineSegmentLabel(
                      label: segment.label,
                      width: width,
                      style: labelStyle,
                      vertical: verticalLabels,
                      maxLines: maxLabelLines,
                      overflow: multiLineLabels
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                  );
                }
                if (constraints.maxHeight < 48) {
                  return TimelineSegmentLabel(
                    label: segment.label,
                    width: width,
                    style: labelStyle,
                    vertical: verticalLabels,
                    maxLines: maxLabelLines,
                    overflow: multiLineLabels
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  );
                }

                final canShowRange =
                    width >= 96 && !isGap && constraints.maxHeight >= 60;
                final canShowSecondary =
                    showSecondary && constraints.maxHeight >= 56;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TimelineSegmentLabel(
                      label: segment.label,
                      width: width,
                      style: labelStyle,
                      vertical: verticalLabels,
                      maxLines: maxLabelLines,
                      overflow: multiLineLabels
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    if (canShowSecondary)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          segment.secondaryLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: detailStyle,
                        ),
                      ),
                    if (canShowRange) ...[
                      const Spacer(),
                      Text(
                        '${segment.startMa.toStringAsFixed(1)}–${segment.endMa.toStringAsFixed(1)} Ma',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: detailStyle,
                      ),
                    ],
                  ],
                );
              },
            ),
          );

          if (isGap) {
            return content;
          }

          return Tooltip(
            message:
                '${segment.label} • '
                '${segment.startMa.toStringAsFixed(2)}–'
                '${segment.endMa.toStringAsFixed(2)} Ma',
            child: InkWell(
              onTap: () => onTapSegment(segment),
              onLongPress: () => _showDebugDialog(context, segment),
              child: content,
            ),
          );
        },
      ),
    );
  }
}

void _showDebugDialog(BuildContext context, TimelineRowSegment segment) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Segment debug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Label: ${segment.label}'),
            Text('Rank: ${segment.rank.name}'),
            Text('Start: ${segment.startMa}'),
            Text('End: ${segment.endMa}'),
            Text('Key: ${segment.colorKey}'),
            Text('Gap: ${segment.isGap}'),
            Text('Units: ${segment.unitSpan}'),
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
}
