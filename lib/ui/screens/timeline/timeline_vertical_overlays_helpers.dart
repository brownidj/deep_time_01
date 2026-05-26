import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';

List<double> eventPointYs(
  List<TimelineEventSegment> events,
  double totalUnits,
  double height,
) {
  if (events.isEmpty || totalUnits <= 0) {
    return const [];
  }
  final ys = <double>[];
  for (final event in events) {
    if (event.type != TimelineEventType.point) {
      continue;
    }
    final y = (event.startUnit / totalUnits * height).clamp(0.0, height);
    ys.add(y - 0.5);
  }
  return ys;
}

List<double> extinctionYs(
  List<ExtinctionDefinition> extinctions,
  List<TimelineRowSegment> periodSegments,
  List<TimelineRowSegment> stageSegments,
  double height,
) {
  final periodTotal = periodSegments.fold<double>(
    0.0,
    (sum, segment) => sum + segment.unitSpan,
  );
  final stageTotal = stageSegments.fold<double>(
    0.0,
    (sum, segment) => sum + segment.unitSpan,
  );
  if (periodTotal <= 0) {
    return const [];
  }

  double? boundaryForPeriod(String label) {
    var sum = 0.0;
    for (final segment in periodSegments) {
      sum += segment.unitSpan;
      if (!segment.isGap && segment.label == label) {
        return height * (sum / periodTotal);
      }
    }
    return null;
  }

  double? boundaryForStage(String label) {
    if (stageTotal <= 0) {
      return null;
    }
    var sum = 0.0;
    for (final segment in stageSegments) {
      sum += segment.unitSpan;
      if (!segment.isGap && segment.label == label) {
        return height * (sum / stageTotal);
      }
    }
    return null;
  }

  double? positionForMa(double ma) {
    var unitCursor = 0.0;
    for (final segment in periodSegments) {
      final unitEnd = unitCursor + segment.unitSpan;
      if (!segment.isGap && ma <= segment.startMa && ma >= segment.endMa) {
        final span = segment.startMa - segment.endMa;
        if (span <= 0) {
          return height * (unitCursor / periodTotal);
        }
        final fraction = (segment.startMa - ma) / span;
        final unitPos =
            unitCursor + (segment.unitSpan * fraction.clamp(0.0, 1.0));
        return height * (unitPos / periodTotal);
      }
      unitCursor = unitEnd;
    }
    if (periodSegments.isNotEmpty && ma >= periodSegments.first.startMa) {
      return 0;
    }
    return height;
  }

  final ys = <double>[];
  for (final extinction in extinctions) {
    double? y;
    switch (extinction.anchor.type) {
      case ExtinctionAnchorType.period:
        y = boundaryForPeriod(extinction.anchor.label ?? '');
        break;
      case ExtinctionAnchorType.stage:
        y = boundaryForStage(extinction.anchor.label ?? '');
        break;
      case ExtinctionAnchorType.ma:
        if (extinction.anchor.ma != null) {
          y = positionForMa(extinction.anchor.ma!);
        }
        break;
    }
    if (y != null) {
      ys.add(y - 0.5);
    }
  }
  return ys;
}
