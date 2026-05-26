import 'package:flutter/widgets.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';

const double _fallbackWidth = 40.0;

String formatMaLabel(double value) {
  return value.toStringAsFixed(1);
}

double minimalHorizontalLabelWidth(String label, {TextStyle? style}) {
  if (label.trim().isEmpty) {
    return _fallbackWidth;
  }
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.width + 16;
}

double minimalVerticalLabelWidth(String label, {TextStyle? style}) {
  if (label.trim().isEmpty) {
    return 36.0;
  }
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.height + 12;
}

double segmentLabelWidth(
  List<TimelineRowSegment> segments, {
  TextStyle? style,
  double horizontalPadding = 12,
}) {
  var maxWidth = 0.0;
  for (final segment in segments) {
    final label = segment.label.trim();
    if (label.isEmpty) {
      continue;
    }
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final width = painter.width + horizontalPadding;
    if (width > maxWidth) {
      maxWidth = width;
    }
  }
  return maxWidth;
}

double maColumnWidth(
  TimelineLayoutSnapshot layout, {
  TextStyle? style,
  double padding = 12,
}) {
  var maxWidth = minimalHorizontalLabelWidth('Ma', style: style);
  for (final segment in layout.eonSegments) {
    if (segment.isGap) {
      continue;
    }
    final width = labelWidth(formatMaLabel(segment.endMa), style: style);
    if (width > maxWidth) {
      maxWidth = width;
    }
  }
  for (final segment in layout.eraSegments) {
    if (segment.isGap) {
      continue;
    }
    final width = labelWidth(formatMaLabel(segment.endMa), style: style);
    if (width > maxWidth) {
      maxWidth = width;
    }
  }
  return maxWidth + padding;
}

double labelWidth(String label, {TextStyle? style}) {
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.width;
}

double maxLabelWidth(
  List<String> labels, {
  TextStyle? style,
  double padding = 0,
  double fallback = _fallbackWidth,
}) {
  var maxWidth = 0.0;
  for (final label in labels) {
    final text = label.trim();
    if (text.isEmpty) {
      continue;
    }
    final width = labelWidth(text, style: style) + padding;
    if (width > maxWidth) {
      maxWidth = width;
    }
  }
  return maxWidth > 0 ? maxWidth : fallback;
}

double minScrollHeightForStages(
  TimelineLayoutSnapshot layout, {
  TextStyle? style,
  double verticalPadding = 4,
}) {
  final segments = layout.stageSegments;
  if (segments.isEmpty) {
    return 0.0;
  }
  var total = 0.0;
  for (final segment in segments) {
    if (segment.isGap || segment.label.trim().isEmpty) {
      continue;
    }
    final painter = TextPainter(
      text: TextSpan(text: segment.label, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    total += painter.height + (verticalPadding * 2);
  }
  return total;
}

double extinctionsTrackWidthForLabels(
  List<String> labels, {
  TextStyle? style,
  double markerLeft = 0,
  double markerSize = 13,
  double labelGap = 6,
  double rightPadding = 6,
  String fallbackLabel = 'Ext.',
}) {
  var maxWidth = 0.0;
  for (final label in labels) {
    final text = label.trim();
    if (text.isEmpty) {
      continue;
    }
    final width = labelWidth(text, style: style);
    if (width > maxWidth) {
      maxWidth = width;
    }
  }
  if (maxWidth <= 0) {
    maxWidth = labelWidth(fallbackLabel, style: style);
  }
  return markerLeft + markerSize + labelGap + maxWidth + rightPadding;
}
