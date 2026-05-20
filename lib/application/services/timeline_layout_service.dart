import 'package:gts_01/domain/models/geologic_division.dart';
import 'package:gts_01/domain/models/geologic_rank.dart';
import 'package:gts_01/domain/models/timeline_palette.dart';

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

class TimelineLayoutService {
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

    final slots = _buildSlots(
      eons,
      divisionById,
      childrenByParentId,
    );

    return TimelineLayoutSnapshot(
      eonSegments: _buildBandRow(
        slots,
        rank: GeologicRank.eon,
      ),
      eraSegments: _buildBandRow(
        slots,
        rank: GeologicRank.era,
      ),
      periodSegments: _buildRankRow(slots, rank: GeologicRank.period),
      epochSegments: _buildRankRow(slots, rank: GeologicRank.epoch),
      stageSegments: _buildStageRow(slots),
      rlifeSegments: _buildRLifeRow(slots),
      oldestMa: oldestMa,
      youngestMa: youngestMa,
    );
  }

  List<TimelineBandSegment> _buildBandRow(
    List<_Slot> slots, {
    required GeologicRank rank,
  }) {
    final segments = <TimelineBandSegment>[];
    GeologicDivision? current;
    var span = 0.0;
    for (final slot in slots) {
      final division = slot.divisionFor(rank);
      if (division?.id != current?.id) {
        if (span > 0) {
          segments.add(
            _bandFromDivision(current, span, rank),
          );
        }
        current = division;
        span = slot.weight;
      } else {
        span += slot.weight;
      }
    }
    if (span > 0) {
      segments.add(
        _bandFromDivision(current, span, rank),
      );
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
        label: '',
        rank: rank,
        startMa: 0,
        endMa: 0,
        colorKey: '',
        isGap: true,
        unitSpan: unitSpan,
      );
    }
    return TimelineBandSegment(
      label: division.name,
      rank: division.rank,
      startMa: division.startMa,
      endMa: division.endMa,
      colorKey: _colorKeyForDivision(division, _divisionById),
      isGap: false,
      unitSpan: unitSpan,
    );
  }

  List<TimelineRowSegment> _buildRankRow(
    List<_Slot> slots, {
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
      );
    }
    return TimelineRowSegment(
      id: division.id,
      label: division.name,
      rank: division.rank,
      startMa: division.startMa,
      endMa: division.endMa,
      colorKey: _colorKeyForDivision(division, _divisionById),
      isGap: false,
      unitSpan: unitSpan,
      secondaryLabel: null,
    );
  }

  List<TimelineRowSegment> _buildStageRow(List<_Slot> slots) {
    final segments = <TimelineRowSegment>[];
    var index = 0;
    while (index < slots.length) {
      final currentEon = slots[index].eon;
      final eonSlots = <_Slot>[];
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
        segments.add(
          _rowFromDivision(
            null,
            totalWeight,
            GeologicRank.stage,
          ),
        );
        continue;
      }

      for (final slot in eonSlots) {
        final epoch = slot.epoch;
        if (epoch == null) {
          segments.add(
            _rowFromDivision(null, slot.weight, GeologicRank.stage),
          );
          continue;
        }
        final stages = slot.stages;
        if (stages.isEmpty) {
          segments.add(
            _rowFromDivision(null, slot.weight, GeologicRank.stage),
          );
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
              colorKey: _colorKeyForDivision(stage, _divisionById),
              isGap: false,
              unitSpan: span,
              secondaryLabel: null,
            ),
          );
        }
      }
    }
    return segments;
  }

  List<TimelineRowSegment> _buildRLifeRow(List<_Slot> slots) {
    const rlifeData = {
      'Precambrian':
          'microbial mats, stromatolites, early eukaryotes, Ediacaran organisms',
      'Cambrian':
          'trilobites, archaeocyathids, early arthropods, early chordates, small shelly fossils',
      'Ordovician':
          'brachiopods, bryozoans, graptolites, nautiloids, trilobites, early jawless fish',
      'Silurian':
          'sea scorpions, corals, crinoids, jawless fish, early jawed fish, early land plants',
      'Devonian':
          'armoured fish, lobe-finned fish, early sharks, ammonoids, early forests, first tetrapods',
      'Carboniferous':
          'coal-swamp plants, giant insects, amphibians, early reptiles, crinoids, brachiopods',
      'Permian':
          'synapsids, conifers, seed ferns, ammonoids, fusulinids, large terrestrial reptiles',
      'Triassic':
          'early dinosaurs, marine reptiles, ammonites, conifers, early mammals, pterosaurs',
      'Jurassic':
          'dinosaurs, pterosaurs, marine reptiles, ammonites, cycads, conifers, early birds',
      'Cretaceous':
          'flowering plants, dinosaurs, ammonites, mosasaurs, plesiosaurs, birds, early mammals',
      'Paleogene':
          'mammals diversify, birds diversify, early whales, grasses begin expanding, foraminifera',
      'Neogene':
          'grassland mammals, horses, antelope, apes, whales, sharks, modern bird groups',
      'Quaternary':
          'mammoths, mastodons, sabre-toothed cats, giant ground sloths, humans, Ice Age megafauna',
    };
    final phanerozoicPeriods = {
      'Cambrian',
      'Ordovician',
      'Silurian',
      'Devonian',
      'Carboniferous',
      'Permian',
      'Triassic',
      'Jurassic',
      'Cretaceous',
      'Paleogene',
      'Neogene',
      'Quaternary',
    };

    final segments = <TimelineRowSegment>[];
    String? currentInterval;
    String? currentColorKey;
    double currentSpan = 0.0;
    double currentStartMa = 0.0;
    double currentEndMa = 0.0;

    void flush() {
      if (currentInterval == null) {
        return;
      }
      final label = rlifeData[currentInterval];
      if (label == null) {
        segments.add(
          TimelineRowSegment(
            id: -1,
            label: '',
            rank: GeologicRank.period,
            startMa: currentStartMa,
            endMa: currentEndMa,
            colorKey: '',
            isGap: true,
            unitSpan: currentSpan,
            secondaryLabel: null,
          ),
        );
      } else {
        segments.add(
          TimelineRowSegment(
            id: currentInterval.hashCode,
            label: label,
            rank: GeologicRank.period,
            startMa: currentStartMa,
            endMa: currentEndMa,
            colorKey: currentColorKey ?? '',
            isGap: false,
            unitSpan: currentSpan,
            secondaryLabel: null,
          ),
        );
      }
    }

    for (final slot in slots) {
      final period = slot.period;
      String interval;
      String? colorKey;
      double slotStart;
      double slotEnd;
      if (period != null && phanerozoicPeriods.contains(period.name)) {
        interval = period.name;
        colorKey = _colorKeyForDivision(period, _divisionById);
        slotStart = period.startMa;
        slotEnd = period.endMa;
      } else {
        interval = 'Precambrian';
        colorKey = _colorKeyForPrecambrian(slot);
        slotStart = slot.eon.startMa;
        slotEnd = slot.eon.endMa;
      }

      if (interval != currentInterval) {
        flush();
        currentInterval = interval;
        currentColorKey = colorKey;
        currentSpan = slot.weight;
        currentStartMa = slotStart;
        currentEndMa = slotEnd;
      } else {
        currentSpan += slot.weight;
        currentEndMa = slotEnd;
      }
    }
    flush();
    return segments;
  }

  String _colorKeyForPrecambrian(_Slot slot) {
    final proterozoic = _divisionById.values.firstWhere(
      (division) =>
          division.rank == GeologicRank.eon && division.name == 'Proterozoic',
      orElse: () => slot.eon,
    );
    return _colorKeyForDivision(proterozoic, _divisionById);
  }

  String _colorKeyForDivision(
    GeologicDivision division,
    Map<int, GeologicDivision> divisionById,
  ) {
    final parts = <GeologicDivision>[];
    GeologicDivision? current = division;
    while (current != null) {
      parts.add(current);
      final parentId = current.parentId;
      current = parentId == null ? null : divisionById[parentId];
    }
    var key = '';
    for (final part in parts.reversed) {
      key = divisionColorKey(
        name: part.name,
        rank: part.rank.name,
        parentKey: key.isEmpty ? null : key,
      );
    }
    return key;
  }

  Map<int, GeologicDivision> _divisionById = const {};

  List<_Slot> _buildSlots(
    List<GeologicDivision> eons,
    Map<int, GeologicDivision> divisionById,
    Map<int, List<GeologicDivision>> childrenByParentId,
  ) {
    _divisionById = divisionById;
    final slots = <_Slot>[];
    final mesozoicEra = _findEra(eons, childrenByParentId, 'Mesozoic');
    final cenozoicEra = _findEra(eons, childrenByParentId, 'Cenozoic');
    final mesozoicPeriodCount = mesozoicEra == null
        ? 0
        : _childrenOfRank(
            mesozoicEra,
            GeologicRank.period,
            childrenByParentId,
          ).length;
    final cenozoicEpochCount = cenozoicEra == null
        ? 0
        : _countEpochsForEra(cenozoicEra, childrenByParentId);
    final mesozoicPeriodWeight = (mesozoicPeriodCount > 0 &&
            cenozoicEpochCount > 0)
        ? cenozoicEpochCount / mesozoicPeriodCount
        : 1.0;
    for (final eon in eons) {
      final eras = _childrenOfRank(eon, GeologicRank.era, childrenByParentId)
        ..sort((a, b) => b.startMa.compareTo(a.startMa));
      if (eras.isEmpty) {
        slots.add(_Slot(eon: eon));
        continue;
      }
      for (final era in eras) {
        final periods =
            _childrenOfRank(era, GeologicRank.period, childrenByParentId)
              ..sort((a, b) => b.startMa.compareTo(a.startMa));
        if (periods.isEmpty) {
          slots.add(_Slot(eon: eon, era: era));
          continue;
        }
        for (final period in periods) {
          final epochs =
              _childrenOfRank(period, GeologicRank.epoch, childrenByParentId)
                ..sort((a, b) => b.startMa.compareTo(a.startMa));
          if (epochs.isEmpty) {
            slots.add(_Slot(eon: eon, era: era, period: period));
            continue;
          }
          final isMesozoic = _isMesozoicPeriod(period, era);
          final epochWeight = isMesozoic
              ? mesozoicPeriodWeight / epochs.length
              : 1.0;
          for (final epoch in epochs) {
            final stages =
                _childrenOfRank(epoch, GeologicRank.stage, childrenByParentId)
                  ..sort((a, b) => b.startMa.compareTo(a.startMa));
            slots.add(
              _Slot(
                eon: eon,
                era: era,
                period: period,
                epoch: epoch,
                stages: stages,
                weight: epochWeight,
              ),
            );
          }
        }
      }
    }
    return slots;
  }

  List<GeologicDivision> _childrenOfRank(
    GeologicDivision parent,
    GeologicRank rank,
    Map<int, List<GeologicDivision>> childrenByParentId,
  ) {
    final children = childrenByParentId[parent.id] ?? const [];
    return children.where((division) => division.rank == rank).toList();
  }

  GeologicDivision? _findEra(
    List<GeologicDivision> eons,
    Map<int, List<GeologicDivision>> childrenByParentId,
    String name,
  ) {
    for (final eon in eons) {
      final eras = _childrenOfRank(eon, GeologicRank.era, childrenByParentId);
      for (final era in eras) {
        if (era.name == name) {
          return era;
        }
      }
    }
    return null;
  }

  int _countEpochsForEra(
    GeologicDivision era,
    Map<int, List<GeologicDivision>> childrenByParentId,
  ) {
    var count = 0;
    final periods = _childrenOfRank(era, GeologicRank.period, childrenByParentId);
    for (final period in periods) {
      count +=
          _childrenOfRank(period, GeologicRank.epoch, childrenByParentId).length;
    }
    return count;
  }

  bool _isMesozoicPeriod(GeologicDivision period, GeologicDivision? era) {
    if (period.rank != GeologicRank.period) {
      return false;
    }
    if (era?.name != 'Mesozoic') {
      return false;
    }
    return switch (period.name) {
      'Triassic' => true,
      'Jurassic' => true,
      'Cretaceous' => true,
      _ => false,
    };
  }
}

class _Slot {
  _Slot({
    required this.eon,
    this.era,
    this.period,
    this.epoch,
    List<GeologicDivision>? stages,
    double? weight,
  })  : stages = stages ?? const [],
        weight = weight ?? 1.0;

  final GeologicDivision eon;
  final GeologicDivision? era;
  final GeologicDivision? period;
  final GeologicDivision? epoch;
  final List<GeologicDivision> stages;
  final double weight;

  GeologicDivision? divisionFor(GeologicRank rank) {
    switch (rank) {
      case GeologicRank.eon:
        return eon;
      case GeologicRank.era:
        return era;
      case GeologicRank.period:
        return period;
      case GeologicRank.epoch:
        return epoch;
      case GeologicRank.stage:
        return null;
      case GeologicRank.age:
        return null;
    }
  }
}
