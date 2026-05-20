import 'package:flutter/material.dart';
import 'package:gts_01/application/services/timeline_layout_service.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';

class TimelineBands extends StatelessWidget {
  const TimelineBands({
    super.key,
    required this.eonSegments,
    required this.eraSegments,
    required this.palette,
    required this.onTapSegment,
  });

  final List<TimelineBandSegment> eonSegments;
  final List<TimelineBandSegment> eraSegments;
  final DeepTimePalette palette;
  final ValueChanged<TimelineBandSegment> onTapSegment;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (eonSegments.isNotEmpty)
          _TimelineBandRow(
            segments: eonSegments,
            height: 44,
            colorForSegment: (segment) => segment.isGap
                ? const Color(0xFF2A2E2E)
                : palette.colorForKey(segment.colorKey),
            labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: DeepTimePalette.darkLabel,
            ),
            borderColor: DeepTimePalette.frameBorder,
            overlayBuilder: (context, index, width) {
              final segment = eonSegments[index];
              final content = _BandLabel(
                segment: segment,
                width: width,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: DeepTimePalette.darkLabel,
                ),
              );
              if (segment.isGap) {
                return content;
              }
              return InkWell(
                onTap: () => onTapSegment(segment),
                child: content,
              );
            },
          ),
        if (eraSegments.isNotEmpty)
          _TimelineBandRow(
            segments: eraSegments,
            height: 52,
            colorForSegment: (segment) => segment.isGap
                ? const Color(0xFF2A2E2E)
                : palette.colorForKey(segment.colorKey),
            labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: DeepTimePalette.darkLabel,
            ),
            borderColor: DeepTimePalette.frameBorder,
            overlayBuilder: (context, index, width) {
              final segment = eraSegments[index];
              final content = _BandLabel(
                segment: segment,
                width: width,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: DeepTimePalette.darkLabel,
                ),
              );
              if (segment.isGap) {
                return content;
              }
              return InkWell(
                onTap: () => onTapSegment(segment),
                child: content,
              );
            },
          ),
      ],
    );
  }
}

class ContinuousTimelineRow extends StatelessWidget {
  const ContinuousTimelineRow({
    super.key,
    required this.segments,
    required this.selectedId,
    required this.onTapSegment,
    required this.palette,
    required this.rowHeight,
    this.verticalLabels = false,
  });

  final List<TimelineRowSegment> segments;
  final int? selectedId;
  final ValueChanged<TimelineRowSegment> onTapSegment;
  final DeepTimePalette palette;
  final double rowHeight;
  final bool verticalLabels;

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
      child: _TimelineBandRow(
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
                    child: _SegmentLabel(
                      label: segment.label,
                      width: width,
                      style: labelStyle,
                      vertical: verticalLabels,
                    ),
                  );
                }
                if (constraints.maxHeight < 48) {
                  return _SegmentLabel(
                    label: segment.label,
                    width: width,
                    style: labelStyle,
                    vertical: verticalLabels,
                  );
                }

                final canShowRange =
                    width >= 96 && !isGap && constraints.maxHeight >= 60;
                final canShowSecondary =
                    showSecondary && constraints.maxHeight >= 56;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SegmentLabel(
                      label: segment.label,
                      width: width,
                      style: labelStyle,
                      vertical: verticalLabels,
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

class _TimelineBandRow extends StatelessWidget {
  const _TimelineBandRow({
    required this.segments,
    required this.height,
    required this.colorForSegment,
    required this.borderColor,
    required this.labelStyle,
    this.overlayBuilder,
  });

  final List<TimelineBandSegment> segments;
  final double height;
  final Color Function(TimelineBandSegment segment) colorForSegment;
  final Color borderColor;
  final TextStyle? labelStyle;
  final Widget Function(BuildContext context, int index, double width)?
  overlayBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (segments.isEmpty || constraints.maxWidth <= 0) {
            return const SizedBox.shrink();
          }

          final totalUnits = segments.fold<double>(
            0.0,
            (sum, segment) => sum + segment.unitSpan,
          );
          if (totalUnits <= 0) {
            return const SizedBox.shrink();
          }

          var consumedWidth = 0.0;
          final children = <Widget>[];
          for (var index = 0; index < segments.length; index++) {
            final segment = segments[index];
            final rawWidth =
                constraints.maxWidth * (segment.unitSpan / totalUnits);
            final width = index == segments.length - 1
                ? (constraints.maxWidth - consumedWidth).clamp(
                    0.0,
                    constraints.maxWidth,
                  )
                : rawWidth.clamp(0.0, constraints.maxWidth);
            consumedWidth += width;

            final content = overlayBuilder == null
                ? _BandLabel(segment: segment, width: width, style: labelStyle)
                : overlayBuilder!(context, index, width);

            children.add(
              SizedBox(
                width: width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorForSegment(segment),
                    border: Border.all(color: borderColor),
                  ),
                  child: content,
                ),
              ),
            );
          }

          return Row(children: children);
        },
      ),
    );
  }
}

class _BandLabel extends StatelessWidget {
  const _BandLabel({
    required this.segment,
    required this.width,
    required this.style,
  });

  final TimelineBandSegment segment;
  final double width;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: _SegmentLabel(label: segment.label, width: width, style: style),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({
    required this.label,
    required this.width,
    required this.style,
    this.vertical = false,
  });

  final String label;
  final double width;
  final TextStyle? style;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return const SizedBox.shrink();
    }
    if (width < 24) {
      return const SizedBox.shrink();
    }
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    if (!vertical) {
      return Align(
        alignment: Alignment.centerLeft,
        child: text,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: RotatedBox(
                quarterTurns: 3,
                child: text,
              ),
            ),
          ),
        );
      },
    );
  }
}
