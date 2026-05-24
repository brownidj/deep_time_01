import 'package:flutter/material.dart';
import 'package:deep_time/ui/models/time_label_mode.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';
import 'package:deep_time/ui/screens/timeline/timeline_orientation.dart';
import 'package:deep_time/ui/theme/deep_time_palette.dart';

class TimelineColumnHeaders extends StatelessWidget {
  const TimelineColumnHeaders({
    super.key,
    required this.metrics,
    required this.labelMode,
  });

  final TimelineBodyMetrics metrics;
  final TimeLabelMode labelMode;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: DeepTimePalette.panelText,
      fontWeight: FontWeight.w700,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = _widthScale(constraints.maxWidth);
        final cappedTracks = <TimelineTrack>{
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
        return SizedBox(
          height: metrics.headerHeight,
          child: Row(
            children: [
              for (final track in metrics.trackOrder)
                SizedBox(
                  width: scaledWidth(track),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: DeepTimePalette.frameBorder,
                      border: Border.all(color: DeepTimePalette.frameBorder),
                    ),
                    child: Center(
                      child: Text(_labelFor(track), style: labelStyle),
                    ),
                  ),
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

  String _labelFor(TimelineTrack track) {
    switch (track) {
      case TimelineTrack.eon:
        return labelMode.labelForRank('eon');
      case TimelineTrack.era:
        return labelMode.labelForRank('era');
      case TimelineTrack.period:
        return labelMode.divisionRowLabel();
      case TimelineTrack.epoch:
        return labelMode.seriesRowLabel();
      case TimelineTrack.stage:
        return labelMode.stageRowLabel();
      case TimelineTrack.rlife:
        return 'Representative life';
      case TimelineTrack.events:
        return 'Events';
      case TimelineTrack.extinctions:
        return 'Extinctions';
      case TimelineTrack.clades:
        return 'Clades';
    }
  }

  // Header labels are horizontal.
}
