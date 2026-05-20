import 'package:flutter/material.dart';
import 'package:gts_01/application/services/timeline_layout_service.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';
import 'package:gts_01/ui/widgets/timeline_segment_label.dart';

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
          TimelineBandRow(
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
          TimelineBandRow(
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

class TimelineBandRow extends StatelessWidget {
  const TimelineBandRow({
    super.key,
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
      child: TimelineSegmentLabel(
        label: segment.label,
        width: width,
        style: style,
      ),
    );
  }
}
