part of 'timeline_vertical_columns.dart';

double _minHeightForStageLabel(
  TimelineRowSegment segment,
  TextStyle? style, {
  double verticalPadding = 4,
}) {
  if (segment.isGap || segment.label.trim().isEmpty) {
    return 0.0;
  }
  final painter = TextPainter(
    text: TextSpan(text: segment.label, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.height + (verticalPadding * 2);
}

double _minHeightForVerticalLabel(
  TimelineRowSegment segment,
  TextStyle? style, {
  double verticalPadding = 4,
}) {
  if (segment.isGap || segment.label.trim().isEmpty) {
    return 0.0;
  }
  final painter = TextPainter(
    text: TextSpan(text: segment.label, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.width + (verticalPadding * 2);
}

Map<int, double> _buildStageMinHeights(
  List<TimelineRowSegment> stages,
  TextStyle? style, {
  double verticalPadding = 4,
}) {
  return {
    for (final segment in stages)
      segment.id: _minHeightForStageLabel(
        segment,
        style,
        verticalPadding: verticalPadding,
      ),
  };
}

Map<int, double> _sumChildMinHeights<P, C>(
  List<P> parents,
  List<C> children,
  Map<int, double> childMinHeights,
  double Function(P parent) parentStart,
  double Function(P parent) parentEnd,
  int Function(P parent) parentId,
  double Function(C child) childStart,
  double Function(C child) childEnd,
  int Function(C child) childId,
  bool Function(C child) childIsGap,
) {
  final result = <int, double>{};
  for (final parent in parents) {
    if (parents.isEmpty) {
      continue;
    }
    var sum = 0.0;
    for (final child in children) {
      if (childIsGap(child)) {
        continue;
      }
      final childMin = childMinHeights[childId(child)] ?? 0.0;
      if (childMin <= 0) {
        continue;
      }
      if (childStart(child) <= parentStart(parent) &&
          childEnd(child) >= parentEnd(parent)) {
        sum += childMin;
      }
    }
    result[parentId(parent)] = sum;
  }
  return result;
}

Map<int, double> _buildPeriodHeights(
  List<TimelineRowSegment> periods,
  List<TimelineRowSegment> epochs,
  Map<int, double> epochHeights,
  TextStyle? periodStyle, {
  double verticalPadding = 4,
}) {
  final result = <int, double>{};
  for (final period in periods) {
    var sum = 0.0;
    var hasEpochs = false;
    for (final epoch in epochs) {
      if (epoch.isGap) {
        continue;
      }
      if (epoch.startMa <= period.startMa && epoch.endMa >= period.endMa) {
        hasEpochs = true;
        sum += epochHeights[epoch.id] ?? 0.0;
      }
    }
    if (!hasEpochs) {
      sum = _minHeightForVerticalLabel(
        period,
        periodStyle,
        verticalPadding: verticalPadding,
      );
    }
    result[period.id] = sum;
  }
  return result;
}

class _MinHeightMaps {
  const _MinHeightMaps({
    required this.stageHeights,
    required this.epochHeights,
    required this.periodHeights,
    required this.eraHeights,
    required this.eonHeights,
  });

  final Map<int, double> stageHeights;
  final Map<int, double> epochHeights;
  final Map<int, double> periodHeights;
  final Map<int, double> eraHeights;
  final Map<int, double> eonHeights;
}

_MinHeightMaps _buildMinHeightMaps(
  TimelineLayoutSnapshot layout,
  TextStyle? stageStyle, {
  TextStyle? periodStyle,
  double verticalPadding = 4,
}) {
  final stageHeights = _buildStageMinHeights(
    layout.stageSegments,
    stageStyle,
    verticalPadding: verticalPadding,
  );
  final epochHeights =
      _sumChildMinHeights<TimelineRowSegment, TimelineRowSegment>(
        layout.epochSegments,
        layout.stageSegments,
        stageHeights,
        (parent) => parent.startMa,
        (parent) => parent.endMa,
        (parent) => parent.id,
        (child) => child.startMa,
        (child) => child.endMa,
        (child) => child.id,
        (child) => child.isGap,
      );
  final periodHeights = _buildPeriodHeights(
    layout.periodSegments,
    layout.epochSegments,
    epochHeights,
    periodStyle,
    verticalPadding: verticalPadding,
  );
  final eraHeights =
      _sumChildMinHeights<TimelineBandSegment, TimelineRowSegment>(
        layout.eraSegments,
        layout.periodSegments,
        periodHeights,
        (parent) => parent.startMa,
        (parent) => parent.endMa,
        (parent) => parent.id,
        (child) => child.startMa,
        (child) => child.endMa,
        (child) => child.id,
        (child) => child.isGap,
      );
  final eonHeights =
      _sumChildMinHeights<TimelineBandSegment, TimelineBandSegment>(
        layout.eonSegments,
        layout.eraSegments,
        eraHeights,
        (parent) => parent.startMa,
        (parent) => parent.endMa,
        (parent) => parent.id,
        (child) => child.startMa,
        (child) => child.endMa,
        (child) => child.id,
        (child) => child.isGap,
      );
  return _MinHeightMaps(
    stageHeights: stageHeights,
    epochHeights: epochHeights,
    periodHeights: periodHeights,
    eraHeights: eraHeights,
    eonHeights: eonHeights,
  );
}

List<double> _computeProportionalHeights<T>(
  List<T> segments, {
  required double height,
  required double unitsTotal,
  required double Function(T segment) unitSpan,
}) {
  final heights = <double>[];
  for (final segment in segments) {
    heights.add(height * (unitSpan(segment) / unitsTotal));
  }
  return heights;
}

List<double> _computeHeightsWithMinimums<T>(
  List<T> segments, {
  required double height,
  required double unitsTotal,
  required List<double> minHeights,
  required double Function(T segment) unitSpan,
}) {
  if (segments.isEmpty || height <= 0 || unitsTotal <= 0) {
    return List<double>.filled(segments.length, 0.0);
  }
  final heights = List<double>.filled(segments.length, 0.0);
  final remaining = List<int>.generate(segments.length, (i) => i);
  var remainingHeight = height;
  var remainingUnits = unitsTotal;

  while (true) {
    var changed = false;
    for (var i = 0; i < remaining.length; i++) {
      final index = remaining[i];
      final segment = segments[index];
      final proportional =
          remainingHeight * (unitSpan(segment) / remainingUnits);
      if (proportional + 0.5 < minHeights[index]) {
        heights[index] = minHeights[index];
        remainingHeight -= heights[index];
        remainingUnits -= unitSpan(segment);
        remaining.removeAt(i);
        i -= 1;
        changed = true;
        if (remainingHeight <= 0 || remainingUnits <= 0) {
          break;
        }
      }
    }
    if (!changed || remainingHeight <= 0 || remainingUnits <= 0) {
      break;
    }
  }

  if (remainingHeight <= 0 || remainingUnits <= 0) {
    for (final index in remaining) {
      heights[index] = 0.0;
    }
    return heights;
  }

  for (final index in remaining) {
    final segment = segments[index];
    heights[index] = remainingHeight * (unitSpan(segment) / remainingUnits);
  }
  return heights;
}
