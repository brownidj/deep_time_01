import 'package:deep_time/application/services/timeline_layout_builder.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/domain/models/geologic_division.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';

export 'package:deep_time/application/services/timeline_layout_models.dart';

class TimelineLayoutService {
  TimelineLayoutSnapshot build(
    List<GeologicDivision> divisions,
    TimelineMarkerCatalog markers,
  ) {
    final builder = TimelineLayoutBuilder();
    return builder.build(divisions, markers);
  }
}
