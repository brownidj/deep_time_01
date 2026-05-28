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

  test('hiding hideable tracks closes remaining columns', () {
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
        TimelineTrack.extinctions,
        TimelineTrack.events,
        TimelineTrack.clades,
      ],
    );

    expect(metrics.trackOrder.contains(TimelineTrack.continents), isFalse);
    expect(metrics.trackOrder.contains(TimelineTrack.paleoEcology), isFalse);
    expect(metrics.trackOrder.contains(TimelineTrack.rlife), isFalse);
    expect(
      metrics.trackX(TimelineTrack.extinctions),
      metrics.trackX(TimelineTrack.stage) +
          metrics.trackWidth(TimelineTrack.stage),
    );
  });

  test(
    'gap policy keeps fixed columns tight and hideable columns left-guttered',
    () {
      final layout = layoutWithLongStage();
      const markers = TimelineMarkerCatalog(events: [], extinctions: []);
      final metrics = TimelineBodyMetrics.fromLayout(
        layout: layout,
        markers: markers,
        constraints: const BoxConstraints.tightFor(width: 1200, height: 800),
      );

      expect(metrics.gapAfter(TimelineTrack.eon), 0);
      expect(metrics.gapAfter(TimelineTrack.era), 0);
      expect(metrics.gapAfter(TimelineTrack.period), 0);
      expect(metrics.gapAfter(TimelineTrack.epoch), 0);
      expect(metrics.gapAfter(TimelineTrack.stage), 0);
      expect(metrics.gapAfter(TimelineTrack.continents), 0);
      expect(metrics.gapAfter(TimelineTrack.paleoEcology), 0);
      expect(metrics.gapAfter(TimelineTrack.rlife), 0);
      expect(metrics.gapBefore(TimelineTrack.ma), 0);
      expect(metrics.gapBefore(TimelineTrack.eon), 0);
      expect(metrics.gapBefore(TimelineTrack.stage), 0);
      expect(
        metrics.gapBefore(TimelineTrack.continents),
        kTimelineStandardInterColumnGap,
      );
      expect(
        metrics.gapBefore(TimelineTrack.paleoEcology),
        kTimelineStandardInterColumnGap,
      );
      expect(
        metrics.gapBefore(TimelineTrack.rlife),
        kTimelineStandardInterColumnGap,
      );
      expect(metrics.gapBefore(TimelineTrack.extinctions), 0);
    },
  );

  test('extinction column butts against the visible column to its left', () {
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
        TimelineTrack.continents,
        TimelineTrack.paleoEcology,
        TimelineTrack.extinctions,
        TimelineTrack.events,
        TimelineTrack.clades,
      ],
    );

    expect(
      metrics.trackX(TimelineTrack.extinctions),
      metrics.trackX(TimelineTrack.paleoEcology) +
          metrics.trackWidth(TimelineTrack.paleoEcology),
    );
  });
}
