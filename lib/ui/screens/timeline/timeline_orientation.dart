import 'package:flutter/foundation.dart';

enum TimelineTrack {
  ma,
  eon,
  era,
  period,
  epoch,
  stage,
  paleoEcology,
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
  TimelineTrack.paleoEcology,
  TimelineTrack.rlife,
  TimelineTrack.extinctions,
  TimelineTrack.events,
  TimelineTrack.clades,
];

const double kTimelineStandardInterColumnGap = 10.0;

double trailingGapForTrack(TimelineTrack track, {required bool isLastVisible}) {
  if (isLastVisible) {
    return 0.0;
  }
  switch (track) {
    case TimelineTrack.eon:
    case TimelineTrack.era:
    case TimelineTrack.period:
    case TimelineTrack.epoch:
      return 0.0;
    case TimelineTrack.ma:
      return 0.0;
    case TimelineTrack.stage:
    case TimelineTrack.continents:
    case TimelineTrack.paleoEcology:
      return kTimelineStandardInterColumnGap;
    case TimelineTrack.rlife:
    case TimelineTrack.extinctions:
    case TimelineTrack.events:
    case TimelineTrack.clades:
      return 0.0;
  }
}

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
