import 'package:flutter/material.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/domain/models/clade.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/ui/models/clade_view_mode.dart';
import 'package:deep_time/ui/models/time_label_mode.dart';
import 'package:deep_time/ui/theme/deep_time_palette.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_content.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';

class TimelineBody extends StatelessWidget {
  const TimelineBody({
    super.key,
    required this.layout,
    required this.palette,
    required this.markers,
    required this.labelMode,
    required this.scrollController,
    required this.selectedId,
    required this.onBandSelect,
    required this.onSelect,
    required this.clades,
    required this.cladeViewMode,
    required this.cladeCategoryId,
    required this.cladeRepresentativeIds,
    required this.cladeSearchQuery,
    required this.cladeSpotlightId,
    required this.onCladeSpotlight,
  });

  final TimelineLayoutSnapshot layout;
  final DeepTimePalette palette;
  final TimelineMarkerCatalog markers;
  final TimeLabelMode labelMode;
  final ScrollController scrollController;
  final int? selectedId;
  final ValueChanged<TimelineBandSegment> onBandSelect;
  final ValueChanged<TimelineRowSegment> onSelect;
  final List<Clade> clades;
  final CladeViewMode cladeViewMode;
  final String cladeCategoryId;
  final List<String> cladeRepresentativeIds;
  final String cladeSearchQuery;
  final String? cladeSpotlightId;
  final ValueChanged<Clade> onCladeSpotlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final metrics = TimelineBodyMetrics.fromLayout(
              layout: layout,
              markers: markers,
              constraints: constraints,
            );
            return TimelineBodyContent(
              layout: layout,
              palette: palette,
              markers: markers,
              labelMode: labelMode,
              scrollController: scrollController,
              selectedId: selectedId,
              onBandSelect: onBandSelect,
              onSelect: onSelect,
              metrics: metrics,
              clades: clades,
              cladeViewMode: cladeViewMode,
              cladeCategoryId: cladeCategoryId,
              cladeRepresentativeIds: cladeRepresentativeIds,
              cladeSearchQuery: cladeSearchQuery,
              cladeSpotlightId: cladeSpotlightId,
              onCladeSpotlight: onCladeSpotlight,
            );
          },
        ),
      ),
    );
  }
}
