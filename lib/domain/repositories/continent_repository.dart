import 'package:deep_time/domain/models/timeline_marker_catalog.dart';

abstract class ContinentRepository {
  Future<List<TimelineEventDefinition>> fetchContinents();
}
