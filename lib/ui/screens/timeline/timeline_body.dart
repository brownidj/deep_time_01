import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:deep_time/application/services/timeline_layout_models.dart';
import 'package:deep_time/domain/models/clade.dart';
import 'package:deep_time/domain/models/timeline_marker_catalog.dart';
import 'package:deep_time/ui/models/clade_view_mode.dart';
import 'package:deep_time/ui/models/time_label_mode.dart';
import 'package:deep_time/ui/theme/deep_time_palette.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_content.dart';
import 'package:deep_time/ui/screens/timeline/timeline_body_metrics.dart';
import 'package:deep_time/ui/screens/timeline/timeline_orientation.dart';

class TimelineBody extends StatelessWidget {
  const TimelineBody({
    super.key,
    required this.layout,
    required this.palette,
    required this.markers,
    required this.labelMode,
    required this.scrollController,
    required this.selectedId,
    required this.onBandSelect,
    required this.onSelect,
    required this.clades,
    required this.cladeViewMode,
    required this.cladeCategoryId,
    required this.cladeRepresentativeIds,
    required this.cladeSearchQuery,
    required this.cladeSpotlightId,
    required this.onCladeSpotlight,
  });

  final TimelineLayoutSnapshot layout;
  final DeepTimePalette palette;
  final TimelineMarkerCatalog markers;
  final TimeLabelMode labelMode;
  final ScrollController scrollController;
  final int? selectedId;
  final ValueChanged<TimelineBandSegment> onBandSelect;
  final ValueChanged<TimelineRowSegment> onSelect;
  final List<Clade> clades;
  final CladeViewMode cladeViewMode;
  final String cladeCategoryId;
  final List<String> cladeRepresentativeIds;
  final String cladeSearchQuery;
  final String? cladeSpotlightId;
  final ValueChanged<Clade> onCladeSpotlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final headerStyle = Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700);
            final stageTextStyle = Theme.of(context).textTheme.bodySmall
                ?.copyWith(
                  color: DeepTimePalette.darkLabel,
                  fontWeight: FontWeight.w700,
                );
            final config = _buildOrientationConfig(
              layout: layout,
              labelMode: labelMode,
              style: headerStyle,
              stageStyle: stageTextStyle,
            );
            final minScrollHeight = _minScrollHeightForStages(
              layout,
              style: stageTextStyle,
              verticalPadding: 4,
            );
            final metrics = TimelineBodyMetrics.fromLayout(
              layout: layout,
              markers: markers,
              constraints: constraints,
              config: config,
              minScrollHeight: minScrollHeight,
            );
            return TimelineBodyContent(
              layout: layout,
              palette: palette,
              markers: markers,
              labelMode: labelMode,
              scrollController: scrollController,
              selectedId: selectedId,
              onBandSelect: onBandSelect,
              onSelect: onSelect,
              metrics: metrics,
              clades: clades,
              cladeViewMode: cladeViewMode,
              cladeCategoryId: cladeCategoryId,
              cladeRepresentativeIds: cladeRepresentativeIds,
              cladeSearchQuery: cladeSearchQuery,
              cladeSpotlightId: cladeSpotlightId,
              onCladeSpotlight: onCladeSpotlight,
            );
          },
        ),
      ),
    );
  }

  TimelineOrientationConfig _buildOrientationConfig({
    required TimelineLayoutSnapshot layout,
    required TimeLabelMode labelMode,
    TextStyle? style,
    TextStyle? stageStyle,
  }) {
    final eonLabel = labelMode.labelForRank('eon');
    final eraLabel = labelMode.labelForRank('era');
    final periodLabel = labelMode.divisionRowLabel();
    final epochLabel = labelMode.seriesRowLabel();
    final maxEpochLabelWidth = _segmentLabelWidth(
      layout.epochSegments,
      style: style,
      horizontalPadding: 12,
    );
    final eonWidth = _minimalHorizontalLabelWidth(eonLabel, style: style);
    final eraWidth = _minimalHorizontalLabelWidth(eraLabel, style: style);
    final periodWidth = math.max(
      _minimalVerticalLabelWidth(periodLabel, style: style),
      _minimalHorizontalLabelWidth(periodLabel, style: style),
    );
    final epochWidth = math.max(
      _minimalHorizontalLabelWidth(epochLabel, style: style),
      maxEpochLabelWidth,
    );
    final maxStageLabelWidth = _segmentLabelWidth(
      layout.stageSegments,
      style: stageStyle,
      horizontalPadding: 12,
    );
    final stageWidth = math.max(
      _minimalHorizontalLabelWidth(labelMode.stageRowLabel(), style: style),
      maxStageLabelWidth,
    );
    final rlifeWidth =
        _minimalHorizontalLabelWidth('Representative life', style: style) * 1.5;
    return TimelineOrientationConfig(
      trackWidths: {
        TimelineTrack.eon: eonWidth,
        TimelineTrack.era: eraWidth,
        TimelineTrack.period: periodWidth,
        TimelineTrack.epoch: epochWidth,
        TimelineTrack.stage: stageWidth,
        TimelineTrack.rlife: rlifeWidth,
      },
    );
  }

  double _minimalHorizontalLabelWidth(String label, {TextStyle? style}) {
    if (label.trim().isEmpty) {
      return 40.0;
    }
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width + 16;
  }

  double _minimalVerticalLabelWidth(String label, {TextStyle? style}) {
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

  double _segmentLabelWidth(
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

  double _minScrollHeightForStages(
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
}
