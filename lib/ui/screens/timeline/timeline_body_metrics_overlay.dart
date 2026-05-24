import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';
import 'package:deep_time/ui/screens/timeline/timeline_orientation.dart';

extension TimelineBodyMetricsOverlay on TimelineBodyMetrics {
  TimelineRowSegment? rowSegmentAtY(
    List<TimelineRowSegment> segments,
    double totalUnits,
    double y,
  ) {
    if (segments.isEmpty || totalUnits <= 0 || scrollHeight <= 0) {
      return null;
    }
    final unitPos = (y / scrollHeight) * totalUnits;
    var cursor = 0.0;
    for (final segment in segments) {
      cursor += segment.unitSpan;
      if (unitPos <= cursor) {
        return segment;
      }
    }
    return segments.last;
  }

  TimelineBandSegment? bandSegmentAtY(
    List<TimelineBandSegment> segments,
    double totalUnits,
    double y,
  ) {
    if (segments.isEmpty || totalUnits <= 0 || scrollHeight <= 0) {
      return null;
    }
    final unitPos = (y / scrollHeight) * totalUnits;
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

  bool hasRowContentAtY(
    List<TimelineRowSegment> segments,
    double totalUnits,
    double y,
  ) {
    return rowHasContent(rowSegmentAtY(segments, totalUnits, y));
  }

  bool hasBandContentAtY(
    List<TimelineBandSegment> segments,
    double totalUnits,
    double y,
  ) {
    return bandHasContent(bandSegmentAtY(segments, totalUnits, y));
  }

  double _columnRight(TimelineTrack track) {
    return trackX(track) + trackWidth(track);
  }

  double eonOverlayRight(double y) {
    final hasEra = hasBandContentAtY(layout.eraSegments, eraTotalUnits, y);
    if (!hasEra) {
      return _columnRight(TimelineTrack.eon);
    }
    final hasPeriod = hasRowContentAtY(layout.periodSegments, periodUnits, y);
    if (!hasPeriod) {
      return _columnRight(TimelineTrack.era);
    }
    final hasEpoch = hasRowContentAtY(layout.epochSegments, epochTotalUnits, y);
    if (!hasEpoch) {
      return _columnRight(TimelineTrack.period);
    }
    final hasStage = hasRowContentAtY(layout.stageSegments, stageTotalUnits, y);
    if (!hasStage) {
      return _columnRight(TimelineTrack.epoch);
    }
    final hasRlife = hasRowContentAtY(layout.rlifeSegments, rlifeTotalUnits, y);
    if (!hasRlife) {
      return _columnRight(TimelineTrack.stage);
    }
    return _columnRight(TimelineTrack.rlife);
  }

  double eraOverlayRight(double y) {
    final hasPeriod = hasRowContentAtY(layout.periodSegments, periodUnits, y);
    if (!hasPeriod) {
      return _columnRight(TimelineTrack.era);
    }
    final hasEpoch = hasRowContentAtY(layout.epochSegments, epochTotalUnits, y);
    if (!hasEpoch) {
      return _columnRight(TimelineTrack.period);
    }
    final hasStage = hasRowContentAtY(layout.stageSegments, stageTotalUnits, y);
    if (!hasStage) {
      return _columnRight(TimelineTrack.epoch);
    }
    final hasRlife = hasRowContentAtY(layout.rlifeSegments, rlifeTotalUnits, y);
    if (!hasRlife) {
      return _columnRight(TimelineTrack.stage);
    }
    return _columnRight(TimelineTrack.rlife);
  }

  double periodOverlayRight(double y) {
    final hasEpoch = hasRowContentAtY(layout.epochSegments, epochTotalUnits, y);
    if (!hasEpoch) {
      return _columnRight(TimelineTrack.period);
    }
    final hasStage = hasRowContentAtY(layout.stageSegments, stageTotalUnits, y);
    if (!hasStage) {
      return _columnRight(TimelineTrack.epoch);
    }
    final hasRlife = hasRowContentAtY(layout.rlifeSegments, rlifeTotalUnits, y);
    if (!hasRlife) {
      return _columnRight(TimelineTrack.stage);
    }
    return _columnRight(TimelineTrack.rlife);
  }
}
