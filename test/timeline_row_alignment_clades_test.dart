import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deep_time/domain/models/clade.dart';
import 'package:deep_time/domain/models/clade_zoom_level.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/ui/models/clade_view_mode.dart';
import 'package:deep_time/ui/models/time_label_mode.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body.dart';
import 'package:deep_time/ui/screens/timeline/timeline_orientation.dart';

import 'timeline_row_alignment_helpers.dart';

void main() {
  testWidgets('Vertical clade tree indents children and aligns range dates', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final palette = testPalette();
    final layout = splitPeriodLayout();
    const markers = TimelineMarkerCatalog(events: [], extinctions: []);
    const clades = [
      Clade(
        id: 'parent_clade',
        label: 'Parent Clade',
        scientificRank: 'test',
        startMa: 100,
        endMa: 0,
        displayGroups: ['all'],
        displayPriority: 0,
        minZoomLevel: CladeZoomLevel.whole,
      ),
      Clade(
        id: 'child_clade',
        label: 'Child Clade',
        scientificRank: 'test',
        parentId: 'parent_clade',
        startMa: 50,
        endMa: 0,
        displayGroups: ['all'],
        displayPriority: 1,
        minZoomLevel: CladeZoomLevel.whole,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 2000,
            height: 1200,
            child: Column(
              children: [
                TimelineBody(
                  layout: layout,
                  palette: palette,
                  markers: markers,
                  labelMode: TimeLabelMode.geologicTime,
                  scrollController: ScrollController(),
                  selectedId: null,
                  onBandSelect: (_) {},
                  onSelect: (_) {},
                  clades: clades,
                  cladeViewMode: CladeViewMode.representativeOnly,
                  cladeCategoryId: 'all',
                  cladeRepresentativeIds: const [],
                  cladeSearchQuery: '',
                  cladeSpotlightId: null,
                  onCladeSpotlight: (_) {},
                  visibleTracks: {...kDefaultTimelineTrackOrder}
                    ..remove(TimelineTrack.paleoEcology),
                  paleoEcology: const [],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final columnRect = tester.getRect(
      find.byKey(const ValueKey('vertical-clade-column')),
    );
    final parentRect = tester.getRect(
      find.byKey(const ValueKey('vertical-clade-parent_clade')),
    );
    final childRect = tester.getRect(
      find.byKey(const ValueKey('vertical-clade-child_clade')),
    );

    expect(childRect.left, greaterThan(parentRect.left));
    expect(
      (childRect.top - (columnRect.top + columnRect.height / 2)).abs(),
      lessThanOrEqualTo(4.0),
    );
    expect(
      (childRect.height - (columnRect.height / 2)).abs(),
      lessThanOrEqualTo(4.0),
    );
    expect(
      find.byKey(
        const ValueKey('vertical-clade-connector-parent_clade-child_clade'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Representative clade view keeps ancestors for tree connectors', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final palette = testPalette();
    final layout = splitPeriodLayout();
    const markers = TimelineMarkerCatalog(events: [], extinctions: []);
    const clades = [
      Clade(
        id: 'parent_clade',
        label: 'Parent Clade',
        scientificRank: 'test',
        startMa: 100,
        endMa: 0,
        displayGroups: ['all'],
        displayPriority: 0,
        minZoomLevel: CladeZoomLevel.whole,
      ),
      Clade(
        id: 'child_clade',
        label: 'Child Clade',
        scientificRank: 'test',
        parentId: 'parent_clade',
        startMa: 50,
        endMa: 0,
        displayGroups: ['all'],
        displayPriority: 1,
        minZoomLevel: CladeZoomLevel.whole,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 2000,
            height: 1200,
            child: Column(
              children: [
                TimelineBody(
                  layout: layout,
                  palette: palette,
                  markers: markers,
                  labelMode: TimeLabelMode.geologicTime,
                  scrollController: ScrollController(),
                  selectedId: null,
                  onBandSelect: (_) {},
                  onSelect: (_) {},
                  clades: clades,
                  cladeViewMode: CladeViewMode.representativeOnly,
                  cladeCategoryId: 'all',
                  cladeRepresentativeIds: const ['child_clade'],
                  cladeSearchQuery: '',
                  cladeSpotlightId: null,
                  onCladeSpotlight: (_) {},
                  visibleTracks: {...kDefaultTimelineTrackOrder}
                    ..remove(TimelineTrack.paleoEcology),
                  paleoEcology: const [],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('vertical-clade-parent_clade')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('vertical-clade-child_clade')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('vertical-clade-connector-parent_clade-child_clade'),
      ),
      findsOneWidget,
    );
  });
}

Future<void> _setLargeSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(2000, 1200));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}
