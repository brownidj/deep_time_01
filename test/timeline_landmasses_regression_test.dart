import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/domain/models/geologic_rank.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/domain/models/timeline_palette.dart';
import 'package:deep_time/ui/models/clade_view_mode.dart';
import 'package:deep_time/ui/models/time_label_mode.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body.dart';
import 'package:deep_time/ui/screens/timeline/timeline_orientation.dart';
import 'package:deep_time/ui/screens/timeline/timeline_settings_dialog.dart';
import 'package:deep_time/ui/theme/deep_time_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Settings and headers use Landmasses label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TimelineSettingsDialog(
          labelMode: TimeLabelMode.geologicTime,
          onScaleChanged: (_) {},
          cladeViewMode: CladeViewMode.representativeOnly,
          cladeCategoryId: 'all',
          cladeDisplayGroups: const [],
          onCladeViewModeChanged: (_) {},
          onCladeCategoryChanged: (_) {},
          visibleTracks: {...kDefaultTimelineTrackOrder},
          onTrackVisibilityChanged: (_, _) {},
        ),
      ),
    );

    expect(find.text('Landmasses'), findsOneWidget);
  });

  testWidgets('Landmasses bars expand to fill lane width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(2200, 1400));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final palette = DeepTimePalette(
      const TimelinePalette(
        divisionColors: {
          'eon|test': 0xFF111111,
          'era|test': 0xFF222222,
          'period|test': 0xFF333333,
          'epoch|test': 0xFF444444,
          'stage|test': 0xFF555555,
          'rlife|test': 0xFF666666,
          'continent|test': 0xFF88BB88,
        },
      ),
    );

    final layout = TimelineLayoutSnapshot(
      divisions: const [],
      eonSegments: const [
        TimelineBandSegment(
          id: 1,
          label: 'TestEon',
          rank: GeologicRank.eon,
          startMa: 100,
          endMa: 0,
          colorKey: 'eon|test',
          isGap: false,
          unitSpan: 1,
        ),
      ],
      eraSegments: const [
        TimelineBandSegment(
          id: 2,
          label: 'TestEra',
          rank: GeologicRank.era,
          startMa: 100,
          endMa: 0,
          colorKey: 'era|test',
          isGap: false,
          unitSpan: 1,
        ),
      ],
      periodSegments: const [
        TimelineRowSegment(
          id: 3,
          label: 'TestPeriod',
          rank: GeologicRank.period,
          startMa: 100,
          endMa: 0,
          colorKey: 'period|test',
          isGap: false,
          unitSpan: 1,
        ),
      ],
      epochSegments: const [
        TimelineRowSegment(
          id: 4,
          label: 'TestEpoch',
          rank: GeologicRank.epoch,
          startMa: 100,
          endMa: 0,
          colorKey: 'epoch|test',
          isGap: false,
          unitSpan: 1,
        ),
      ],
      stageSegments: const [
        TimelineRowSegment(
          id: 5,
          label: 'TestStage',
          rank: GeologicRank.stage,
          startMa: 100,
          endMa: 0,
          colorKey: 'stage|test',
          isGap: false,
          unitSpan: 1,
        ),
      ],
      rlifeSegments: const [
        TimelineRowSegment(
          id: 6,
          label: 'RLife',
          rank: GeologicRank.stage,
          startMa: 100,
          endMa: 0,
          colorKey: 'rlife|test',
          isGap: false,
          unitSpan: 1,
        ),
      ],
      eventSegments: const [],
      continentSegments: const [
        TimelineEventSegment(
          label: 'TestLand',
          shortLabel: 'TestLand',
          type: TimelineEventType.bar,
          startMa: 100,
          endMa: 0,
          startUnit: 1,
          endUnit: 0,
          colorKey: 'continent|test',
        ),
      ],
      oldestMa: 100,
      youngestMa: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 2200,
            height: 1400,
            child: Column(
              children: [
                TimelineBody(
                  layout: layout,
                  palette: palette,
                  markers: const TimelineMarkerCatalog(
                    events: [],
                    extinctions: [],
                  ),
                  labelMode: TimeLabelMode.geologicTime,
                  scrollController: ScrollController(),
                  selectedId: null,
                  onBandSelect: (_) {},
                  onSelect: (_) {},
                  clades: const [],
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

    final bar = find.byKey(const ValueKey('vertical-event-bar-TestLand-0'));
    expect(bar, findsOneWidget);
    final barWidth = tester.getRect(bar).width;

    expect(barWidth, greaterThan(40));
  });
}
