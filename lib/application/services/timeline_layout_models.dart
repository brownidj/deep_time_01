import 'package:gts_01/domain/models/geologic_rank.dart';

class TimelineBandSegment {
  const TimelineBandSegment({
    required this.label,
    required this.rank,
    required this.startMa,
    required this.endMa,
    required this.colorKey,
    required this.isGap,
    required this.unitSpan,
  });

  final String label;
  final GeologicRank rank;
  final double startMa;
  final double endMa;
  final String colorKey;
  final bool isGap;
  final double unitSpan;

  double get durationMa => startMa - endMa;
}

class TimelineRowSegment {
  const TimelineRowSegment({
    required this.id,
    required this.label,
    required this.rank,
    required this.startMa,
    required this.endMa,
    required this.colorKey,
    required this.isGap,
    required this.unitSpan,
    this.secondaryLabel,
  });

  final int id;
  final String label;
  final GeologicRank rank;
  final double startMa;
  final double endMa;
  final String colorKey;
  final bool isGap;
  final double unitSpan;
  final String? secondaryLabel;

  double get durationMa => startMa - endMa;
}

class TimelineLayoutSnapshot {
  const TimelineLayoutSnapshot({
    required this.eonSegments,
    required this.eraSegments,
    required this.periodSegments,
    required this.epochSegments,
    required this.stageSegments,
    required this.rlifeSegments,
    required this.oldestMa,
    required this.youngestMa,
  });

  final List<TimelineBandSegment> eonSegments;
  final List<TimelineBandSegment> eraSegments;
  final List<TimelineRowSegment> periodSegments;
  final List<TimelineRowSegment> epochSegments;
  final List<TimelineRowSegment> stageSegments;
  final List<TimelineRowSegment> rlifeSegments;
  final double oldestMa;
  final double youngestMa;

  TimelineRowSegments get rowSegments => TimelineRowSegments(
    periods: periodSegments,
    epochs: epochSegments,
    stages: stageSegments,
  );
}

class TimelineRowSegments {
  const TimelineRowSegments({
    required this.periods,
    required this.epochs,
    required this.stages,
  });

  final List<TimelineRowSegment> periods;
  final List<TimelineRowSegment> epochs;
  final List<TimelineRowSegment> stages;

  List<TimelineRowSegment> forRank(GeologicRank rank) {
    switch (rank) {
      case GeologicRank.period:
        return periods;
      case GeologicRank.epoch:
        return epochs;
      case GeologicRank.stage:
        return stages;
      case GeologicRank.eon:
      case GeologicRank.era:
      case GeologicRank.age:
        return const [];
    }
  }

  List<TimelineRowSegment> operator [](GeologicRank rank) => forRank(rank);
}
