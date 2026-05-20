import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gts_01/app/app_debug.dart';
import 'package:gts_01/application/services/timeline_layout_models.dart';
import 'package:gts_01/ui/models/time_label_mode.dart';
import 'package:gts_01/ui/screens/timeline/timeline_extinction_markers.dart';
import 'package:gts_01/ui/screens/timeline/timeline_row_labels.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';
import 'package:gts_01/ui/widgets/continuous_timeline.dart';

class TimelineBody extends StatelessWidget {
  const TimelineBody({
    super.key,
    required this.layout,
    required this.palette,
    required this.labelMode,
    required this.scrollController,
    required this.selectedId,
    required this.onBandSelect,
    required this.onSelect,
  });

  final TimelineLayoutSnapshot layout;
  final DeepTimePalette palette;
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
            const eraHeight = 52.0;
            const rowHeight = 110.0;
            const subRowHeight = 72.0;
            const stageRowHeight = 120.0;
            const rlifeRowHeight = 110.0;
            const minUnitWidth = 96.0;
            final totalUnits = layout.eonSegments.fold<double>(
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

            return Row(
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
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TimelineBands(
                                  eonSegments: layout.eonSegments,
                                  eraSegments: layout.eraSegments,
                                  palette: palette,
                                  onTapSegment: onBandSelect,
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
                              ],
                            ),
                            Positioned(
                              top: eonHeight + eraHeight - 10,
                              left: 0,
                              right: 0,
                              child: IgnorePointer(
                                child: ExtinctionMarkers(
                                  width: scrollWidth,
                                  periodSegments: layout.periodSegments,
                                  stageSegments: layout.stageSegments,
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
            );
          },
        ),
      ),
    );
  }
}
