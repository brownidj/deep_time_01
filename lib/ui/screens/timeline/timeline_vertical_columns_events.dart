part of 'timeline_vertical_columns.dart';

class _VerticalEventsColumn extends StatelessWidget {
  const _VerticalEventsColumn({
    required this.width,
    required this.height,
    required this.events,
    required this.totalUnits,
    required this.palette,
    required this.lineLeft,
  });

  final double width;
  final double height;
  final List<TimelineEventSegment> events;
  final double totalUnits;
  final DeepTimePalette palette;
  final double lineLeft;

  @override
  Widget build(BuildContext context) {
    if (width <= 0 || height <= 0 || totalUnits <= 0) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DeepTimePalette.timelineGapBackground,
          border: Border.all(color: DeepTimePalette.periodDivider, width: 1),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final event in events.where(
              (e) => e.type == TimelineEventType.bar,
            ))
              _VerticalEventBar(
                event: event,
                width: width,
                height: height,
                totalUnits: totalUnits,
                palette: palette,
              ),
            for (final event in events.where(
              (e) => e.type == TimelineEventType.point,
            ))
              _VerticalEventPoint(
                event: event,
                width: width,
                height: height,
                totalUnits: totalUnits,
                lineLeft: lineLeft,
              ),
          ],
        ),
      ),
    );
  }
}

class _VerticalEventBar extends StatelessWidget {
  const _VerticalEventBar({
    required this.event,
    required this.width,
    required this.height,
    required this.totalUnits,
    required this.palette,
  });

  final TimelineEventSegment event;
  final double width;
  final double height;
  final double totalUnits;
  final DeepTimePalette palette;

  @override
  Widget build(BuildContext context) {
    final yStart = (event.startUnit / totalUnits * height).clamp(0.0, height);
    final yEnd = (event.endUnit / totalUnits * height).clamp(0.0, height);
    final top = math.min(yStart, yEnd);
    final rawHeight = (yEnd - yStart).abs();
    final barHeight = math.max(10.0, rawHeight);
    final barWidth = math.max(10.0, width * 0.28);
    final left = (width - barWidth) / 2;
    final fillColor = _safeColorForKey(event.colorKey, palette);
    final explanation = event.explanation;

    return Positioned(
      left: left,
      top: top,
      width: barWidth,
      height: barHeight,
      child: Tooltip(
        message:
            '${event.label} • ${formatTimeRange(startMa: event.startMa, endMa: event.endMa, startPrecision: 1, endPrecision: 1, durationPrecision: 1)}',
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: explanation == null || explanation.trim().isEmpty
              ? null
              : () => showTimelineExplanationDialog(
                  context: context,
                  title: event.label,
                  explanation: explanation.trim(),
                ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: DeepTimePalette.periodDivider),
            ),
          ),
        ),
      ),
    );
  }
}

class _VerticalEventPoint extends StatelessWidget {
  const _VerticalEventPoint({
    required this.event,
    required this.width,
    required this.height,
    required this.totalUnits,
    required this.lineLeft,
  });

  final TimelineEventSegment event;
  final double width;
  final double height;
  final double totalUnits;
  final double lineLeft;

  @override
  Widget build(BuildContext context) {
    final y = (event.startUnit / totalUnits * height).clamp(0.0, height);
    const rowHeight = 20.0;
    final rowTop = (y - rowHeight / 2).clamp(0.0, height - rowHeight);
    final markerSize = 9.0;
    final markerLeft = 6.0;
    final lineRight = markerLeft;
    final textLeft = (markerLeft + markerSize + 6).clamp(0.0, width - 6);
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: DeepTimePalette.panelText,
      fontWeight: FontWeight.w700,
    );
    final explanation = event.explanation;

    return Positioned(
      left: 0,
      right: 0,
      top: rowTop,
      height: rowHeight,
      child: Tooltip(
        message:
            '${event.label} • ${formatTimeRange(startMa: event.startMa, endMa: event.startMa == event.endMa ? null : event.endMa, startPrecision: 1, endPrecision: 1, durationPrecision: 1)}',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: explanation == null || explanation.trim().isEmpty
              ? null
              : () => showTimelineExplanationDialog(
                  context: context,
                  title: event.label,
                  explanation: explanation.trim(),
                ),
          child: Stack(
            children: [
              if (lineRight > lineLeft)
                Positioned(
                  left: lineLeft,
                  width: lineRight - lineLeft,
                  top: rowHeight / 2 - 0.5,
                  child: Container(height: 1, color: const Color(0xFFFFEB3B)),
                ),
              Positioned(
                left: markerLeft,
                top: rowHeight / 2 - markerSize / 2,
                child: SizedBox(
                  width: markerSize,
                  height: markerSize,
                  child: CustomPaint(
                    painter: _LeftTrianglePainter(
                      color: const Color(0xFFFFEB3B),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: textLeft,
                right: 6,
                top: 2,
                child: Text(
                  event.shortLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
