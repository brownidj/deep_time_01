import 'package:flutter/material.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics_overlay.dart';
import 'package:deep_time/ui/screens/timeline/timeline_event_markers.dart';
import 'package:deep_time/ui/screens/timeline/timeline_extinction_markers.dart';
import 'package:deep_time/ui/theme/deep_time_palette.dart';

class TimelineBodyOverlays extends StatelessWidget {
  const TimelineBodyOverlays({
    super.key,
    required this.layout,
    required this.metrics,
  });

  final TimelineLayoutSnapshot layout;
  final TimelineBodyMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _TimelineBoundaryOverlays(metrics: metrics),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: SizedBox(
              height: metrics.contentHeight,
              child: EventPointMarkers(
                width: metrics.scrollWidth,
                totalUnits: metrics.periodUnits,
                events: layout.eventSegments,
                height: metrics.contentHeight,
                lineTop: metrics.eonHeight + metrics.eraHeight,
                markerTop:
                    metrics.eventsRowTop +
                    metrics.eventsRowHeight -
                    EventPointMarkers.markerHeight,
                showMarkers: false,
                showLines: true,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: metrics.contentHeight,
            child: EventPointMarkers(
              width: metrics.scrollWidth,
              totalUnits: metrics.periodUnits,
              events: layout.eventSegments,
              height: metrics.contentHeight,
              lineTop: metrics.eonHeight + metrics.eraHeight,
              markerTop:
                  metrics.eventsRowTop +
                  metrics.eventsRowHeight -
                  EventPointMarkers.markerHeight,
              showMarkers: true,
              showLines: false,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: metrics.contentHeight,
            child: EventPointMarkers(
              width: metrics.scrollWidth,
              totalUnits: metrics.periodUnits,
              events: layout.eventSegments,
              height: metrics.contentHeight,
              lineTop: metrics.eonHeight + metrics.eraHeight,
              markerTop:
                  metrics.eventsRowTop +
                  metrics.eventsRowHeight -
                  EventPointMarkers.markerHeight,
              showMarkers: false,
              showLines: false,
              showLineHitTargets: true,
            ),
          ),
        ),
        Positioned(
          top: metrics.eonEraBoundary,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: SizedBox(
              height: metrics.contentHeight - metrics.eonEraBoundary,
              child: ExtinctionMarkers(
                width: metrics.scrollWidth,
                height: metrics.contentHeight - metrics.eonEraBoundary,
                lineTop: 0,
                triangleTip: metrics.extinctionsRowTop - metrics.eonEraBoundary,
                periodSegments: layout.periodSegments,
                stageSegments: layout.stageSegments,
                markerLayouts: metrics.extinctionLayouts,
                showMarkers: false,
                showLines: true,
              ),
            ),
          ),
        ),
        Positioned(
          top: metrics.eonEraBoundary,
          left: 0,
          right: 0,
          child: SizedBox(
            height: metrics.contentHeight - metrics.eonEraBoundary,
            child: ExtinctionMarkers(
              width: metrics.scrollWidth,
              height: metrics.contentHeight - metrics.eonEraBoundary,
              lineTop: 0,
              triangleTip: metrics.extinctionsRowTop - metrics.eonEraBoundary,
              periodSegments: layout.periodSegments,
              stageSegments: layout.stageSegments,
              markerLayouts: metrics.extinctionLayouts,
              showMarkers: true,
              showLines: false,
            ),
          ),
        ),
        Positioned(
          top: metrics.eonEraBoundary,
          left: 0,
          right: 0,
          child: SizedBox(
            height: metrics.contentHeight - metrics.eonEraBoundary,
            child: ExtinctionMarkers(
              width: metrics.scrollWidth,
              height: metrics.contentHeight - metrics.eonEraBoundary,
              lineTop: 0,
              triangleTip: metrics.extinctionsRowTop - metrics.eonEraBoundary,
              periodSegments: layout.periodSegments,
              stageSegments: layout.stageSegments,
              markerLayouts: metrics.extinctionLayouts,
              showMarkers: false,
              showLines: false,
              showLineHitTargets: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineBoundaryOverlays extends StatelessWidget {
  const _TimelineBoundaryOverlays({required this.metrics});

  final TimelineBodyMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: SizedBox(
          height: metrics.rlifeBottom,
          child: Stack(
            children: [
              for (final x in metrics.eonBoundaryXs)
                _BoundaryMarker(
                  left: x,
                  top: 0,
                  bottom: metrics.eonOverlayBottom(x),
                  scrollWidth: metrics.scrollWidth,
                ),
              for (final x in metrics.eraBoundaryXs)
                _BoundaryMarker(
                  left: x,
                  top: metrics.eonHeight,
                  bottom: metrics.eraOverlayBottom(x),
                  scrollWidth: metrics.scrollWidth,
                ),
              for (final x in metrics.periodBoundaryXs)
                _BoundaryMarker(
                  left: x,
                  top: metrics.eonHeight + metrics.eraHeight,
                  bottom: metrics.periodOverlayBottom(x),
                  scrollWidth: metrics.scrollWidth,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoundaryMarker extends StatelessWidget {
  const _BoundaryMarker({
    required this.left,
    required this.top,
    required this.bottom,
    required this.scrollWidth,
  });

  final double left;
  final double top;
  final double bottom;
  final double scrollWidth;

  @override
  Widget build(BuildContext context) {
    final height = bottom - top;
    if (height <= 0) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: (left - 1.5).clamp(0.0, scrollWidth - 3),
      top: top,
      height: height,
      child: Container(width: 3, color: DeepTimePalette.periodDivider),
    );
  }
}
