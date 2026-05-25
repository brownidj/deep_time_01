import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:deep_time/app/app_debug.dart';
import 'package:deep_time/application/services/clade_search.dart';
import 'package:deep_time/application/services/clade_visibility_resolver.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/domain/models/clade.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/ui/models/clade_view_mode.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';
import 'package:deep_time/ui/screens/timeline/timeline_min_height_helpers.dart';
import 'package:deep_time/ui/screens/timeline/timeline_orientation.dart';
import 'package:deep_time/ui/theme/deep_time_palette.dart';
import 'package:deep_time/ui/widgets/time_range_format.dart';
import 'package:deep_time/ui/widgets/timeline_range_mapper.dart';
import 'package:deep_time/ui/widgets/timeline_explanation_dialog.dart';

part 'timeline_vertical_columns_segments.dart';
part 'timeline_vertical_columns_segment_heights.dart';
part 'timeline_vertical_columns_ma.dart';
part 'timeline_vertical_columns_events.dart';
part 'timeline_vertical_columns_extinctions.dart';
part 'timeline_vertical_columns_painters.dart';
part 'timeline_vertical_columns_clades.dart';

class TimelineVerticalColumns extends StatelessWidget {
  const TimelineVerticalColumns({
    super.key,
    required this.layout,
    required this.markers,
    required this.palette,
    required this.selectedId,
    required this.onBandSelect,
    required this.onSelect,
    required this.scrollController,
    required this.clades,
    required this.cladeViewMode,
    required this.cladeCategoryId,
    required this.cladeRepresentativeIds,
    required this.cladeSearchQuery,
    required this.cladeSpotlightId,
    required this.onCladeSpotlight,
    required this.metrics,
  });

