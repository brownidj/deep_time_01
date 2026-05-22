import 'package:gts_01/application/services/timeline_layout_builder.dart';
import 'package:gts_01/application/services/timeline_layout_models.dart';
import 'package:gts_01/domain/models/geologic_division.dart';
import 'package:gts_01/domain/models/timeline_marker_catalog.dart';

export 'package:gts_01/application/services/timeline_layout_models.dart';

class TimelineLayoutService {
  TimelineLayoutSnapshot build(
    List<GeologicDivision> divisions,
    TimelineMarkerCatalog markers,
  ) {
    final builder = TimelineLayoutBuilder();
    return builder.build(divisions, markers);
  }
}
