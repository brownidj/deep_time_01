import 'package:deep_time/domain/models/timeline_marker_catalog.dart';

abstract class TimelineMarkerRepository {
  Future<TimelineMarkerCatalog> fetchMarkers();
}
