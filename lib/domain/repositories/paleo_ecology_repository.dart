import 'package:deep_time/domain/models/paleo_ecology_entry.dart';

abstract class PaleoEcologyRepository {
  Future<List<PaleoEcologyEntry>> fetchEntries();
}
