import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/domain/models/geologic_rank.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/ui/models/clade_view_mode.dart';
import 'package:deep_time/ui/models/time_label_mode.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body.dart';

import 'timeline_row_alignment_helpers.dart';

void main() {
  testWidgets('Stage blocks have minimum height for horizontal labels', (
    tester,
  ) async {
    final layout = _cascadeLayout();
    final palette = testPalette();
    const markers = TimelineMarkerCatalog(events: [], extinctions: []);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 420,
            child: TimelineBody(
              layout: layout,
              palette: palette,
              markers: markers,
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
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final stageFinder = find.text('StageOne');
    expect(stageFinder, findsOneWidget);

    final stageText = tester.widget<Text>(stageFinder);
    final stageStyle = stageText.style;
    expect(stageStyle, isNotNull);

    final painter = TextPainter(
      text: TextSpan(text: 'StageOne', style: stageStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final minStageHeight = painter.height + 8;

    final stageBox = _findNearestSizedBoxHeight(tester, stageFinder);
    expect(stageBox, isNotNull);
    expect(stageBox! + 0.1, greaterThanOrEqualTo(minStageHeight));
  });

  testWidgets('Epoch/Period/Era/Eon heights cover their stage blocks', (
    tester,
  ) async {
    final layout = _cascadeLayout();
    final palette = testPalette();
    const markers = TimelineMarkerCatalog(events: [], extinctions: []);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 420,
            child: TimelineBody(
              layout: layout,
              palette: palette,
              markers: markers,
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
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final stageFinder = find.text('StageOne');
    final stageText = tester.widget<Text>(stageFinder);
    final stageStyle = stageText.style;
    expect(stageStyle, isNotNull);

    final stagePainter = TextPainter(
      text: TextSpan(text: 'StageOne', style: stageStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final minStageHeight = stagePainter.height + 8;
    final requiredTotal = minStageHeight * 2;

    final epochHeight = _findNearestSizedBoxHeight(
      tester,
      find.text('TestEpoch'),
    );
    final periodHeight = _findNearestSizedBoxHeight(
      tester,
      find.text('TestPeriod'),
    );
    final eraHeight = _findNearestSizedBoxHeight(tester, find.text('TestEra'));
    final eonHeight = _findNearestSizedBoxHeight(tester, find.text('TestEon'));

    expect(epochHeight, isNotNull);
    expect(periodHeight, isNotNull);
    expect(eraHeight, isNotNull);
    expect(eonHeight, isNotNull);

    expect(epochHeight! + 0.1, greaterThanOrEqualTo(requiredTotal));
    expect(periodHeight! + 0.1, greaterThanOrEqualTo(requiredTotal));
    expect(eraHeight! + 0.1, greaterThanOrEqualTo(requiredTotal));
    expect(eonHeight! + 0.1, greaterThanOrEqualTo(requiredTotal));
  });

  testWidgets('Stage column width fits longest stage label', (tester) async {
    final layout = _layoutWithLongStage();
    final palette = testPalette();
    const markers = TimelineMarkerCatalog(events: [], extinctions: []);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 420,
            child: TimelineBody(
              layout: layout,
              palette: palette,
              markers: markers,
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
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    const longLabel = 'Wuchiapingian';
    final stageFinder = find.text(longLabel);
    expect(stageFinder, findsOneWidget);

    final stageText = tester.widget<Text>(stageFinder);
    final stageStyle = stageText.style;
    expect(stageStyle, isNotNull);

    final painter = TextPainter(
      text: TextSpan(text: longLabel, style: stageStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final requiredWidth = painter.width + 12;

    final tileWidth = _findNearestSizedBoxWidth(tester, stageFinder);
    expect(tileWidth, isNotNull);
    expect(tileWidth! + 0.1, greaterThanOrEqualTo(requiredWidth));
  });

  testWidgets('Pre-Cambrian periods without epochs use label-length height', (
    tester,
  ) async {
    final layout = _precambrianPeriodLayout();
    final palette = testPalette();
    const markers = TimelineMarkerCatalog(events: [], extinctions: []);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 420,
            child: TimelineBody(
              layout: layout,
              palette: palette,
              markers: markers,
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
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    const periodLabel = 'Ediacaran';
    final periodFinder = find.text(periodLabel);
    expect(periodFinder, findsOneWidget);

    final periodText = tester.widget<Text>(periodFinder);
    final periodStyle = periodText.style;
    expect(periodStyle, isNotNull);

    final painter = TextPainter(
      text: TextSpan(text: periodLabel, style: periodStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final requiredHeight = painter.width + 8;

    final tileHeight = _findNearestSizedBoxHeight(tester, periodFinder);
    expect(tileHeight, isNotNull);
    expect(tileHeight! + 0.1, greaterThanOrEqualTo(requiredHeight));
  });
}

TimelineLayoutSnapshot _cascadeLayout() {
  return const TimelineLayoutSnapshot(
    eonSegments: [
      TimelineBandSegment(
        id: 1,
        label: 'TestEon',
        rank: GeologicRank.eon,
        startMa: 600,
        endMa: 0,
        colorKey: 'eon|test',
        isGap: false,
        unitSpan: 2,
      ),
    ],
    eraSegments: [
      TimelineBandSegment(
        id: 2,
        label: 'TestEra',
        rank: GeologicRank.era,
        startMa: 600,
        endMa: 0,
        colorKey: 'era|test',
        isGap: false,
        unitSpan: 2,
      ),
    ],
    periodSegments: [
      TimelineRowSegment(
        id: 3,
        label: 'TestPeriod',
        rank: GeologicRank.period,
        startMa: 600,
        endMa: 0,
        colorKey: 'period|test',
        isGap: false,
        unitSpan: 2,
      ),
    ],
    epochSegments: [
      TimelineRowSegment(
        id: 4,
        label: 'TestEpoch',
        rank: GeologicRank.epoch,
        startMa: 600,
        endMa: 0,
        colorKey: 'epoch|test',
        isGap: false,
        unitSpan: 2,
      ),
    ],
    stageSegments: [
      TimelineRowSegment(
        id: 5,
        label: 'StageOne',
        rank: GeologicRank.stage,
        startMa: 600,
        endMa: 300,
        colorKey: 'stage|test',
        isGap: false,
        unitSpan: 1,
      ),
      TimelineRowSegment(
        id: 6,
        label: 'StageTwo',
        rank: GeologicRank.stage,
        startMa: 300,
        endMa: 0,
        colorKey: 'stage|test',
        isGap: false,
        unitSpan: 1,
      ),
    ],
    rlifeSegments: [],
    eventSegments: [],
    oldestMa: 600,
    youngestMa: 0,
  );
}

TimelineLayoutSnapshot _layoutWithLongStage() {
  return const TimelineLayoutSnapshot(
    eonSegments: [
      TimelineBandSegment(
        id: 1,
        label: 'TestEon',
        rank: GeologicRank.eon,
        startMa: 600,
        endMa: 0,
        colorKey: 'eon|test',
        isGap: false,
        unitSpan: 2,
      ),
    ],
    eraSegments: [
      TimelineBandSegment(
        id: 2,
        label: 'TestEra',
        rank: GeologicRank.era,
        startMa: 600,
        endMa: 0,
        colorKey: 'era|test',
        isGap: false,
        unitSpan: 2,
      ),
    ],
    periodSegments: [
      TimelineRowSegment(
        id: 3,
        label: 'TestPeriod',
        rank: GeologicRank.period,
        startMa: 600,
        endMa: 0,
        colorKey: 'period|test',
        isGap: false,
        unitSpan: 2,
      ),
    ],
    epochSegments: [
      TimelineRowSegment(
        id: 4,
        label: 'TestEpoch',
        rank: GeologicRank.epoch,
        startMa: 600,
        endMa: 0,
        colorKey: 'epoch|test',
        isGap: false,
        unitSpan: 2,
      ),
    ],
    stageSegments: [
      TimelineRowSegment(
        id: 5,
        label: 'Wuchiapingian',
        rank: GeologicRank.stage,
        startMa: 600,
        endMa: 300,
        colorKey: 'stage|test',
        isGap: false,
        unitSpan: 1,
      ),
      TimelineRowSegment(
        id: 6,
        label: 'StageTwo',
        rank: GeologicRank.stage,
        startMa: 300,
        endMa: 0,
        colorKey: 'stage|test',
        isGap: false,
        unitSpan: 1,
      ),
    ],
    rlifeSegments: [],
    eventSegments: [],
    oldestMa: 600,
    youngestMa: 0,
  );
}

TimelineLayoutSnapshot _precambrianPeriodLayout() {
  return const TimelineLayoutSnapshot(
    eonSegments: [
      TimelineBandSegment(
        id: 1,
        label: 'TestEon',
        rank: GeologicRank.eon,
        startMa: 2500,
        endMa: 541,
        colorKey: 'eon|test',
        isGap: false,
        unitSpan: 1,
      ),
    ],
    eraSegments: [
      TimelineBandSegment(
        id: 2,
        label: 'TestEra',
        rank: GeologicRank.era,
        startMa: 2500,
        endMa: 541,
        colorKey: 'era|test',
        isGap: false,
        unitSpan: 1,
      ),
    ],
    periodSegments: [
      TimelineRowSegment(
        id: 3,
        label: 'Ediacaran',
        rank: GeologicRank.period,
        startMa: 635,
        endMa: 541,
        colorKey: 'period|test',
        isGap: false,
        unitSpan: 1,
      ),
    ],
    epochSegments: [],
    stageSegments: [],
    rlifeSegments: [],
    eventSegments: [],
    oldestMa: 2500,
    youngestMa: 541,
  );
}

double? _findNearestSizedBoxHeight(WidgetTester tester, Finder textFinder) {
  final sizedBoxes = find.ancestor(
    of: textFinder,
    matching: find.byType(SizedBox),
  );
  for (final element in sizedBoxes.evaluate()) {
    final widget = element.widget;
    if (widget is SizedBox && widget.height != null) {
      return widget.height;
    }
  }
  return null;
}

double? _findNearestSizedBoxWidth(WidgetTester tester, Finder textFinder) {
  final sizedBoxes = find.ancestor(
    of: textFinder,
    matching: find.byType(SizedBox),
  );
  for (final element in sizedBoxes.evaluate()) {
    final widget = element.widget;
    if (widget is SizedBox && widget.width != null) {
      return widget.width;
    }
  }
  return null;
}
