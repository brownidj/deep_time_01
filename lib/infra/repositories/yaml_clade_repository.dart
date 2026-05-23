import 'package:flutter/services.dart';
import 'package:deep_time/domain/models/clade.dart';
import 'package:deep_time/domain/models/clade_zoom_level.dart';
import 'package:deep_time/domain/repositories/clade_repository.dart';
import 'package:yaml/yaml.dart';

class YamlCladeRepository implements CladeRepository {
  YamlCladeRepository({required this.assetPath});

  final String assetPath;

  @override
  Future<List<Clade>> fetchAll() async {
    final yamlText = await rootBundle.loadString(assetPath);
    final document = loadYaml(yamlText);
    if (document is! YamlList) {
      throw StateError('Expected a YAML list in $assetPath');
    }
    final clades = document.whereType<YamlMap>().map(_parseClade).toList();
    _validateUniqueIds(clades);
    _validateLivingClades(clades);
    return clades;
  }

  Clade _parseClade(YamlMap entry) {
    final id = _requireString(entry, 'id');
    final label = _requireString(entry, 'label');
    final scientificRank = _requireString(entry, 'scientific_rank');
    final startMa = _requireDouble(entry, 'start_ma');
    final endMa = _requireDouble(entry, 'end_ma');
    final displayGroups = _readStringList(entry['display_groups']);
    final displayPriority = _requireInt(entry, 'display_priority');
    final minZoomLevel = parseCladeZoomLevel(
      _requireString(entry, 'min_zoom_level'),
    );
    return Clade(
      id: id,
      label: label,
      scientificRank: scientificRank,
      parentId: _readString(entry['parent_id']),
      startMa: startMa,
      endMa: endMa,
      rangeNote: _readString(entry['range_note']),
      confidence: _readString(entry['confidence']),
      displayGroups: displayGroups,
      displayPriority: displayPriority,
      minZoomLevel: minZoomLevel,
      shortDescription: _readString(entry['short_description']),
      representativeTaxa: _readStringList(entry['representative_taxa']),
      extinctionNote: _readString(entry['extinction_note']),
      tags: _readStringList(entry['tags']),
    );
  }

  void _validateUniqueIds(List<Clade> clades) {
    final ids = <String>{};
    for (final clade in clades) {
      if (!ids.add(clade.id)) {
        throw StateError('Duplicate clade id: ${clade.id}');
      }
    }
  }

  void _validateLivingClades(List<Clade> clades) {
    for (final clade in clades) {
      if (clade.endMa < 0) {
        throw StateError('Clade ${clade.id} has negative end_ma');
      }
    }
  }

  String _requireString(YamlMap map, String key) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    throw StateError('Missing required "$key" in $assetPath');
  }

  String? _readString(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  double _requireDouble(YamlMap map, String key) {
    final value = _readDouble(map[key]);
    if (value == null) {
      throw StateError('Missing required "$key" in $assetPath');
    }
    return value;
  }

  double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  int _requireInt(YamlMap map, String key) {
    final value = map[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    throw StateError('Missing required "$key" in $assetPath');
  }

  List<String> _readStringList(Object? value) {
    if (value is! YamlList) {
      return const [];
    }
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
