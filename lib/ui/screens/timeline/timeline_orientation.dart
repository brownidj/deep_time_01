import 'package:flutter/foundation.dart';

enum TimelineTrack {
  ma,
  eon,
  era,
  period,
  epoch,
  stage,
  rlife,
  extinctions,
  continents,
  events,
  clades,
}

const List<TimelineTrack> kDefaultTimelineTrackOrder = <TimelineTrack>[
  TimelineTrack.ma,
  TimelineTrack.eon,
  TimelineTrack.era,
  TimelineTrack.period,
  TimelineTrack.epoch,
  TimelineTrack.stage,
  TimelineTrack.continents,
  TimelineTrack.rlife,
  TimelineTrack.extinctions,
  TimelineTrack.events,
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
