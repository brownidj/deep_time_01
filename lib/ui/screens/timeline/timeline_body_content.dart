import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/domain/models/clade.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/ui/models/clade_view_mode.dart';
import 'package:deep_time/ui/models/time_label_mode.dart';
import 'package:deep_time/ui/screens/timeline/timeline_column_headers.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';
import 'package:deep_time/ui/screens/timeline/timeline_vertical_columns.dart';
import 'package:deep_time/ui/screens/timeline/timeline_vertical_overlays.dart';
import 'package:deep_time/ui/theme/deep_time_palette.dart';

class TimelineBodyContent extends StatelessWidget {
  const TimelineBodyContent({
    super.key,
    required this.layout,
    required this.palette,
    required this.markers,
    required this.labelMode,
    required this.scrollController,
    required this.selectedId,
    required this.onBandSelect,
    required this.onSelect,
    required this.metrics,
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
  final TimelineBodyMetrics metrics;
  final List<Clade> clades;
  final CladeViewMode cladeViewMode;
  final String cladeCategoryId;
  final List<String> cladeRepresentativeIds;
  final String cladeSearchQuery;
  final String? cladeSpotlightId;
  final ValueChanged<Clade> onCladeSpotlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TimelineColumnHeaders(metrics: metrics, labelMode: labelMode),
        Expanded(
          child: _buildVerticalCanvas(),
        ),
      ],
    );
  }

  Widget _buildVerticalCanvas() {
    final contentHeight = math.max(metrics.minHeight, metrics.scrollHeight);
    return Scrollbar(
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        child: SizedBox(
          height: contentHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              TimelineVerticalColumns(
                layout: layout,
                markers: markers,
                palette: palette,
                selectedId: selectedId,
                onBandSelect: onBandSelect,
                onSelect: onSelect,
                scrollController: scrollController,
                clades: clades,
                cladeViewMode: cladeViewMode,
                cladeCategoryId: cladeCategoryId,
                cladeRepresentativeIds: cladeRepresentativeIds,
                cladeSearchQuery: cladeSearchQuery,
                cladeSpotlightId: cladeSpotlightId,
                onCladeSpotlight: onCladeSpotlight,
                metrics: metrics,
              ),
              Positioned.fill(
                child: TimelineVerticalOverlays(
                  metrics: metrics,
                  contentHeight: contentHeight,
                  markers: markers,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
