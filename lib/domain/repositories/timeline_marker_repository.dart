import 'package:gts_01/domain/models/timeline_marker_catalog.dart';

abstract class TimelineMarkerRepository {
  Future<TimelineMarkerCatalog> fetchMarkers();
}
