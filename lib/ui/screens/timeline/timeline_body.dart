import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gts_01/app/app_debug.dart';
import 'package:gts_01/application/services/timeline_layout_models.dart';
import 'package:gts_01/domain/models/timeline_marker_catalog.dart';
import 'package:gts_01/ui/models/time_label_mode.dart';
import 'package:gts_01/ui/screens/timeline/timeline_extinction_markers.dart';
import 'package:gts_01/ui/screens/timeline/timeline_event_markers.dart';
import 'package:gts_01/ui/screens/timeline/timeline_row_labels.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';
import 'package:gts_01/ui/widgets/continuous_timeline.dart';
import 'package:gts_01/ui/widgets/timeline_events_row.dart';

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
  });

  final TimelineLayoutSnapshot layout;
  final DeepTimePalette palette;
  final TimelineMarkerCatalog markers;
  final TimeLabelMode labelMode;
  final ScrollController scrollController;
  final int? selectedId;
  final ValueChanged<TimelineBandSegment> onBandSelect;
  final ValueChanged<TimelineRowSegment> onSelect;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const labelWidth = 96.0;
            const eonHeight = 44.0;
            const eraHeight = 104.0;
            const rowHeight = 110.0;
            const subRowHeight = 72.0;
            const stageRowHeight = 120.0;
            const rlifeRowHeight = 110.0;
            const eventsRowBaseHeight = 70.0;
            const extinctionsRowHeight = 70.0;
            const minUnitWidth = 96.0;
            final eventsRowHeight = TimelineEventsRow.requiredHeight(
              events: layout.eventSegments,
              rowHeight: eventsRowBaseHeight,
            );
            final contentHeight = eonHeight +
                eraHeight +
                subRowHeight +
                subRowHeight +
                stageRowHeight +
                rlifeRowHeight +
                eventsRowHeight +
                extinctionsRowHeight;
            final totalUnits = layout.eonSegments.fold<double>(
              0.0,
              (sum, segment) => sum + segment.unitSpan,
            );
            final periodUnits = layout.periodSegments.fold<double>(
              0.0,
              (sum, segment) => sum + segment.unitSpan,
            );
            final scale = AppDebug.timelineScale.clamp(
              AppDebug.minTimelineScale,
              AppDebug.maxTimelineScale,
            );
            final scrollWidth = math.max(
              constraints.maxWidth * scale,
              totalUnits * minUnitWidth,
            );
            final extinctionLayouts = ExtinctionMarkers.buildMarkerLayouts(
              width: scrollWidth,
              periodSegments: layout.periodSegments,
              stageSegments: layout.stageSegments,
              extinctions: markers.extinctions,
            );

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: labelWidth,
                      child: TimelineRowLabels(
                        eonHeight: eonHeight,
                        eraHeight: eraHeight,
                        rowHeight: rowHeight,
                        subRowHeight: subRowHeight,
                        stageRowHeight: stageRowHeight,
                    rlifeRowHeight: rlifeRowHeight,
                    eventsRowHeight: eventsRowHeight,
                    extinctionsRowHeight: extinctionsRowHeight,
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
                            width: scrollWidth,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TimelineBands(
                                      eonSegments: layout.eonSegments,
                                      eraSegments: layout.eraSegments,
                                      palette: palette,
                                      onTapSegment: onBandSelect,
                                      eonHeight: eonHeight,
                                      eraHeight: eraHeight,
                                    ),
                                    ContinuousTimelineRow(
                                      segments: layout.periodSegments,
                                      selectedId: selectedId,
                                      palette: palette,
                                      rowHeight: subRowHeight,
                                      onTapSegment: onSelect,
                                    ),
                                    ContinuousTimelineRow(
                                      segments: layout.epochSegments,
                                      selectedId: selectedId,
                                      palette: palette,
                                      rowHeight: subRowHeight,
                                      onTapSegment: onSelect,
                                    ),
                                    ContinuousTimelineRow(
                                      segments: layout.stageSegments,
                                      selectedId: selectedId,
                                      palette: palette,
                                      rowHeight: stageRowHeight,
                                      verticalLabels: true,
                                      onTapSegment: onSelect,
                                    ),
                                    ContinuousTimelineRow(
                                      segments: layout.rlifeSegments,
                                      selectedId: selectedId,
                                      palette: palette,
                                      rowHeight: rlifeRowHeight,
                                      multiLineLabels: true,
                                      maxLabelLines: 3,
                                      onTapSegment: onSelect,
                                    ),
                                    TimelineEventsRow(
                                      events: layout.eventSegments,
                                      totalUnits: periodUnits,
                                      rowHeight: eventsRowHeight,
                                      palette: palette,
                                    ),
                                    SizedBox(
                                      height: extinctionsRowHeight,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: DeepTimePalette.panelBackground,
                                          border: Border.all(
                                            color: DeepTimePalette.periodDivider,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: eonHeight +
                                      eraHeight -
                                      ExtinctionMarkers.markerHeight,
                                  left: 0,
                                  right: 0,
                                  child: IgnorePointer(
                                    child: SizedBox(
                                      height: contentHeight -
                                          (eonHeight +
                                              eraHeight -
                                              ExtinctionMarkers.markerHeight),
                                      child: Stack(
                                        children: [
                                          ExtinctionMarkers(
                                            width: scrollWidth,
                                            height: contentHeight -
                                                (eonHeight +
                                                    eraHeight -
                                                    ExtinctionMarkers
                                                        .markerHeight),
                                            periodSegments:
                                                layout.periodSegments,
                                            stageSegments:
                                                layout.stageSegments,
                                            markerLayouts: extinctionLayouts,
                                          ),
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            right: 0,
                                            child: EventPointMarkers(
                                              width: scrollWidth,
                                              totalUnits: periodUnits,
                                              events: layout.eventSegments,
                                              extinctionMarkers:
                                                  extinctionLayouts,
                                              height: contentHeight -
                                                  (eonHeight +
                                                      eraHeight -
                                                      ExtinctionMarkers
                                                          .markerHeight),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
          },
        ),
      ),
    );
  }
}
