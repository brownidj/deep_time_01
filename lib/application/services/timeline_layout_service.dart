import 'package:gts_01/application/services/timeline_layout_builder.dart';
import 'package:gts_01/application/services/timeline_layout_models.dart';
import 'package:gts_01/domain/models/geologic_division.dart';

export 'package:gts_01/application/services/timeline_layout_models.dart';

class TimelineLayoutService {
  TimelineLayoutSnapshot build(List<GeologicDivision> divisions) {
    final builder = TimelineLayoutBuilder();
    return builder.build(divisions);
  }
}
