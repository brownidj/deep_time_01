import 'package:gts_01/app/app_debug.dart';
import 'package:gts_01/application/services/timeline_service.dart';
import 'package:gts_01/infra/db/app_database.dart';
import 'package:gts_01/infra/repositories/sqlite_geologic_division_repository.dart';
import 'package:gts_01/infra/repositories/sqlite_paleontology_repository.dart';
import 'package:gts_01/infra/repositories/yaml_timeline_palette_repository.dart';

class AppDependencies {
  AppDependencies({required this.database, required this.timelineService});

  final AppDatabase database;
  final TimelineService timelineService;

  static Future<AppDependencies> build() async {
    try {
      final database = await AppDatabase.open();
      final divisionRepository = SqliteGeologicDivisionRepository(database);
      final paleontologyRepository = SqlitePaleontologyRepository(database);
      final paletteRepository = YamlTimelinePaletteRepository(
        assetPath: 'data/time_divisions.yaml',
      );
      final timelineService = TimelineService(
        divisionRepository: divisionRepository,
        paleontologyRepository: paleontologyRepository,
        paletteRepository: paletteRepository,
      );
      return AppDependencies(
        database: database,
        timelineService: timelineService,
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
