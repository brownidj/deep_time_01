import 'package:deep_time/domain/models/clade.dart';

abstract class CladeRepository {
  Future<List<Clade>> fetchAll();
}
