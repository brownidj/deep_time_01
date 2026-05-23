import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:deep_time/app/app_debug.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/ui/screens/timeline/timeline_extinction_markers.dart';
import 'package:deep_time/ui/widgets/timeline_events_row.dart';

class TimelineBodyMetrics {
  TimelineBodyMetrics._({
    required this.layout,
    required this.markers,
    required this.minHeight,
    required this.labelWidth,
    required this.eonHeight,
    required this.eraHeight,
    required this.rowHeight,
    required this.subRowHeight,
    required this.stageRowHeight,
    required this.rlifeRowHeight,
    required this.eventsRowBaseHeight,
    required this.cladeRowHeight,
    required this.extinctionsRowHeight,
    required this.minUnitWidth,
    required this.eventsRowHeight,
    required this.contentHeight,
    required this.totalUnits,
    required this.periodUnits,
    required this.scrollWidth,
    required this.extinctionLayouts,
    required this.eventsRowTop,
    required this.cladeRowTop,
    required this.extinctionsRowTop,
    required this.eonEraBoundary,
    required this.rlifeBottom,
    required this.eonTotalUnits,
    required this.eraTotalUnits,
    required this.epochTotalUnits,
    required this.stageTotalUnits,
    required this.rlifeTotalUnits,
    required this.periodBoundaryXs,
    required this.eraBoundaryXs,
    required this.eonBoundaryXs,
  });

  factory TimelineBodyMetrics.fromLayout({
    required TimelineLayoutSnapshot layout,
    required TimelineMarkerCatalog markers,
    required BoxConstraints constraints,
  }) {
    const labelWidth = 96.0;
    const eonHeight = 44.0;
    const eraHeight = 72.0;
    const rowHeight = 110.0;
    const subRowHeight = 72.0;
    const stageRowHeight = 120.0;
    const rlifeRowHeight = 110.0;
    const eventsRowBaseHeight = 70.0;
    const cladeRowHeight = 140.0;
    const extinctionsRowHeight = 70.0;
    const minUnitWidth = 96.0;
    final eventsRowHeight = TimelineEventsRow.requiredHeight(
      events: layout.eventSegments,
      rowHeight: eventsRowBaseHeight,
    );
    final contentHeight =
        eonHeight +
        eraHeight +
        subRowHeight +
        subRowHeight +
        stageRowHeight +
        rlifeRowHeight +
        eventsRowHeight +
        cladeRowHeight +
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
    final eventsRowTop =
        eonHeight +
        eraHeight +
        subRowHeight +
        subRowHeight +
        stageRowHeight +
        rlifeRowHeight;
    final extinctionsRowTop = eventsRowTop + eventsRowHeight;
    final cladeRowTop = extinctionsRowTop + extinctionsRowHeight;
    final eonEraBoundary = eonHeight;
    final rlifeBottom =
        eonHeight +
        eraHeight +
        subRowHeight +
        subRowHeight +
        stageRowHeight +
        rlifeRowHeight;
    final eonTotalUnits = layout.eonSegments.fold<double>(
      0.0,
      (sum, segment) => sum + segment.unitSpan,
    );
    final eraTotalUnits = layout.eraSegments.fold<double>(
      0.0,
      (sum, segment) => sum + segment.unitSpan,
    );
    final epochTotalUnits = layout.epochSegments.fold<double>(
      0.0,
      (sum, segment) => sum + segment.unitSpan,
    );
    final stageTotalUnits = layout.stageSegments.fold<double>(
      0.0,
      (sum, segment) => sum + segment.unitSpan,
    );
    final rlifeTotalUnits = layout.rlifeSegments.fold<double>(
      0.0,
      (sum, segment) => sum + segment.unitSpan,
    );
    final periodBoundaryXs = _rowBoundaryPositions(
      layout.periodSegments,
      periodUnits,
      scrollWidth,
    );
    final eraBoundaryXs = _bandBoundaryPositions(
      layout.eraSegments,
      eraTotalUnits,
      scrollWidth,
    );
    final eonBoundaryXs = _bandBoundaryPositions(
      layout.eonSegments,
      eonTotalUnits,
      scrollWidth,
    );

    return TimelineBodyMetrics._(
      layout: layout,
      markers: markers,
      minHeight: constraints.maxHeight,
      labelWidth: labelWidth,
      eonHeight: eonHeight,
      eraHeight: eraHeight,
      rowHeight: rowHeight,
      subRowHeight: subRowHeight,
      stageRowHeight: stageRowHeight,
      rlifeRowHeight: rlifeRowHeight,
      eventsRowBaseHeight: eventsRowBaseHeight,
      cladeRowHeight: cladeRowHeight,
      extinctionsRowHeight: extinctionsRowHeight,
      minUnitWidth: minUnitWidth,
      eventsRowHeight: eventsRowHeight,
      contentHeight: contentHeight,
      totalUnits: totalUnits,
      periodUnits: periodUnits,
      scrollWidth: scrollWidth,
      extinctionLayouts: extinctionLayouts,
      eventsRowTop: eventsRowTop,
      cladeRowTop: cladeRowTop,
      extinctionsRowTop: extinctionsRowTop,
      eonEraBoundary: eonEraBoundary,
      rlifeBottom: rlifeBottom,
      eonTotalUnits: eonTotalUnits,
      eraTotalUnits: eraTotalUnits,
      epochTotalUnits: epochTotalUnits,
      stageTotalUnits: stageTotalUnits,
      rlifeTotalUnits: rlifeTotalUnits,
      periodBoundaryXs: periodBoundaryXs,
      eraBoundaryXs: eraBoundaryXs,
      eonBoundaryXs: eonBoundaryXs,
    );
  }

