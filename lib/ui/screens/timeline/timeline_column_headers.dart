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
          TimelineTrack.ma,
          TimelineTrack.eon,
          TimelineTrack.era,
          TimelineTrack.period,
          TimelineTrack.epoch,
          TimelineTrack.stage,
          TimelineTrack.paleoEcology,
          TimelineTrack.rlife,
          TimelineTrack.extinctions,
          TimelineTrack.continents,
        };
        double scaledWidth(TimelineTrack track) =>
            metrics.trackWidth(track) *
            (cappedTracks.contains(track) ? 1.0 : scale);
        return SizedBox(
          height: metrics.headerHeight,
          child: Row(
            children: [
              for (final track in metrics.trackOrder) ...[
                SizedBox(
                  width: scaledWidth(track),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: DeepTimePalette.frameBorder,
                      border: Border.all(color: DeepTimePalette.frameBorder),
                    ),
                    child: Center(
                      child: Text(
                        _labelFor(track),
                        style: labelStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                if (metrics.gapAfter(track) > 0)
                  SizedBox(width: metrics.gapAfter(track)),
              ],
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
    final cappedTracks = <TimelineTrack>{
      TimelineTrack.ma,
      TimelineTrack.eon,
      TimelineTrack.era,
      TimelineTrack.period,
      TimelineTrack.epoch,
      TimelineTrack.stage,
      TimelineTrack.paleoEcology,
      TimelineTrack.rlife,
      TimelineTrack.extinctions,
      TimelineTrack.continents,
    };
    var fixed = 0.0;
    var scalable = 0.0;
    for (final track in metrics.trackOrder) {
      final width = metrics.trackWidth(track);
      if (cappedTracks.contains(track)) {
        fixed += width;
      } else {
        scalable += width;
      }
      fixed += metrics.gapAfter(track);
    }
    if (scalable <= 0) {
      return 1.0;
    }
    final available = (maxWidth - fixed).clamp(0.0, double.infinity);
    return available / scalable;
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
      case TimelineTrack.paleoEcology:
        return 'Paleo-ecology';
      case TimelineTrack.events:
        return 'Events';
      case TimelineTrack.extinctions:
        return 'Ext.';
      case TimelineTrack.continents:
        return 'Landmasses';
      case TimelineTrack.clades:
        return 'Clades';
      case TimelineTrack.ma:
        return 'Ma\n4567';
    }
  }

  // Header labels are horizontal.
}
