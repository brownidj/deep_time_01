import 'package:flutter/services.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/domain/repositories/continent_repository.dart';
import 'package:yaml/yaml.dart';

class YamlContinentRepository implements ContinentRepository {
  YamlContinentRepository({required this.assetPath});

  final String assetPath;

  @override
  Future<List<TimelineEventDefinition>> fetchContinents() async {
    final yamlText = await rootBundle.loadString(assetPath);
    final document = loadYaml(yamlText) as YamlMap;
    final continents = document['continents'];
    if (continents is! YamlList) {
      return const [];
    }
    return continents.whereType<YamlMap>().map(_parseBar).toList();
  }

  TimelineEventDefinition _parseBar(YamlMap entry) {
    final label = _requireString(entry, 'label');
    final shortLabel = _requireString(entry, 'short_label');
    final startMa = _requireDouble(entry, 'start_ma');
    final endMa = _requireDouble(entry, 'end_ma');
    final explanation = _readString(entry['explanation']);
    return TimelineEventDefinition(
      label: label,
      shortLabel: shortLabel,
      kind: TimelineEventKind.bar,
      explanation: explanation,
      startMa: startMa,
      endMa: endMa,
      atMa: null,
    );
  }

  String _requireString(YamlMap map, String key) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    throw StateError('Missing required string "$key" in $assetPath');
  }

  double _requireDouble(YamlMap map, String key) {
    final value = _readDouble(map[key]);
    if (value == null) {
      throw StateError('Missing required number "$key" in $assetPath');
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

  String? _readString(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }
}
