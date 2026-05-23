import 'package:deep_time/application/services/timeline_layout_events.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/application/services/timeline_layout_rlife.dart';
import 'package:deep_time/application/services/timeline_layout_rows.dart';
import 'package:deep_time/application/services/timeline_layout_slots.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/domain/models/geologic_division.dart';
import 'package:deep_time/domain/models/geologic_rank.dart';

class TimelineLayoutBuilder {
  TimelineLayoutSnapshot build(
    List<GeologicDivision> divisions,
    TimelineMarkerCatalog markers,
  ) {
    if (divisions.isEmpty) {
      return const TimelineLayoutSnapshot(
        eonSegments: [],
        eraSegments: [],
        periodSegments: [],
        epochSegments: [],
        stageSegments: [],
        rlifeSegments: [],
        eventSegments: [],
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
        eventSegments: [],
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
    final eventsBuilder = TimelineEventsBuilder(definitions: markers.events);

    final eonSegments = rowBuilder.buildBandRow(slots, rank: GeologicRank.eon);
    final eraSegments = rowBuilder.buildBandRow(slots, rank: GeologicRank.era);
    final periodSegments = rowBuilder.buildRankRow(
      slots,
      rank: GeologicRank.period,
    );
    final epochSegments = rowBuilder.buildRankRow(
      slots,
      rank: GeologicRank.epoch,
    );
    final stageSegments = rowBuilder.buildStageRow(slots);
    final rlifeSegments = rlifeBuilder.buildRLifeRow(slots);
    final eventSegments = eventsBuilder.buildEventsRow(
      periodSegments: periodSegments,
      eraSegments: eraSegments,
    );

    return TimelineLayoutSnapshot(
      eonSegments: eonSegments,
      eraSegments: eraSegments,
      periodSegments: periodSegments,
      epochSegments: epochSegments,
      stageSegments: stageSegments,
      rlifeSegments: rlifeSegments,
      eventSegments: eventSegments,
      oldestMa: oldestMa,
      youngestMa: youngestMa,
    );
  }
}
