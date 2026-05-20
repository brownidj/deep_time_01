import 'package:gts_01/domain/models/timeline_palette.dart';

abstract class TimelinePaletteRepository {
  Future<TimelinePalette> fetchPalette();
}
