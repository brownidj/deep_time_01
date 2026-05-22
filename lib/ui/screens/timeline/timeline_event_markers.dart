import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gts_01/application/services/timeline_layout_service.dart';
import 'package:gts_01/ui/screens/timeline/timeline_extinction_markers.dart';
import 'package:gts_01/ui/theme/deep_time_palette.dart';

class EventPointMarkers extends StatelessWidget {
  const EventPointMarkers({
    super.key,
    required this.width,
    required this.totalUnits,
    required this.events,
    required this.height,
    this.extinctionMarkers = const [],
  });

  final double width;
  final double totalUnits;
  final List<TimelineEventSegment> events;
  final double height;
  final List<ExtinctionMarkerLayout> extinctionMarkers;

  static const markerHeight = 14.0;
  static const triangleWidth = 12.0;
  static const markerColor = Color(0xFFFFEB3B);

  @override
  Widget build(BuildContext context) {
    if (totalUnits <= 0 || !width.isFinite || width <= 0) {
      return const SizedBox.shrink();
    }
    final pointEvents = events
        .where((event) => event.type == TimelineEventType.point)
        .toList();
    if (pointEvents.isEmpty) {
      return const SizedBox.shrink();
    }
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.w700,
    );
    if (labelStyle == null) {
      return const SizedBox.shrink();
    }
    final majorStyle = labelStyle.copyWith(
      fontSize: (labelStyle.fontSize ?? 12) + 4,
    );
    final stackedLevels = <List<_Span>>[
      _extinctionSpans(labelStyle, majorStyle),
    ];
    final markerOffsets = <TimelineEventSegment, double>{};
    for (final event in pointEvents) {
      final center = (event.startUnit / totalUnits * width);
      if (!center.isFinite) {
        continue;
      }
      final textPainter = TextPainter(
        text: TextSpan(text: event.shortLabel, style: labelStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      final markerWidth = math.max(textPainter.width, triangleWidth);
      final span = _Span(center: center, halfWidth: markerWidth / 2);
      var levelIndex = 0;
      while (true) {
        if (levelIndex >= stackedLevels.length) {
          stackedLevels.add([]);
        }
        final overlaps = stackedLevels[levelIndex].any(
          (existing) => existing.overlaps(span, padding: 4),
        );
        if (!overlaps) {
          stackedLevels[levelIndex].add(span);
          markerOffsets[event] = levelIndex * (textPainter.height + 10);
          break;
        }
        levelIndex += 1;
      }
    }
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final event in pointEvents)
            if ((event.startUnit / totalUnits * width).isFinite)
              Positioned(
                left: (event.startUnit / totalUnits * width).clamp(0.0, width),
                child: FractionalTranslation(
                  translation: const Offset(-0.5, 0),
                  child: _EventMarker(
                    label: event.shortLabel,
                    verticalOffset: markerOffsets[event] ?? 0,
                  ),
                ),
              ),
          for (final event in pointEvents)
            if ((event.startUnit / totalUnits * width).isFinite &&
                (markerOffsets[event] ?? 0) > 0)
              Positioned(
                left: (event.startUnit / totalUnits * width - 0.5)
                    .clamp(0.0, width - 1),
                top: markerHeight - (markerOffsets[event] ?? 0),
                height: markerOffsets[event] ?? 0,
                child: Container(
                  width: 1,
                  color: markerColor,
                ),
              ),
          for (final event in pointEvents)
            Positioned(
              left: (event.startUnit / totalUnits * width - 0.5)
                  .clamp(0.0, width - 1),
              top: markerHeight,
              bottom: 0,
              child: Container(
                width: 1,
                color: markerColor,
              ),
            ),
          Positioned(
            top: markerHeight,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: DeepTimePalette.periodDivider,
            ),
          ),
        ],
      ),
    );
  }

  List<_Span> _extinctionSpans(TextStyle baseStyle, TextStyle majorStyle) {
    if (extinctionMarkers.isEmpty) {
      return [];
    }
    final spans = <_Span>[];
    for (final marker in extinctionMarkers) {
      final label = marker.isMajor ? marker.label : marker.shortLabel;
      final style = marker.isMajor ? majorStyle : baseStyle;
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      final triangle = marker.isMajor
          ? ExtinctionMarkers.majorTriangleWidth
          : ExtinctionMarkers.triangleWidth;
      final markerWidth = math.max(textPainter.width, triangle);
      spans.add(_Span(center: marker.x, halfWidth: markerWidth / 2));
    }
    return spans;
  }
}

class _EventMarker extends StatelessWidget {
  const _EventMarker({
    required this.label,
    required this.verticalOffset,
  });

  final String label;
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.w700,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final markerWidth = math.max(
      textPainter.width,
      EventPointMarkers.triangleWidth,
    );

    return Transform.translate(
      offset: Offset(0, -verticalOffset),
      child: SizedBox(
        width: markerWidth,
        height: EventPointMarkers.markerHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 0,
              left: (markerWidth - EventPointMarkers.triangleWidth) / 2,
              child: CustomPaint(
                size: const Size(
                  EventPointMarkers.triangleWidth,
                  EventPointMarkers.markerHeight,
                ),
                painter: _DownTrianglePainter(),
              ),
            ),
            Positioned(
              bottom: EventPointMarkers.markerHeight + 3,
              left: 0,
              right: 0,
              child: Text(
                label,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = EventPointMarkers.markerColor
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Span {
  const _Span({required this.center, required this.halfWidth});

  final double center;
  final double halfWidth;

  bool overlaps(_Span other, {double padding = 0}) {
    return (center - other.center).abs() <
        (halfWidth + other.halfWidth + padding);
  }
}
