import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';
import 'package:deep_time/ui/screens/timeline/timeline_orientation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'timeline_layout_test_helpers.dart';

void main() {
  test(
    'default track order places paleo-ecology between continents and rlife',
    () {
      final continentsIndex = kDefaultTimelineTrackOrder.indexOf(
        TimelineTrack.continents,
      );
      final paleoIndex = kDefaultTimelineTrackOrder.indexOf(
        TimelineTrack.paleoEcology,
      );
      final rlifeIndex = kDefaultTimelineTrackOrder.indexOf(
        TimelineTrack.rlife,
      );

      expect(continentsIndex, isNonNegative);
      expect(paleoIndex, greaterThan(continentsIndex));
      expect(rlifeIndex, greaterThan(paleoIndex));
    },
  );

  test(
    'hiding continent and paleo-ecology tracks closes remaining columns',
    () {
      final layout = layoutWithLongStage();
      const markers = TimelineMarkerCatalog(events: [], extinctions: []);
      final metrics = TimelineBodyMetrics.fromLayout(
        layout: layout,
        markers: markers,
        constraints: const BoxConstraints.tightFor(width: 1200, height: 800),
        trackOrder: [
          TimelineTrack.ma,
          TimelineTrack.eon,
          TimelineTrack.era,
          TimelineTrack.period,
          TimelineTrack.epoch,
          TimelineTrack.stage,
          TimelineTrack.rlife,
          TimelineTrack.extinctions,
          TimelineTrack.events,
          TimelineTrack.clades,
        ],
      );

      expect(metrics.trackOrder.contains(TimelineTrack.continents), isFalse);
      expect(metrics.trackOrder.contains(TimelineTrack.paleoEcology), isFalse);
      expect(
        metrics.trackX(TimelineTrack.rlife),
        metrics.trackX(TimelineTrack.stage) +
            metrics.trackWidth(TimelineTrack.stage),
      );
    },
  );
}
