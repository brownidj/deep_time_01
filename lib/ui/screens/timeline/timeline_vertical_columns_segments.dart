part of 'timeline_vertical_columns.dart';

class _VerticalBandColumn extends StatelessWidget {
  const _VerticalBandColumn({
    required this.width,
    required this.height,
    required this.segments,
    required this.unitsTotal,
    required this.selectedId,
    required this.onTapSegment,
    required this.colorForSegment,
    required this.rotateLabel,
    required this.horizontalPadding,
    required this.minHeightForSegment,
  });

  final double width;
  final double height;
  final List<TimelineBandSegment> segments;
  final double unitsTotal;
  final int? selectedId;
  final ValueChanged<TimelineBandSegment> onTapSegment;
  final Color Function(TimelineBandSegment segment) colorForSegment;
  final bool rotateLabel;
  final double horizontalPadding;
  final double Function(TimelineBandSegment segment, TextStyle? style)?
  minHeightForSegment;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty || width <= 0 || height <= 0 || unitsTotal <= 0) {
      return SizedBox(
        width: width.clamp(0, double.infinity),
        height: height.clamp(0, double.infinity),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: DeepTimePalette.timelineGapBackground,
          ),
        ),
      );
    }
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: DeepTimePalette.darkLabel,
      fontWeight: FontWeight.w700,
    );
    final segmentHeights = minHeightForSegment == null
        ? _computeProportionalHeights(
            segments,
            height: height,
            unitsTotal: unitsTotal,
            unitSpan: (segment) => segment.unitSpan,
          )
        : _computeHeightsWithMinimums(
            segments,
            height: height,
            unitsTotal: unitsTotal,
            minHeights: [
              for (final segment in segments)
                minHeightForSegment!(segment, labelStyle),
            ],
            unitSpan: (segment) => segment.unitSpan,
          );
    var consumed = 0.0;
    final children = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final segmentHeight = i == segments.length - 1
          ? (height - consumed).clamp(0.0, height)
          : segmentHeights[i].clamp(0.0, height);
      consumed += segmentHeight;
      final isSelected = selectedId == segment.id;
      final baseColor = segment.isGap
          ? DeepTimePalette.timelineGapBackground
          : colorForSegment(segment);
      final color = isSelected && !segment.isGap
          ? _darken(baseColor, 0.93)
          : baseColor;
      final borderColor = segment.isGap
          ? DeepTimePalette.timelineGapBackground
          : DeepTimePalette.frameBorder;
      final content = _VerticalSegmentTile(
        width: width,
        height: segmentHeight,
        color: color,
        borderColor: borderColor,
        label: segment.label,
        rotateLabel: rotateLabel,
        horizontalPadding: horizontalPadding,
        debugLabel: AppDebug.enabled ? segment.unitSpan.toStringAsFixed(1) : null,
      );
      if (segment.isGap) {
        children.add(content);
        continue;
      }
      final explanation = segment.explanation;
      children.add(
        Tooltip(
          message:
              '${segment.label} • ${formatTimeRange(startMa: segment.startMa, endMa: segment.endMa, startPrecision: 2, endPrecision: 2, durationPrecision: 2)}',
          child: InkWell(
            onTap: () => onTapSegment(segment),
            onLongPress: explanation == null || explanation.trim().isEmpty
                ? null
                : () => showTimelineExplanationDialog(
                    context: context,
                    title: segment.label,
                    explanation: explanation,
                  ),
            child: content,
          ),
        ),
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: Column(children: children),
    );
  }
}

class _VerticalRowColumn extends StatelessWidget {
  const _VerticalRowColumn({
    required this.width,
    required this.height,
    required this.segments,
    required this.unitsTotal,
    required this.selectedId,
    required this.onTapSegment,
    required this.colorForSegment,
    required this.rotateLabel,
    required this.horizontalPadding,
    required this.minHeightForSegment,
  });

