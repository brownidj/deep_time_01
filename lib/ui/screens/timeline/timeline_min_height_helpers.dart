import 'package:flutter/widgets.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';

class MinHeightMaps {
  const MinHeightMaps({
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

double minHeightForStageLabel(
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

double minHeightForVerticalLabel(
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

double minHeightForVerticalBandLabel(
  TimelineBandSegment segment,
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

double minHeightFromParentRange<T>(
  double startMa,
  double endMa,
  List<T> parents,
  Map<int, double> parentHeights,
  double Function(T parent) parentStart,
  double Function(T parent) parentEnd,
  int Function(T parent) parentId,
) {
  for (final parent in parents) {
    if (startMa <= parentStart(parent) && endMa >= parentEnd(parent)) {
      return parentHeights[parentId(parent)] ?? 0.0;
    }
  }
  return 0.0;
}

Map<int, double> _buildStageMinHeights(
  List<TimelineRowSegment> stages,
  TextStyle? style, {
  double verticalPadding = 4,
}) {
  return {
    for (final segment in stages)
      segment.id: minHeightForStageLabel(
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

Map<int, double> _buildEpochHeights(
  List<TimelineRowSegment> epochs,
  List<TimelineRowSegment> stages,
  Map<int, double> stageHeights,
  TextStyle? epochStyle, {
  double verticalPadding = 4,
}) {
  final result = <int, double>{};
  for (final epoch in epochs) {
    var sum = 0.0;
    var hasStages = false;
    for (final stage in stages) {
      if (stage.isGap) {
        continue;
      }
      if (stage.startMa <= epoch.startMa && stage.endMa >= epoch.endMa) {
        hasStages = true;
        sum += stageHeights[stage.id] ?? 0.0;
      }
    }
    if (!hasStages) {
      sum = minHeightForStageLabel(
        epoch,
        epochStyle,
        verticalPadding: verticalPadding,
      );
    }
    result[epoch.id] = sum;
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
      sum = minHeightForVerticalLabel(
        period,
        periodStyle,
        verticalPadding: verticalPadding,
      );
    }
    result[period.id] = sum;
  }
  return result;
}

Map<int, double> _buildEraHeights(
  List<TimelineBandSegment> eras,
  List<TimelineRowSegment> periods,
  Map<int, double> periodHeights,
  TextStyle? eraStyle, {
  double verticalPadding = 4,
}) {
  final result = <int, double>{};
  for (final era in eras) {
    var sum = 0.0;
    var hasPeriods = false;
    for (final period in periods) {
      if (period.isGap) {
        continue;
      }
      if (period.startMa <= era.startMa && period.endMa >= era.endMa) {
        hasPeriods = true;
        sum += periodHeights[period.id] ?? 0.0;
      }
    }
    if (!hasPeriods) {
      sum = minHeightForVerticalBandLabel(
        era,
        eraStyle,
        verticalPadding: verticalPadding,
      );
    }
    result[era.id] = sum;
  }
  return result;
}

Map<int, double> _buildEonHeights(
  List<TimelineBandSegment> eons,
  List<TimelineBandSegment> eras,
  Map<int, double> eraHeights,
  TextStyle? eonStyle, {
  double verticalPadding = 4,
}) {
  final result = <int, double>{};
  for (final eon in eons) {
    var sum = 0.0;
    var hasEras = false;
    for (final era in eras) {
      if (era.isGap) {
        continue;
      }
      if (era.startMa <= eon.startMa && era.endMa >= eon.endMa) {
        hasEras = true;
        sum += eraHeights[era.id] ?? 0.0;
      }
    }
    if (!hasEras) {
      sum = minHeightForVerticalBandLabel(
        eon,
        eonStyle,
        verticalPadding: verticalPadding,
      );
    }
    result[eon.id] = sum;
  }
  return result;
}

MinHeightMaps buildMinHeightMaps(
  TimelineLayoutSnapshot layout,
  TextStyle? stageStyle, {
  TextStyle? epochStyle,
  TextStyle? periodStyle,
  TextStyle? eraStyle,
  TextStyle? eonStyle,
  double verticalPadding = 4,
}) {
  final stageHeights = _buildStageMinHeights(
    layout.stageSegments,
    stageStyle,
    verticalPadding: verticalPadding,
  );
  final epochHeights = _buildEpochHeights(
    layout.epochSegments,
    layout.stageSegments,
    stageHeights,
    epochStyle ?? stageStyle,
    verticalPadding: verticalPadding,
  );
  final periodHeights = _buildPeriodHeights(
    layout.periodSegments,
    layout.epochSegments,
    epochHeights,
    periodStyle,
    verticalPadding: verticalPadding,
  );
  final eraHeights = _buildEraHeights(
    layout.eraSegments,
    layout.periodSegments,
    periodHeights,
    eraStyle ?? periodStyle ?? stageStyle,
    verticalPadding: verticalPadding,
  );
  final eonHeights = _buildEonHeights(
    layout.eonSegments,
    layout.eraSegments,
    eraHeights,
    eonStyle ?? eraStyle ?? periodStyle ?? stageStyle,
    verticalPadding: verticalPadding,
  );
  return MinHeightMaps(
    stageHeights: stageHeights,
    epochHeights: epochHeights,
    periodHeights: periodHeights,
    eraHeights: eraHeights,
    eonHeights: eonHeights,
  );
}

List<double> boundaryPositionsWithMinimums<T>(
  List<T> segments, {
  required double height,
  required double unitsTotal,
  required List<double> minHeights,
  required double Function(T segment) unitSpan,
}) {
  if (segments.isEmpty || unitsTotal <= 0 || height <= 0) {
    return const [];
  }
  final heights = _computeHeightsWithMinimums(
    segments,
    height: height,
    unitsTotal: unitsTotal,
    minHeights: minHeights,
    unitSpan: unitSpan,
  );
  final positions = <double>[];
  var cursor = 0.0;
  for (var i = 0; i < segments.length - 1; i++) {
    cursor += heights[i];
    positions.add(cursor);
  }
  return positions;
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
