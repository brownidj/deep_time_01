import 'package:deep_time/domain/models/clade_display_group.dart';

abstract class CladeDisplayGroupRepository {
  Future<List<CladeDisplayGroup>> fetchDisplayGroups();
}
