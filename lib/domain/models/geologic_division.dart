import 'package:gts_01/domain/models/geologic_rank.dart';

class GeologicDivision {
  const GeologicDivision({
    required this.id,
    required this.name,
    required this.rank,
    required this.startMa,
    required this.endMa,
    this.startMaUncertainty,
    this.parentId,
  });

  final int id;
  final String name;
  final GeologicRank rank;
  final double startMa;
  final double endMa;
  final double? startMaUncertainty;
  final int? parentId;

  double get durationMa => startMa - endMa;
}
