import 'package:flutter/foundation.dart';

enum TimelineTrack {
  eon,
  era,
  period,
  epoch,
  stage,
  rlife,
  events,
  extinctions,
  clades,
}

const List<TimelineTrack> kDefaultTimelineTrackOrder = <TimelineTrack>[
  TimelineTrack.eon,
  TimelineTrack.era,
  TimelineTrack.period,
  TimelineTrack.epoch,
  TimelineTrack.stage,
  TimelineTrack.rlife,
  TimelineTrack.events,
  TimelineTrack.extinctions,
  TimelineTrack.clades,
];

@immutable
class TimelineOrientationConfig {
  const TimelineOrientationConfig({
    this.trackWidths = const <TimelineTrack, double>{},
    this.defaultTrackWidth = 112.0,
    this.verticalHeaderHeight = 44.0,
    this.minUnitHeight = 96.0,
  });

  final Map<TimelineTrack, double> trackWidths;
  final double defaultTrackWidth;
  final double verticalHeaderHeight;
  final double minUnitHeight;

  double trackWidthFor(TimelineTrack track) {
    return trackWidths[track] ?? defaultTrackWidth;
  }
}

const TimelineOrientationConfig kDefaultTimelineOrientation =
    TimelineOrientationConfig();
