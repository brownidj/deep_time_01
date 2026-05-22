import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gts_01/application/services/timeline_layout_service.dart';
import 'package:gts_01/domain/models/geologic_rank.dart';
import 'package:gts_01/domain/models/timeline_palette.dart';
import 'package:gts_01/domain/models/timeline_marker_catalog.dart';
import 'package:gts_01/ui/models/time_label_mode.dart';
import 'package:gts_01/ui/screens/timeline/timeline_body.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';
import 'package:gts_01/ui/widgets/continuous_timeline_row.dart';
import 'package:gts_01/ui/widgets/timeline_band_row.dart';
import 'package:gts_01/ui/widgets/timeline_events_row.dart';

void main() {
  testWidgets('Timeline rows align with static label heights', (tester) async {
    final palette = DeepTimePalette(
      const TimelinePalette(
        divisionColors: {
          'eon|test': 0xFF111111,
          'era|test': 0xFF222222,
          'period|test': 0xFF333333,
          'epoch|test': 0xFF444444,
          'stage|test': 0xFF555555,
          'rlife|test': 0xFF666666,
        },
      ),
    );

    final layout = TimelineLayoutSnapshot(
      eonSegments: const [
        TimelineBandSegment(
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
          id: 1,
          label: 'TestPeriod',
          rank: GeologicRank.period,
          startMa: 100,
          endMa: 0,
          colorKey: 'period|test',
          isGap: false,
          unitSpan: 1,
          secondaryLabel: null,
        ),
      ],
      epochSegments: const [
        TimelineRowSegment(
          id: 2,
          label: 'TestEpoch',
          rank: GeologicRank.epoch,
          startMa: 100,
          endMa: 0,
          colorKey: 'epoch|test',
          isGap: false,
          unitSpan: 1,
          secondaryLabel: null,
        ),
      ],
      stageSegments: const [
        TimelineRowSegment(
          id: 3,
          label: 'TestStage',
          rank: GeologicRank.stage,
          startMa: 100,
          endMa: 0,
          colorKey: 'stage|test',
          isGap: false,
          unitSpan: 1,
          secondaryLabel: null,
        ),
      ],
      rlifeSegments: const [
        TimelineRowSegment(
          id: 4,
          label: 'TestRLife',
          rank: GeologicRank.period,
          startMa: 100,
          endMa: 0,
          colorKey: 'rlife|test',
          isGap: false,
          unitSpan: 1,
          secondaryLabel: null,
        ),
      ],
      eventSegments: const [
        TimelineEventSegment(
          label: 'Event A',
          shortLabel: 'A',
          type: TimelineEventType.bar,
          startMa: 100,
          endMa: 60,
          startUnit: 0,
          endUnit: 1,
          colorKey: '',
        ),
        TimelineEventSegment(
          label: 'Event B',
          shortLabel: 'B',
          type: TimelineEventType.bar,
          startMa: 90,
          endMa: 70,
          startUnit: 0.1,
          endUnit: 0.9,
          colorKey: '',
        ),
        TimelineEventSegment(
          label: 'Event C',
          shortLabel: 'C',
          type: TimelineEventType.bar,
          startMa: 80,
          endMa: 75,
          startUnit: 0.2,
          endUnit: 0.8,
          colorKey: '',
        ),
      ],
      oldestMa: 100,
      youngestMa: 0,
    );
    const markers = TimelineMarkerCatalog(
      events: [],
      extinctions: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 900,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    double labelHeightFor(String text) {
      final labelFinder = find.ancestor(
        of: find.text(text),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              widget.height != null &&
              widget.child is DecoratedBox,
        ),
      );
      return tester.getSize(labelFinder).height;
    }

    final eonLabelHeight = labelHeightFor('Eon');
    final eraLabelHeight = labelHeightFor('Era');
    final periodLabelHeight = labelHeightFor('Period');
    final epochLabelHeight = labelHeightFor('Epoch');
    final ageLabelHeight = labelHeightFor('Age');
    final rlifeLabelHeight = labelHeightFor('RLife');
    final eventsLabelHeight = labelHeightFor('Events');
    final extinctionsLabelHeight = labelHeightFor('Extinctions');

    final bandRows = find.descendant(
      of: find.byType(TimelineBands),
      matching: find.byType(TimelineBandRow),
    );

    expect(bandRows, findsNWidgets(2));

    final eonBandHeight = tester.getSize(bandRows.at(0)).height;
    final eraBandHeight = tester.getSize(bandRows.at(1)).height;

    expect(eonBandHeight, eonLabelHeight);
    expect(eraBandHeight, eraLabelHeight);

    final rowWidgets = find.byType(ContinuousTimelineRow);
    expect(rowWidgets, findsNWidgets(4));

    final periodHeight = tester.getSize(rowWidgets.at(0)).height;
    final epochHeight = tester.getSize(rowWidgets.at(1)).height;
    final ageHeight = tester.getSize(rowWidgets.at(2)).height;
    final rlifeHeight = tester.getSize(rowWidgets.at(3)).height;

    expect(periodHeight, periodLabelHeight);
    expect(epochHeight, epochLabelHeight);
    expect(ageHeight, ageLabelHeight);
    expect(rlifeHeight, rlifeLabelHeight);

    final eventsRowHeight = tester.getSize(find.byType(TimelineEventsRow)).height;
    final expectedEventsHeight = TimelineEventsRow.requiredHeight(
      events: layout.eventSegments,
      rowHeight: 70.0,
    );
    expect(eventsRowHeight, expectedEventsHeight);
    expect(eventsLabelHeight, expectedEventsHeight);
    expect(extinctionsLabelHeight, 70.0);
  });
}
