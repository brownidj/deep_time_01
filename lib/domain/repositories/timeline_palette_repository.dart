import 'package:deep_time/domain/models/timeline_palette.dart';

abstract class TimelinePaletteRepository {
  Future<TimelinePalette> fetchPalette();
}
