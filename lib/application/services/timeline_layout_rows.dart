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
    var currentStartMa = 0.0;
    var currentEndMa = 0.0;
    var span = 0.0;
    for (final slot in slots) {
      final division = slot.divisionFor(rank);
      final slotRange = _slotRangeForRank(slot, rank);
      if (division?.id != current?.id) {
        if (span > 0) {
          segments.add(
            _bandFromDivision(
              current,
              span,
              rank,
              startMa: currentStartMa,
              endMa: currentEndMa,
            ),
          );
        }
        current = division;
        currentStartMa = division?.startMa ?? slotRange.startMa;
        currentEndMa = division?.endMa ?? slotRange.endMa;
        span = slot.weight;
      } else {
        span += slot.weight;
      }
    }
    if (span > 0) {
      segments.add(
        _bandFromDivision(
          current,
          span,
          rank,
          startMa: currentStartMa,
          endMa: currentEndMa,
        ),
      );
    }
    return segments;
  }

  List<TimelineRowSegment> buildRankRow(
    List<TimelineSlot> slots, {
    required GeologicRank rank,
  }) {
    final segments = <TimelineRowSegment>[];
    GeologicDivision? current;
    int? currentGapKey;
    var currentStartMa = 0.0;
    var currentEndMa = 0.0;
    var span = 0.0;
    for (final slot in slots) {
      final division = slot.divisionFor(rank);
      final slotRange = _slotRangeForRank(slot, rank);
      final slotSpan = _slotSpanForRank(slot, rank);
      final gapKey = division == null ? _gapKeyForRank(slot, rank) : null;
      final shouldBreak =
          division?.id != current?.id ||
          (division == null && current == null && gapKey != currentGapKey);
      if (shouldBreak) {
        if (span > 0) {
          segments.add(
            _rowFromDivision(
              current,
              span,
              rank,
              startMa: currentStartMa,
              endMa: currentEndMa,
            ),
          );
        }
        current = division;
        currentGapKey = gapKey;
        currentStartMa = division?.startMa ?? slotRange.startMa;
        currentEndMa = division?.endMa ?? slotRange.endMa;
        span = slotSpan;
      } else {
        span += slotSpan;
      }
    }
    if (span > 0) {
      segments.add(
        _rowFromDivision(
          current,
          span,
          rank,
          startMa: currentStartMa,
          endMa: currentEndMa,
        ),
      );
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
          (sum, slot) => sum + _slotSpanForRank(slot, GeologicRank.stage),
        );
        segments.add(
          _rowFromDivision(
            null,
            totalWeight,
            GeologicRank.stage,
            startMa: currentEon.startMa,
            endMa: currentEon.endMa,
          ),
        );
        continue;
      }

      for (final slot in eonSlots) {
        final slotRange = _slotRangeForRank(slot, GeologicRank.stage);
        final epoch = slot.epoch;
        if (epoch == null) {
          segments.add(
            _rowFromDivision(
              null,
              _slotSpanForRank(slot, GeologicRank.stage),
              GeologicRank.stage,
              startMa: slotRange.startMa,
              endMa: slotRange.endMa,
            ),
          );
          continue;
        }
        final stages = slot.stages;
        if (stages.isEmpty) {
          segments.add(
            _rowFromDivision(
              null,
              _slotSpanForRank(slot, GeologicRank.stage),
              GeologicRank.stage,
              startMa: slotRange.startMa,
              endMa: slotRange.endMa,
            ),
          );
          continue;
        }
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
              unitSpan: 1.0,
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
    GeologicRank rank, {
    required double startMa,
    required double endMa,
  }
  ) {
    if (division == null) {
      return TimelineBandSegment(
        id: -1,
        label: '',
        rank: rank,
        startMa: startMa,
        endMa: endMa,
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
    GeologicRank rank, {
    required double startMa,
    required double endMa,
  }
  ) {
    if (division == null) {
      return TimelineRowSegment(
        id: -1,
        label: '',
        rank: rank,
        startMa: startMa,
        endMa: endMa,
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

  double _slotSpanForRank(TimelineSlot slot, GeologicRank rank) {
    switch (rank) {
      case GeologicRank.period:
        final hasEpochOrStage = slot.epoch != null || slot.stages.isNotEmpty;
        if (!hasEpochOrStage) {
          return slot.weight;
        }
        final periodCount = slot.stages.length;
        return periodCount > 0 ? periodCount.toDouble() : 1.0;
      case GeologicRank.epoch:
      case GeologicRank.stage:
        final count = slot.stages.length;
        return count > 0 ? count.toDouble() : 1.0;
      case GeologicRank.eon:
      case GeologicRank.era:
      case GeologicRank.age:
        return slot.weight;
    }
  }

  GeologicDivision _slotRangeForRank(TimelineSlot slot, GeologicRank rank) {
    switch (rank) {
      case GeologicRank.eon:
        return slot.eon;
      case GeologicRank.era:
        return slot.era ?? slot.eon;
      case GeologicRank.period:
        return slot.period ?? slot.era ?? slot.eon;
      case GeologicRank.epoch:
        return slot.epoch ?? slot.period ?? slot.era ?? slot.eon;
      case GeologicRank.stage:
        return slot.epoch ?? slot.period ?? slot.era ?? slot.eon;
      case GeologicRank.age:
        return slot.eon;
    }
  }

  int _gapKeyForRank(TimelineSlot slot, GeologicRank rank) {
    switch (rank) {
      case GeologicRank.period:
        return slot.era?.id ?? slot.eon.id;
      case GeologicRank.epoch:
        return slot.period?.id ?? slot.era?.id ?? slot.eon.id;
      case GeologicRank.stage:
        return slot.epoch?.id ?? slot.period?.id ?? slot.era?.id ?? slot.eon.id;
      case GeologicRank.eon:
      case GeologicRank.era:
      case GeologicRank.age:
        return slot.eon.id;
    }
  }
}
