import 'package:flutter/widgets.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';

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

Map<int, double> buildStageMinHeights(
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

Map<int, double> buildEpochHeights(
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

Map<int, double> buildPeriodHeights(
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

Map<int, double> buildEraHeights(
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

Map<int, double> buildEonHeights(
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
