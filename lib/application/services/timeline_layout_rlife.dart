import 'package:gts_01/application/services/timeline_layout_color_keys.dart';
import 'package:gts_01/application/services/timeline_layout_models.dart';
import 'package:gts_01/application/services/timeline_layout_slots.dart';
import 'package:gts_01/domain/models/geologic_division.dart';
import 'package:gts_01/domain/models/geologic_rank.dart';

class TimelineRLifeBuilder {
  TimelineRLifeBuilder({required this.divisionById});

  final Map<int, GeologicDivision> divisionById;

  List<TimelineRowSegment> buildRLifeRow(List<TimelineSlot> slots) {
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
        colorKey = colorKeyForDivision(period, divisionById);
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

  String _colorKeyForPrecambrian(TimelineSlot slot) {
    final proterozoic = divisionById.values.firstWhere(
      (division) =>
          division.rank == GeologicRank.eon && division.name == 'Proterozoic',
      orElse: () => slot.eon,
    );
    return colorKeyForDivision(proterozoic, divisionById);
  }
}