  final double width;
  final double height;
  final List<TimelineRowSegment> segments;
  final double unitsTotal;
  final int? selectedId;
  final ValueChanged<TimelineRowSegment> onTapSegment;
  final Color Function(TimelineRowSegment segment) colorForSegment;
  final bool rotateLabel;
  final double horizontalPadding;
  final double Function(TimelineRowSegment segment, TextStyle? style)?
  minHeightForSegment;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty || width <= 0 || height <= 0 || unitsTotal <= 0) {
      return SizedBox(
        width: width.clamp(0, double.infinity),
        height: height.clamp(0, double.infinity),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: DeepTimePalette.timelineGapBackground,
          ),
        ),
      );
    }
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: DeepTimePalette.darkLabel,
      fontWeight: FontWeight.w700,
    );
    final segmentHeights = minHeightForSegment == null
        ? _computeProportionalHeights(
            segments,
            height: height,
            unitsTotal: unitsTotal,
            unitSpan: (segment) => segment.unitSpan,
          )
        : _computeHeightsWithMinimums(
            segments,
            height: height,
            unitsTotal: unitsTotal,
            minHeights: [
              for (final segment in segments)
                minHeightForSegment!(segment, labelStyle),
            ],
            unitSpan: (segment) => segment.unitSpan,
          );
    var consumed = 0.0;
    final children = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final segmentHeight = i == segments.length - 1
          ? (height - consumed).clamp(0.0, height)
          : segmentHeights[i].clamp(0.0, height);
      consumed += segmentHeight;
      final isSelected = selectedId == segment.id;
      final baseColor = segment.isGap
          ? DeepTimePalette.timelineGapBackground
          : colorForSegment(segment);
      final color = isSelected && !segment.isGap
          ? _darken(baseColor, 0.93)
          : baseColor;
      final borderColor = segment.isGap
          ? DeepTimePalette.timelineGapBackground
          : DeepTimePalette.periodDivider;
      final content = _VerticalSegmentTile(
        width: width,
        height: segmentHeight,
        color: color,
        borderColor: borderColor,
        label: segment.label,
        rotateLabel: rotateLabel,
        horizontalPadding: horizontalPadding,
        debugLabel: AppDebug.enabled ? segment.unitSpan.toStringAsFixed(1) : null,
      );
      if (segment.isGap) {
        children.add(content);
        continue;
      }
      final explanation = segment.explanation;
      children.add(
        Tooltip(
          message:
              '${segment.label} • ${formatTimeRange(startMa: segment.startMa, endMa: segment.endMa, startPrecision: 2, endPrecision: 2, durationPrecision: 2)}',
          child: InkWell(
            onTap: () => onTapSegment(segment),
            onLongPress: explanation == null || explanation.trim().isEmpty
                ? null
                : () => showTimelineExplanationDialog(
                    context: context,
                    title: segment.label,
                    explanation: explanation,
                  ),
            child: content,
          ),
        ),
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: Column(children: children),
    );
  }
}

class _VerticalSegmentTile extends StatelessWidget {
  const _VerticalSegmentTile({
    required this.width,
    required this.height,
    required this.color,
    required this.borderColor,
    required this.label,
    required this.rotateLabel,
    required this.horizontalPadding,
    this.debugLabel,
  });

  final double width;
  final double height;
  final Color color;
  final Color borderColor;
  final String label;
  final bool rotateLabel;
  final double horizontalPadding;
  final String? debugLabel;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: DeepTimePalette.darkLabel,
      fontWeight: FontWeight.w700,
    );
    final maxLines = height >= 96
        ? 3
        : height >= 64
        ? 2
        : 1;
    final textWidget = Text(
      label,
      style: textStyle,
      textAlign: TextAlign.center,
      maxLines: rotateLabel ? 1 : maxLines,
      softWrap: !rotateLabel,
      overflow: rotateLabel ? TextOverflow.visible : TextOverflow.ellipsis,
    );
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Stack(
          children: [
            Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 8,
          ),
              child: Center(
                child: rotateLabel
                    ? RotatedBox(quarterTurns: 3, child: textWidget)
                    : textWidget,
              ),
            ),
            if (debugLabel != null && debugLabel!.isNotEmpty)
              Positioned(
                top: 2,
                right: 4,
                child: Text(
                  debugLabel!,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xAAFFFFFF),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
