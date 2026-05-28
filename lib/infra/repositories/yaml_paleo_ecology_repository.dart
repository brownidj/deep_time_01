import 'package:deep_time/domain/models/paleo_ecology_entry.dart';
import 'package:deep_time/domain/repositories/paleo_ecology_repository.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class YamlPaleoEcologyRepository implements PaleoEcologyRepository {
  YamlPaleoEcologyRepository({required this.assetPath});

  final String assetPath;

  @override
  Future<List<PaleoEcologyEntry>> fetchEntries() async {
    final yamlText = await rootBundle.loadString(assetPath);
    final document = loadYaml(yamlText) as YamlMap;
    final list = document['palaeo_ecology'];
    if (list is! YamlList) {
      return const [];
    }
    return list.whereType<YamlMap>().map(_parseEntry).toList();
  }

  PaleoEcologyEntry _parseEntry(YamlMap map) {
    return PaleoEcologyEntry(
      stage: _requireString(map, 'stage'),
      avgTempDeltaC: _requireDouble(map, 'avg_temp_delta_c'),
      avgHumidityDeltaPercent: _requireDouble(
        map,
        'avg_humidity_delta_percent',
      ),
      avgCo2Ppm: _requireDouble(map, 'avg_co2_ppm'),
      seaLevelDeltaM: _requireDouble(map, 'sea_level_delta_m'),
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
}
