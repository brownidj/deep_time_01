import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:deep_time/app/app_debug.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics_overlay.dart';
import 'package:deep_time/ui/screens/timeline/timeline_min_height_helpers.dart';
import 'package:deep_time/ui/screens/timeline/timeline_orientation.dart';
import 'package:deep_time/ui/screens/timeline/timeline_track_widths.dart';
import 'package:deep_time/ui/screens/timeline/timeline_vertical_overlays_helpers.dart';
import 'package:deep_time/ui/screens/timeline/timeline_vertical_overlays_line.dart';
import 'package:deep_time/ui/theme/deep_time_palette.dart';

part 'timeline_vertical_overlays_widgets.dart';

class TimelineVerticalOverlays extends StatelessWidget {
  const TimelineVerticalOverlays({
    super.key,
    required this.metrics,
    required this.contentHeight,
    required this.markers,
  });

  final TimelineBodyMetrics metrics;
  final double contentHeight;
  final TimelineMarkerCatalog markers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidths = resolveTimelineTrackWidths(
          metrics: metrics,
          maxWidth: constraints.maxWidth,
        );
        final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: DeepTimePalette.darkLabel,
          fontWeight: FontWeight.w700,
        );
        final minHeights = buildMinHeightMaps(
          metrics.layout,
          labelStyle,
          periodStyle: labelStyle,
        );
        final eonBoundaryYs = boundaryPositionsWithMinimums(
          metrics.layout.eonSegments,
          height: contentHeight,
          unitsTotal: metrics.eonTotalUnits,
          minHeights: [
            for (final segment in metrics.layout.eonSegments)
              minHeights.eonHeights[segment.id] ?? 0.0,
          ],
          unitSpan: (segment) => segment.unitSpan,
        );
        final eraBoundaryYs = boundaryPositionsWithMinimums(
          metrics.layout.eraSegments,
          height: contentHeight,
          unitsTotal: metrics.eraTotalUnits,
          minHeights: [
            for (final segment in metrics.layout.eraSegments)
              segment.isGap
                  ? minHeightFromParentRange(
                      segment.startMa,
                      segment.endMa,
                      metrics.layout.eonSegments,
                      minHeights.eonHeights,
                      (parent) => parent.startMa,
                      (parent) => parent.endMa,
                      (parent) => parent.id,
                    )
                  : (minHeights.eraHeights[segment.id] ?? 0.0),
          ],
          unitSpan: (segment) => segment.unitSpan,
        );
        final periodBoundaryYs = boundaryPositionsWithMinimums(
          metrics.layout.periodSegments,
          height: contentHeight,
          unitsTotal: metrics.periodUnits,
          minHeights: [
            for (final segment in metrics.layout.periodSegments)
              segment.isGap
                  ? minHeightFromParentRange(
                      segment.startMa,
                      segment.endMa,
                      metrics.layout.eraSegments,
                      minHeights.eraHeights,
                      (parent) => parent.startMa,
                      (parent) => parent.endMa,
                      (parent) => parent.id,
                    )
                  : (minHeights.periodHeights[segment.id] ?? 0.0),
          ],
          unitSpan: (segment) => segment.unitSpan,
        );
        final trackStarts = <TimelineTrack, double>{};
        var trackCursor = 0.0;
        for (final track in metrics.trackOrder) {
          trackCursor += metrics.gapBefore(track);
          trackStarts[track] = trackCursor;
          final width = trackWidths[track] ?? metrics.trackWidth(track);
          trackCursor += width + metrics.gapAfter(track);
        }
        final eonStart = trackStarts[TimelineTrack.eon] ?? 0.0;
        final eraStart = trackStarts[TimelineTrack.era] ?? 0.0;
        final periodStart = trackStarts[TimelineTrack.period] ?? 0.0;
        final eraPeriodBoundaryX = periodStart;
        final eventAnchorX = trackStarts[TimelineTrack.events] ?? 0.0;
        final extinctionAnchorX = trackStarts[TimelineTrack.extinctions] ?? 0.0;
        final eventLines = buildConnectorLines(
          ys: eventPointYs(
            metrics.layout.eventSegments,
            metrics.periodUnits,
            contentHeight,
          ),
          leftBoundaryX: eraPeriodBoundaryX,
          anchorX: eventAnchorX,
        );
        final extinctionLines = buildConnectorLines(
          ys: extinctionYs(
            markers.extinctions,
            metrics.layout.periodSegments,
            metrics.layout.stageSegments,
            contentHeight,
          ),
          leftBoundaryX: eraPeriodBoundaryX,
          anchorX: extinctionAnchorX,
        );
        if (kDebugMode && AppDebug.logTimelineConnectorGeometry) {
          AppDebug.log(
            'Connector geometry: '
            'periodStart=${periodStart.toStringAsFixed(2)} '
            'eventAnchor=${eventAnchorX.toStringAsFixed(2)} '
            'extAnchor=${extinctionAnchorX.toStringAsFixed(2)} '
            'eventLines=${eventLines.length} '
            'extLines=${extinctionLines.length} '
            'firstEventLine=${eventLines.isEmpty ? 'none' : '${eventLines.first.leftX.toStringAsFixed(2)}->${eventLines.first.anchorX.toStringAsFixed(2)} @y ${eventLines.first.y.toStringAsFixed(2)}'} '
            'firstExtLine=${extinctionLines.isEmpty ? 'none' : '${extinctionLines.first.leftX.toStringAsFixed(2)}->${extinctionLines.first.anchorX.toStringAsFixed(2)} @y ${extinctionLines.first.y.toStringAsFixed(2)}'}',
          );
          if (eventLines.isNotEmpty) {
            AppDebug.log(
              'Event line extent X range: '
              '${eventLines.map((l) => l.leftX).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)} '
              'to ${eventLines.map((l) => l.anchorX).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}',
            );
          }
          if (extinctionLines.isNotEmpty) {
            AppDebug.log(
              'Extinction line extent X range: '
              '${extinctionLines.map((l) => l.leftX).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)} '
              'to ${extinctionLines.map((l) => l.anchorX).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}',
            );
          }
        }
        return IgnorePointer(
          child: Stack(
            children: [
              for (final y in eonBoundaryYs)
                _HorizontalBoundaryMarker(
                  left: eonStart,
                  right: metrics.eonOverlayRight(y),
                  top: y,
                  contentHeight: contentHeight,
                ),
              for (final y in eraBoundaryYs)
                _HorizontalBoundaryMarker(
                  left: eraStart,
                  right: metrics.eraOverlayRight(y),
                  top: y,
                  contentHeight: contentHeight,
                ),
              for (final y in periodBoundaryYs)
                _HorizontalBoundaryMarker(
                  left: periodStart,
                  right: metrics.periodOverlayRight(y),
                  top: y,
                  contentHeight: contentHeight,
                ),
              for (final line in eventLines)
                OverlayLine(
                  left: line.leftX,
                  right: line.anchorX,
                  top: line.y,
                  color: const Color(0xFFFFEB3B),
                ),
              for (final line in extinctionLines)
                OverlayLine(
                  left: line.leftX,
                  right: line.anchorX,
                  top: line.y,
                  color: const Color(0xFFFF6D00),
                ),
              if (kDebugMode && AppDebug.showTimelineConnectorAnchors) ...[
                Positioned(
                  left: periodStart - 0.5,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 1, color: Colors.cyanAccent),
                ),
                Positioned(
                  left: eventAnchorX - 0.5,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 1, color: Colors.yellowAccent),
                ),
                Positioned(
                  left: extinctionAnchorX - 0.5,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 1, color: Colors.deepOrangeAccent),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
