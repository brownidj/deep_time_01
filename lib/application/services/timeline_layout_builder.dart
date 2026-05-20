import 'package:gts_01/application/services/timeline_layout_models.dart';
import 'package:gts_01/application/services/timeline_layout_rlife.dart';
import 'package:gts_01/application/services/timeline_layout_rows.dart';
import 'package:gts_01/application/services/timeline_layout_slots.dart';
import 'package:gts_01/domain/models/geologic_division.dart';
import 'package:gts_01/domain/models/geologic_rank.dart';

class TimelineLayoutBuilder {
  TimelineLayoutSnapshot build(List<GeologicDivision> divisions) {
    if (divisions.isEmpty) {
      return const TimelineLayoutSnapshot(
        eonSegments: [],
        eraSegments: [],
        periodSegments: [],
        epochSegments: [],
        stageSegments: [],
        rlifeSegments: [],
        oldestMa: 0,
        youngestMa: 0,
      );
    }

    final divisionById = {
      for (final division in divisions) division.id: division,
    };
    final childrenByParentId = <int, List<GeologicDivision>>{};
    for (final division in divisions) {
      final parentId = division.parentId;
      if (parentId == null) {
        continue;
      }
      childrenByParentId.putIfAbsent(parentId, () => []).add(division);
    }

    final eons =
        divisions
            .where((division) => division.rank == GeologicRank.eon)
            .toList()
          ..sort((a, b) => b.startMa.compareTo(a.startMa));
    if (eons.isEmpty) {
      return const TimelineLayoutSnapshot(
        eonSegments: [],
        eraSegments: [],
        periodSegments: [],
        epochSegments: [],
        stageSegments: [],
        rlifeSegments: [],
        oldestMa: 0,
        youngestMa: 0,
      );
    }

    final oldestMa = eons.first.startMa;
    final youngestMa = eons.last.endMa;

    final slotBuilder = TimelineSlotBuilder();
    final slots = slotBuilder.buildSlots(eons, childrenByParentId);
    final rowBuilder = TimelineRowBuilder(divisionById: divisionById);
    final rlifeBuilder = TimelineRLifeBuilder(divisionById: divisionById);

    return TimelineLayoutSnapshot(
      eonSegments: rowBuilder.buildBandRow(
        slots,
        rank: GeologicRank.eon,
      ),
      eraSegments: rowBuilder.buildBandRow(
        slots,
        rank: GeologicRank.era,
      ),
      periodSegments: rowBuilder.buildRankRow(
        slots,
        rank: GeologicRank.period,
      ),
      epochSegments: rowBuilder.buildRankRow(
        slots,
        rank: GeologicRank.epoch,
      ),
      stageSegments: rowBuilder.buildStageRow(slots),
      rlifeSegments: rlifeBuilder.buildRLifeRow(slots),
      oldestMa: oldestMa,
      youngestMa: youngestMa,
    );
  }
}
