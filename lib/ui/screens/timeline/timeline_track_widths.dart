import 'dart:math' as math;

import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';
import 'package:deep_time/ui/screens/timeline/timeline_orientation.dart';

const Set<TimelineTrack> kFixedTimelineTracks = {
  TimelineTrack.ma,
  TimelineTrack.eon,
  TimelineTrack.era,
  TimelineTrack.period,
  TimelineTrack.epoch,
  TimelineTrack.stage,
  TimelineTrack.paleoEcology,
  TimelineTrack.rlife,
  TimelineTrack.extinctions,
  TimelineTrack.continents,
  TimelineTrack.waterways,
};

Map<TimelineTrack, double> resolveTimelineTrackWidths({
  required TimelineBodyMetrics metrics,
  required double maxWidth,
}) {
  if (!maxWidth.isFinite || maxWidth <= 0 || metrics.trackColumnsWidth <= 0) {
    return {
      for (final track in metrics.trackOrder) track: metrics.trackWidth(track),
    };
  }

  var fixedWidth = 0.0;
  var flexibleBaseWidth = 0.0;
  for (final track in metrics.trackOrder) {
    fixedWidth += metrics.gapBefore(track) + metrics.gapAfter(track);
    if (kFixedTimelineTracks.contains(track)) {
      fixedWidth += metrics.trackWidth(track);
      continue;
    }
    if (track != TimelineTrack.events) {
      flexibleBaseWidth += metrics.trackWidth(track);
    }
  }

  final remainingAfterFixed = math.max(0.0, maxWidth - fixedWidth);
  final hasEvents = metrics.trackOrder.contains(TimelineTrack.events);
  final eventWidth = hasEvents
      ? math.min(metrics.trackWidth(TimelineTrack.events), remainingAfterFixed)
      : 0.0;
  final remainingForFlexible = math.max(0.0, remainingAfterFixed - eventWidth);
  final flexibleScale = flexibleBaseWidth <= 0
      ? 1.0
      : remainingForFlexible / flexibleBaseWidth;

  return {
    for (final track in metrics.trackOrder)
      track: kFixedTimelineTracks.contains(track)
          ? metrics.trackWidth(track)
          : track == TimelineTrack.events
          ? eventWidth
          : metrics.trackWidth(track) * flexibleScale,
  };
}
