import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gts_01/application/services/timeline_layout_models.dart';
import 'package:gts_01/ui/screens/timeline/timeline_event_markers.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';

void main() {
  testWidgets('Point marker label sits 3px above triangle', (tester) async {
    const events = [
      TimelineEventSegment(
        label: 'CE',
        shortLabel: 'CE',
        type: TimelineEventType.point,
        startMa: 100,
        endMa: 100,
        startUnit: 0.5,
        endUnit: 0.5,
        colorKey: '',
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 200,
            child: EventPointMarkers(
              width: 400,
              totalUnits: 1,
              events: events,
              height: 200,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final textFinder = find.text('CE');
    expect(textFinder, findsOneWidget);

    final customPaintFinder = find.descendant(
      of: find.byType(EventPointMarkers),
      matching: find.byType(CustomPaint),
    );
    expect(customPaintFinder, findsOneWidget);

    final textBottom = tester.getBottomLeft(textFinder).dy;
    final triangleTop = tester.getTopLeft(customPaintFinder).dy;

    expect((triangleTop - textBottom).round(), 3);
  });

  testWidgets('Boundary line is continuous across point markers', (
    tester,
  ) async {
    const events = [
      TimelineEventSegment(
        label: 'PETM',
        shortLabel: 'PETM',
        type: TimelineEventType.point,
        startMa: 56,
        endMa: 56,
        startUnit: 0.5,
        endUnit: 0.5,
        colorKey: '',
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 200,
            child: EventPointMarkers(
              width: 400,
              totalUnits: 1,
              events: events,
              height: 200,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final boundaryLineFinder = find.byWidgetPredicate((widget) {
      if (widget is! Container) {
        return false;
      }
      final constraints = widget.constraints;
      final height = constraints?.minHeight ?? constraints?.maxHeight;
      return height == 1 && widget.color == DeepTimePalette.periodDivider;
    });

    expect(boundaryLineFinder, findsOneWidget);
  });

  testWidgets('Point marker label is centered above triangle', (tester) async {
    const events = [
      TimelineEventSegment(
        label: 'PETM',
        shortLabel: 'PETM',
        type: TimelineEventType.point,
        startMa: 56,
        endMa: 56,
        startUnit: 0.5,
        endUnit: 0.5,
        colorKey: '',
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 200,
            child: EventPointMarkers(
              width: 400,
              totalUnits: 1,
              events: events,
              height: 200,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final textCenter = tester.getCenter(find.text('PETM'));
    final triangleCenter = tester.getCenter(
      find.descendant(
        of: find.byType(EventPointMarkers),
        matching: find.byType(CustomPaint),
      ),
    );

    expect((textCenter.dx - triangleCenter.dx).abs(), lessThanOrEqualTo(1));
  });
}
