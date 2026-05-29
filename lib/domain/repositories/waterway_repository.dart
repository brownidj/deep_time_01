import 'package:deep_time/domain/models/timeline_marker_catalog.dart';

abstract class WaterwayRepository {
  Future<List<TimelineEventDefinition>> fetchWaterways();
}