  final TimelineLayoutSnapshot layout;
  final TimelineMarkerCatalog markers;
  final DeepTimePalette palette;
  final int? selectedId;
  final ValueChanged<TimelineBandSegment> onBandSelect;
  final ValueChanged<TimelineRowSegment> onSelect;
  final ScrollController scrollController;
  final List<Clade> clades;
  final CladeViewMode cladeViewMode;
  final String cladeCategoryId;
  final List<String> cladeRepresentativeIds;
  final String cladeSearchQuery;
  final String? cladeSpotlightId;
  final ValueChanged<Clade> onCladeSpotlight;
  final TimelineBodyMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final columnHeight = math.max(metrics.minHeight, metrics.scrollHeight);
    return LayoutBuilder(
      builder: (context, constraints) {
        final useFixedHeights = layout.fixedHeight != null;
        final stageLabelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: DeepTimePalette.darkLabel,
          fontWeight: FontWeight.w700,
        );
        final periodLabelStyle = stageLabelStyle;
        final minHeights = buildMinHeightMaps(
          layout,
          stageLabelStyle,
          periodStyle: periodLabelStyle,
        );
        final scale = _widthScale(constraints.maxWidth);
        final cappedTracks = <TimelineTrack>{
          TimelineTrack.ma,
          TimelineTrack.eon,
          TimelineTrack.era,
          TimelineTrack.period,
          TimelineTrack.epoch,
          TimelineTrack.stage,
          TimelineTrack.rlife,
        };
        double scaledWidth(TimelineTrack track) =>
            metrics.trackWidth(track) *
            (cappedTracks.contains(track) ? 1.0 : scale);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MaColumn(
              width: scaledWidth(TimelineTrack.ma),
              height: columnHeight,
              layout: layout,
              metrics: metrics,
            ),
            _VerticalBandColumn(
              width: scaledWidth(TimelineTrack.eon),
              height: columnHeight,
              segments: layout.eonSegments,
              unitsTotal: metrics.eonTotalUnits,
              selectedId: selectedId,
              onTapSegment: onBandSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: true,
              horizontalPadding: 2,
              minHeightForSegment: useFixedHeights
                  ? null
                  : (segment, _) =>
                      minHeights.eonHeights[segment.id] ?? 0.0,
            ),
            _VerticalBandColumn(
              width: scaledWidth(TimelineTrack.era),
              height: columnHeight,
              segments: layout.eraSegments,
              unitsTotal: metrics.eraTotalUnits,
              selectedId: selectedId,
              onTapSegment: onBandSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: true,
              horizontalPadding: 2,
              minHeightForSegment: useFixedHeights
                  ? null
                  : (segment, _) => segment.isGap
                      ? minHeightFromParentRange(
                          segment.startMa,
                          segment.endMa,
                          layout.eonSegments,
                          minHeights.eonHeights,
                          (parent) => parent.startMa,
                          (parent) => parent.endMa,
                          (parent) => parent.id,
                        )
                      : (minHeights.eraHeights[segment.id] ?? 0.0),
            ),
            _VerticalRowColumn(
              width: scaledWidth(TimelineTrack.period),
              height: columnHeight,
              segments: layout.periodSegments,
              unitsTotal: metrics.periodUnits,
              selectedId: selectedId,
              onTapSegment: onSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: true,
              horizontalPadding: 6,
              minHeightForSegment: useFixedHeights
                  ? null
                  : (segment, _) => segment.isGap
                      ? minHeightFromParentRange(
                          segment.startMa,
                          segment.endMa,
                          layout.eraSegments,
                          minHeights.eraHeights,
                          (parent) => parent.startMa,
                          (parent) => parent.endMa,
                          (parent) => parent.id,
                        )
                      : (minHeights.periodHeights[segment.id] ?? 0.0),
            ),
            _VerticalRowColumn(
              width: scaledWidth(TimelineTrack.epoch),
              height: columnHeight,
              segments: layout.epochSegments,
              unitsTotal: metrics.epochTotalUnits,
              selectedId: selectedId,
              onTapSegment: onSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: false,
              horizontalPadding: 6,
              minHeightForSegment: useFixedHeights
                  ? null
                  : (segment, _) => segment.isGap
                      ? minHeightFromParentRange(
                          segment.startMa,
                          segment.endMa,
                          layout.periodSegments,
                          minHeights.periodHeights,
                          (parent) => parent.startMa,
                          (parent) => parent.endMa,
                          (parent) => parent.id,
                        )
                      : (minHeights.epochHeights[segment.id] ?? 0.0),
            ),
            _VerticalRowColumn(
              width: scaledWidth(TimelineTrack.stage),
              height: columnHeight,
              segments: layout.stageSegments,
              unitsTotal: metrics.stageTotalUnits,
              selectedId: selectedId,
              onTapSegment: onSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: false,
              horizontalPadding: 6,
              minHeightForSegment: useFixedHeights
                  ? null
                  : (segment, style) => segment.isGap
                      ? minHeightFromParentRange(
                          segment.startMa,
                          segment.endMa,
                          layout.epochSegments,
                          minHeights.epochHeights,
                          (parent) => parent.startMa,
                          (parent) => parent.endMa,
                          (parent) => parent.id,
                        )
                      : minHeightForStageLabel(segment, style),
            ),
            _VerticalRowColumn(
              width: scaledWidth(TimelineTrack.rlife),
              height: columnHeight,
              segments: layout.rlifeSegments,
              unitsTotal: metrics.rlifeTotalUnits,
              selectedId: selectedId,
              onTapSegment: onSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: false,
              horizontalPadding: 6,
              minHeightForSegment: null,
            ),
            _VerticalEventsColumn(
              width: scaledWidth(TimelineTrack.events),
              height: columnHeight,
              events: layout.eventSegments,
              totalUnits: metrics.periodUnits,
              palette: palette,
            ),
            _VerticalExtinctionColumn(
              width: scaledWidth(TimelineTrack.extinctions),
              height: columnHeight,
              periodSegments: layout.periodSegments,
              stageSegments: layout.stageSegments,
              extinctions: markers.extinctions,
            ),
            _VerticalCladeColumn(
              width: scaledWidth(TimelineTrack.clades),
              height: columnHeight,
              layout: layout,
              totalUnits: metrics.periodUnits,
              scrollController: scrollController,
              clades: clades,
              viewMode: cladeViewMode,
              displayGroupId: cladeCategoryId,
              representativeIds: cladeRepresentativeIds,
              searchQuery: cladeSearchQuery,
              spotlightId: cladeSpotlightId,
              onSpotlight: onCladeSpotlight,
            ),
          ],
        );
      },
    );
  }

  double _widthScale(double maxWidth) {
    if (!maxWidth.isFinite || maxWidth <= 0 || metrics.trackColumnsWidth <= 0) {
      return 1.0;
    }
    return maxWidth / metrics.trackColumnsWidth;
  }
}

Color _darken(Color color, double factor) {
  int scaledChannel(double value) {
    return (value * 255.0 * factor).round().clamp(0, 255).toInt();
  }

  int scaledAlpha(double value) {
    return (value * 255.0).round().clamp(0, 255).toInt();
  }

  return Color.fromARGB(
    scaledAlpha(color.a),
    scaledChannel(color.r),
    scaledChannel(color.g),
    scaledChannel(color.b),
  );
}

Color _safeColorForKey(String key, DeepTimePalette palette) {
  if (key.trim().isEmpty) {
    return const Color(0xFF6C757D);
  }
  try {
    return palette.colorForKey(key);
  } catch (_) {
    return const Color(0xFF6C757D);
  }
}
