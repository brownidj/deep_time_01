import 'package:gts_01/domain/models/geologic_division.dart';
import 'package:gts_01/domain/models/paleontology_taxon.dart';
import 'package:gts_01/domain/models/fossil_range.dart';
import 'package:gts_01/domain/models/timeline_palette.dart';
import 'package:gts_01/domain/repositories/geologic_division_repository.dart';
import 'package:gts_01/domain/repositories/paleontology_repository.dart';
import 'package:gts_01/domain/repositories/timeline_palette_repository.dart';

class TimelineSnapshot {
  const TimelineSnapshot({
    required this.divisions,
    required this.taxa,
    required this.ranges,
    required this.palette,
  });

  final List<GeologicDivision> divisions;
  final List<PaleontologyTaxon> taxa;
  final List<FossilRange> ranges;
  final TimelinePalette palette;
}

class TimelineService {
  TimelineService({
    required this._divisionRepository,
    required this._paleontologyRepository,
    required this._paletteRepository,
  });

  final GeologicDivisionRepository _divisionRepository;
  final PaleontologyRepository _paleontologyRepository;
  final TimelinePaletteRepository _paletteRepository;

  Future<TimelineSnapshot> loadSnapshot() async {
    final divisions = await _divisionRepository.fetchAll();
    final taxa = await _paleontologyRepository.fetchAllTaxa();
    final ranges = await _paleontologyRepository.fetchRangesOverlapping(
      divisions.isEmpty ? 0 : divisions.first.startMa,
      0,
    );
    final palette = await _paletteRepository.fetchPalette();
    _validatePaletteCoverage(palette, divisions);
    return TimelineSnapshot(
      divisions: divisions,
      taxa: taxa,
      ranges: ranges,
      palette: palette,
    );
  }

  Future<List<FossilRange>> rangesForDivision(GeologicDivision division) async {
    return _paleontologyRepository.fetchRangesOverlapping(
      division.startMa,
      division.endMa,
    );
  }

  void _validatePaletteCoverage(
    TimelinePalette palette,
    List<GeologicDivision> divisions,
  ) {
    if (divisions.isEmpty) {
      return;
    }
    for (final division in divisions) {
      final key = _colorKeyForDivision(division, divisions);
      if (!palette.divisionColors.containsKey(key)) {
        throw StateError(
          'Missing palette color for ${division.rank.name} '
          '"${division.name}" (${division.startMa} Ma).',
        );
      }
    }
  }

  String _colorKeyForDivision(
    GeologicDivision division,
    List<GeologicDivision> divisions,
  ) {
    final divisionById = {for (final item in divisions) item.id: item};
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
}
