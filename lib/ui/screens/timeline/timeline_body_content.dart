import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/domain/models/clade.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/ui/models/clade_view_mode.dart';
import 'package:deep_time/ui/models/time_label_mode.dart';
import 'package:deep_time/ui/screens/timeline/clade_lane.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_overlays.dart';
import 'package:deep_time/ui/screens/timeline/timeline_row_labels.dart';
import 'package:deep_time/ui/theme/deep_time_palette.dart';
import 'package:deep_time/ui/widgets/continuous_timeline.dart';
import 'package:deep_time/ui/widgets/timeline_events_row.dart';

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
    final contentHeight = math.max(metrics.minHeight, metrics.contentHeight);
    return SingleChildScrollView(
      child: SizedBox(
        height: contentHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: metrics.labelWidth,
              child: TimelineRowLabels(
                eonHeight: metrics.eonHeight,
                eraHeight: metrics.eraHeight,
                rowHeight: metrics.rowHeight,
                subRowHeight: metrics.subRowHeight,
                stageRowHeight: metrics.stageRowHeight,
                rlifeRowHeight: metrics.rlifeRowHeight,
                eventsRowHeight: metrics.eventsRowHeight,
                cladeRowHeight: metrics.cladeRowHeight,
                extinctionsRowHeight: metrics.extinctionsRowHeight,
                labelMode: labelMode,
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: metrics.scrollWidth,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TimelineBands(
                              eonSegments: layout.eonSegments,
                              eraSegments: layout.eraSegments,
                              palette: palette,
                              onTapSegment: onBandSelect,
                              eonHeight: metrics.eonHeight,
                              eraHeight: metrics.eraHeight,
                              selectedId: selectedId,
                              eonBorderWidth: 1,
                              eraBorderWidth: 1,
                            ),
                            ContinuousTimelineRow(
                              segments: layout.periodSegments,
                              selectedId: selectedId,
                              palette: palette,
                              rowHeight: metrics.subRowHeight,
                              borderWidth: 1,
                              onTapSegment: onSelect,
                            ),
                            ContinuousTimelineRow(
                              segments: layout.epochSegments,
                              selectedId: selectedId,
                              palette: palette,
                              rowHeight: metrics.subRowHeight,
                              onTapSegment: onSelect,
                            ),
                            ContinuousTimelineRow(
                              segments: layout.stageSegments,
                              selectedId: selectedId,
                              palette: palette,
                              rowHeight: metrics.stageRowHeight,
                              verticalLabels: true,
                              onTapSegment: onSelect,
                            ),
                            ContinuousTimelineRow(
                              segments: layout.rlifeSegments,
                              selectedId: selectedId,
                              palette: palette,
                              rowHeight: metrics.rlifeRowHeight,
                              multiLineLabels: true,
                              maxLabelLines: 3,
                              onTapSegment: onSelect,
                            ),
                            TimelineEventsRow(
                              events: layout.eventSegments,
                              totalUnits: metrics.periodUnits,
                              rowHeight: metrics.eventsRowHeight,
                              palette: palette,
                            ),
                            SizedBox(
                              height: metrics.extinctionsRowHeight,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: DeepTimePalette.timelineGapBackground,
                                  border: Border.all(
                                    color: DeepTimePalette.periodDivider,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: metrics.cladeRowHeight,
                              child: CladeLane(
                                layout: layout,
                                scrollWidth: metrics.scrollWidth,
                                totalUnits: metrics.periodUnits,
                                height: metrics.cladeRowHeight,
                                scrollController: scrollController,
                                clades: clades,
                                viewMode: cladeViewMode,
                                displayGroupId: cladeCategoryId,
                                representativeIds: cladeRepresentativeIds,
                                searchQuery: cladeSearchQuery,
                                spotlightId: cladeSpotlightId,
                                onSpotlight: onCladeSpotlight,
                              ),
                            ),
                          ],
                        ),
                        TimelineBodyOverlays(layout: layout, metrics: metrics),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
