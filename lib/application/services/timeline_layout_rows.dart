import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/application/services/timeline_layout_color_keys.dart';
import 'package:deep_time/application/services/timeline_layout_slots.dart';
import 'package:deep_time/domain/models/geologic_division.dart';
import 'package:deep_time/domain/models/geologic_rank.dart';

class TimelineRowBuilder {
  TimelineRowBuilder({required this.divisionById});

  final Map<int, GeologicDivision> divisionById;

  List<TimelineBandSegment> buildBandRow(
    List<TimelineSlot> slots, {
    required GeologicRank rank,
  }) {
    final segments = <TimelineBandSegment>[];
    GeologicDivision? current;
    var span = 0.0;
    for (final slot in slots) {
      final division = slot.divisionFor(rank);
      if (division?.id != current?.id) {
        if (span > 0) {
          segments.add(_bandFromDivision(current, span, rank));
        }
        current = division;
        span = slot.weight;
      } else {
        span += slot.weight;
      }
    }
    if (span > 0) {
      segments.add(_bandFromDivision(current, span, rank));
    }
    return segments;
  }

  List<TimelineRowSegment> buildRankRow(
    List<TimelineSlot> slots, {
    required GeologicRank rank,
  }) {
    final segments = <TimelineRowSegment>[];
    GeologicDivision? current;
    var span = 0.0;
    for (final slot in slots) {
      final division = slot.divisionFor(rank);
      if (division?.id != current?.id) {
        if (span > 0) {
          segments.add(_rowFromDivision(current, span, rank));
        }
        current = division;
        span = slot.weight;
      } else {
        span += slot.weight;
      }
    }
    if (span > 0) {
      segments.add(_rowFromDivision(current, span, rank));
    }
    return segments;
  }

  List<TimelineRowSegment> buildStageRow(List<TimelineSlot> slots) {
    final segments = <TimelineRowSegment>[];
    var index = 0;
    while (index < slots.length) {
      final currentEon = slots[index].eon;
      final eonSlots = <TimelineSlot>[];
      while (index < slots.length && slots[index].eon.id == currentEon.id) {
        eonSlots.add(slots[index]);
        index += 1;
      }

      final hasEpochs = eonSlots.any((slot) => slot.epoch != null);
      if (!hasEpochs) {
        final totalWeight = eonSlots.fold<double>(
          0.0,
          (sum, slot) => sum + slot.weight,
        );
        segments.add(_rowFromDivision(null, totalWeight, GeologicRank.stage));
        continue;
      }

      for (final slot in eonSlots) {
        final epoch = slot.epoch;
        if (epoch == null) {
          segments.add(_rowFromDivision(null, slot.weight, GeologicRank.stage));
          continue;
        }
        final stages = slot.stages;
        if (stages.isEmpty) {
          segments.add(_rowFromDivision(null, slot.weight, GeologicRank.stage));
          continue;
        }
        final span = slot.weight / stages.length;
        for (final stage in stages) {
          segments.add(
            TimelineRowSegment(
              id: stage.id,
              label: stage.name,
              rank: stage.rank,
              startMa: stage.startMa,
              endMa: stage.endMa,
              colorKey: colorKeyForDivision(stage, divisionById),
              isGap: false,
              unitSpan: span,
              secondaryLabel: null,
              explanation: stage.explanation,
            ),
          );
        }
      }
    }
    return segments;
  }

  TimelineBandSegment _bandFromDivision(
    GeologicDivision? division,
    double unitSpan,
    GeologicRank rank,
  ) {
    if (division == null) {
      return TimelineBandSegment(
        id: -1,
        label: '',
        rank: rank,
        startMa: 0,
        endMa: 0,
        colorKey: '',
        isGap: true,
        unitSpan: unitSpan,
        explanation: null,
      );
    }
    return TimelineBandSegment(
      id: division.id,
      label: division.name,
      rank: division.rank,
      startMa: division.startMa,
      endMa: division.endMa,
      colorKey: colorKeyForDivision(division, divisionById),
      isGap: false,
      unitSpan: unitSpan,
      explanation: division.explanation,
    );
  }

  TimelineRowSegment _rowFromDivision(
    GeologicDivision? division,
    double unitSpan,
    GeologicRank rank,
  ) {
    if (division == null) {
      return TimelineRowSegment(
        id: -1,
        label: '',
        rank: rank,
        startMa: 0,
        endMa: 0,
        colorKey: '',
        isGap: true,
        unitSpan: unitSpan,
        secondaryLabel: null,
        explanation: null,
      );
    }
    return TimelineRowSegment(
      id: division.id,
      label: division.name,
      rank: division.rank,
      startMa: division.startMa,
      endMa: division.endMa,
      colorKey: colorKeyForDivision(division, divisionById),
      isGap: false,
      unitSpan: unitSpan,
      secondaryLabel: null,
      explanation: division.explanation,
    );
  }
}
