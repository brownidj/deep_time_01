import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';

extension TimelineBodyMetricsOverlay on TimelineBodyMetrics {
  TimelineRowSegment? rowSegmentAtX(
    List<TimelineRowSegment> segments,
    double totalUnits,
    double x,
  ) {
    if (segments.isEmpty || totalUnits <= 0) {
      return null;
    }
    final unitPos = (x / scrollWidth) * totalUnits;
    var cursor = 0.0;
    for (final segment in segments) {
      cursor += segment.unitSpan;
      if (unitPos <= cursor) {
        return segment;
      }
    }
    return segments.last;
  }

  TimelineBandSegment? bandSegmentAtX(
    List<TimelineBandSegment> segments,
    double totalUnits,
    double x,
  ) {
    if (segments.isEmpty || totalUnits <= 0) {
      return null;
    }
    final unitPos = (x / scrollWidth) * totalUnits;
    var cursor = 0.0;
    for (final segment in segments) {
      cursor += segment.unitSpan;
      if (unitPos <= cursor) {
        return segment;
      }
    }
    return segments.last;
  }

  bool rowHasContent(TimelineRowSegment? segment) {
    if (segment == null) {
      return false;
    }
    return !segment.isGap &&
        segment.label.trim().isNotEmpty &&
        segment.colorKey.trim().isNotEmpty;
  }

  bool bandHasContent(TimelineBandSegment? segment) {
    if (segment == null) {
      return false;
    }
    return !segment.isGap &&
        segment.label.trim().isNotEmpty &&
        segment.colorKey.trim().isNotEmpty;
  }

  bool hasRowContentAtX(
    List<TimelineRowSegment> segments,
    double totalUnits,
    double x,
  ) {
    return rowHasContent(rowSegmentAtX(segments, totalUnits, x));
  }

  bool hasBandContentAtX(
    List<TimelineBandSegment> segments,
    double totalUnits,
    double x,
  ) {
    return bandHasContent(bandSegmentAtX(segments, totalUnits, x));
  }

  double eonOverlayBottom(double x) {
    final hasEra = hasBandContentAtX(layout.eraSegments, eraTotalUnits, x);
    if (!hasEra) {
      return eonHeight;
    }
    final hasPeriod = hasRowContentAtX(layout.periodSegments, periodUnits, x);
    if (!hasPeriod) {
      return eonHeight + eraHeight;
    }
    final hasEpoch = hasRowContentAtX(layout.epochSegments, epochTotalUnits, x);
    if (!hasEpoch) {
      return eonHeight + eraHeight + subRowHeight;
    }
    final hasStage = hasRowContentAtX(layout.stageSegments, stageTotalUnits, x);
    if (!hasStage) {
      return eonHeight + eraHeight + subRowHeight + subRowHeight;
    }
    final hasRlife = hasRowContentAtX(layout.rlifeSegments, rlifeTotalUnits, x);
    if (!hasRlife) {
      return eonHeight +
          eraHeight +
          subRowHeight +
          subRowHeight +
          stageRowHeight;
    }
    return rlifeBottom;
  }

  double eraOverlayBottom(double x) {
    final hasPeriod = hasRowContentAtX(layout.periodSegments, periodUnits, x);
    if (!hasPeriod) {
      return eonHeight + eraHeight;
    }
    final hasEpoch = hasRowContentAtX(layout.epochSegments, epochTotalUnits, x);
    if (!hasEpoch) {
      return eonHeight + eraHeight + subRowHeight;
    }
    final hasStage = hasRowContentAtX(layout.stageSegments, stageTotalUnits, x);
    if (!hasStage) {
      return eonHeight + eraHeight + subRowHeight + subRowHeight;
    }
    final hasRlife = hasRowContentAtX(layout.rlifeSegments, rlifeTotalUnits, x);
    if (!hasRlife) {
      return eonHeight +
          eraHeight +
          subRowHeight +
          subRowHeight +
          stageRowHeight;
    }
    return rlifeBottom;
  }

  double periodOverlayBottom(double x) {
    final hasEpoch = hasRowContentAtX(layout.epochSegments, epochTotalUnits, x);
    if (!hasEpoch) {
      return eonHeight + eraHeight + subRowHeight;
    }
    final hasStage = hasRowContentAtX(layout.stageSegments, stageTotalUnits, x);
    if (!hasStage) {
      return eonHeight + eraHeight + subRowHeight + subRowHeight;
    }
    final hasRlife = hasRowContentAtX(layout.rlifeSegments, rlifeTotalUnits, x);
    if (!hasRlife) {
      return eonHeight +
          eraHeight +
          subRowHeight +
          subRowHeight +
          stageRowHeight;
    }
    return rlifeBottom;
  }
}
