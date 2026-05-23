import 'package:deep_time/domain/models/clade_zoom_level.dart';

class Clade {
  const Clade({
    required this.id,
    required this.label,
    required this.scientificRank,
    required this.startMa,
    required this.endMa,
    required this.displayGroups,
    required this.displayPriority,
    required this.minZoomLevel,
    this.parentId,
    this.rangeNote,
    this.confidence,
    this.shortDescription,
    this.representativeTaxa,
    this.extinctionNote,
    this.tags,
  });

  final String id;
  final String label;
  final String scientificRank;
  final String? parentId;
  final double startMa;
  final double endMa;
  final String? rangeNote;
  final String? confidence;
  final List<String> displayGroups;
  final int displayPriority;
  final CladeZoomLevel minZoomLevel;
  final String? shortDescription;
  final List<String>? representativeTaxa;
  final String? extinctionNote;
  final List<String>? tags;

  double get durationMa => startMa - endMa;
}
