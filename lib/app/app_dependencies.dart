import 'package:deep_time/app/app_debug.dart';
import 'package:deep_time/application/services/timeline_service.dart';
import 'package:deep_time/infra/db/app_database.dart';
import 'package:deep_time/domain/repositories/clade_display_group_repository.dart';
import 'package:deep_time/domain/repositories/clade_repository.dart';
import 'package:deep_time/domain/repositories/clade_representative_repository.dart';
import 'package:deep_time/infra/repositories/sqlite_geologic_division_repository.dart';
import 'package:deep_time/infra/repositories/sqlite_paleontology_repository.dart';
import 'package:deep_time/infra/repositories/yaml_clade_repository.dart';
import 'package:deep_time/infra/repositories/yaml_clade_display_group_repository.dart';
import 'package:deep_time/infra/repositories/yaml_clade_representative_repository.dart';
import 'package:deep_time/infra/repositories/yaml_timeline_marker_repository.dart';
import 'package:deep_time/infra/repositories/yaml_timeline_palette_repository.dart';

class AppDependencies {
  AppDependencies({
    required this.database,
    required this.timelineService,
    required this.cladeDisplayGroupRepository,
    required this.cladeRepresentativeRepository,
    required this.cladeRepository,
  });

  final AppDatabase database;
  final TimelineService timelineService;
  final CladeDisplayGroupRepository cladeDisplayGroupRepository;
  final CladeRepresentativeRepository cladeRepresentativeRepository;
  final CladeRepository cladeRepository;

  static Future<AppDependencies> build() async {
    try {
      final database = await AppDatabase.open();
      final divisionRepository = SqliteGeologicDivisionRepository(database);
      final paleontologyRepository = SqlitePaleontologyRepository(database);
      final paletteRepository = YamlTimelinePaletteRepository(
        assetPath: 'data/time_divisions.yaml',
      );
      final markerRepository = YamlTimelineMarkerRepository(
        assetPath: 'data/timeline_markers.yaml',
      );
      final cladeDisplayGroupRepository = YamlCladeDisplayGroupRepository(
        assetPath: 'data/clade_display_groups.yaml',
      );
      final cladeRepresentativeRepository = YamlCladeRepresentativeRepository(
        assetPath: 'data/clade_representative_ids.yaml',
      );
      final cladeRepository = YamlCladeRepository(
        assetPath: 'data/clades.yaml',
      );
      final timelineService = TimelineService(
        divisionRepository: divisionRepository,
        paleontologyRepository: paleontologyRepository,
        paletteRepository: paletteRepository,
        markerRepository: markerRepository,
        cladeRepository: cladeRepository,
      );
      return AppDependencies(
        database: database,
        timelineService: timelineService,
        cladeDisplayGroupRepository: cladeDisplayGroupRepository,
        cladeRepresentativeRepository: cladeRepresentativeRepository,
        cladeRepository: cladeRepository,
      );
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to build AppDependencies',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> close() async {
    database.close();
  }
}
