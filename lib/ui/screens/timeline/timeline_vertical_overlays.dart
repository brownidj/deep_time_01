import 'package:flutter/material.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics_overlay.dart';
import 'package:deep_time/ui/screens/timeline/timeline_min_height_helpers.dart';
import 'package:deep_time/ui/screens/timeline/timeline_orientation.dart';
import 'package:deep_time/ui/theme/deep_time_palette.dart';

class TimelineVerticalOverlays extends StatelessWidget {
  const TimelineVerticalOverlays({
    super.key,
    required this.metrics,
    required this.contentHeight,
  });

  final TimelineBodyMetrics metrics;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = _widthScale(constraints.maxWidth);
        const cappedTracks = {
          TimelineTrack.ma,
          TimelineTrack.eon,
          TimelineTrack.era,
          TimelineTrack.period,
          TimelineTrack.epoch,
          TimelineTrack.stage,
          TimelineTrack.rlife,
        };
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
        final cappedWidth = cappedTracks.fold<double>(
          0.0,
          (sum, track) => sum + metrics.trackWidth(track),
        );
        double scaledX(double x) {
          if (x <= cappedWidth) {
            return x;
          }
          return cappedWidth + ((x - cappedWidth) * scale);
        }

        final eonStart = scaledX(metrics.trackX(TimelineTrack.eon));
        final eraStart = scaledX(metrics.trackX(TimelineTrack.era));
        final periodStart = scaledX(metrics.trackX(TimelineTrack.period));

        return IgnorePointer(
          child: Stack(
            children: [
              for (final y in eonBoundaryYs)
                _HorizontalBoundaryMarker(
                  left: eonStart,
                  right: scaledX(metrics.eonOverlayRight(y)),
                  top: y,
                  contentHeight: contentHeight,
                ),
              for (final y in eraBoundaryYs)
                _HorizontalBoundaryMarker(
                  left: eraStart,
                  right: scaledX(metrics.eraOverlayRight(y)),
                  top: y,
                  contentHeight: contentHeight,
                ),
              for (final y in periodBoundaryYs)
                _HorizontalBoundaryMarker(
                  left: periodStart,
                  right: scaledX(metrics.periodOverlayRight(y)),
                  top: y,
                  contentHeight: contentHeight,
                ),
            ],
          ),
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

class _HorizontalBoundaryMarker extends StatelessWidget {
  const _HorizontalBoundaryMarker({
    required this.left,
    required this.right,
    required this.top,
    required this.contentHeight,
  });

  final double left;
  final double right;
  final double top;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    final width = right - left;
    if (width <= 0) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: left,
      top: (top - 1.5).clamp(0.0, contentHeight - 3),
      width: width,
      child: Container(height: 3, color: DeepTimePalette.periodDivider),
    );
  }
}