  final TimelineLayoutSnapshot layout;
  final TimelineMarkerCatalog markers;
  final double minHeight;
  final double labelWidth;
  final double eonHeight;
  final double eraHeight;
  final double rowHeight;
  final double subRowHeight;
  final double stageRowHeight;
  final double rlifeRowHeight;
  final double eventsRowBaseHeight;
  final double cladeRowHeight;
  final double extinctionsRowHeight;
  final double minUnitWidth;
  final double eventsRowHeight;
  final double contentHeight;
  final double totalUnits;
  final double periodUnits;
  final double scrollWidth;
  final List<ExtinctionMarkerLayout> extinctionLayouts;
  final double eventsRowTop;
  final double cladeRowTop;
  final double extinctionsRowTop;
  final double eonEraBoundary;
  final double rlifeBottom;
  final double eonTotalUnits;
  final double eraTotalUnits;
  final double epochTotalUnits;
  final double stageTotalUnits;
  final double rlifeTotalUnits;
  final List<double> periodBoundaryXs;
  final List<double> eraBoundaryXs;
  final List<double> eonBoundaryXs;

  static List<double> _rowBoundaryPositions(
    List<TimelineRowSegment> segments,
    double totalUnits,
    double scrollWidth,
  ) {
    if (segments.isEmpty || totalUnits <= 0) {
      return const [];
    }
    final positions = <double>[];
    var cursor = 0.0;
    for (var i = 0; i < segments.length - 1; i++) {
      cursor += segments[i].unitSpan;
      positions.add(scrollWidth * (cursor / totalUnits));
    }
    return positions;
  }

  static List<double> _bandBoundaryPositions(
    List<TimelineBandSegment> segments,
    double totalUnits,
    double scrollWidth,
  ) {
    if (segments.isEmpty || totalUnits <= 0) {
      return const [];
    }
    final positions = <double>[];
    var cursor = 0.0;
    for (var i = 0; i < segments.length - 1; i++) {
      cursor += segments[i].unitSpan;
      positions.add(scrollWidth * (cursor / totalUnits));
    }
    return positions;
  }
}
