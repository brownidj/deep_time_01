part of 'timeline_vertical_columns.dart';

class TimelineVerticalColumns extends StatelessWidget {
  const TimelineVerticalColumns({
    super.key,
    required this.layout,
    required this.markers,
    required this.palette,
    required this.selectedId,
    required this.onBandSelect,
    required this.onSelect,
    required this.scrollController,
    required this.clades,
    required this.cladeViewMode,
    required this.cladeCategoryId,
    required this.cladeRepresentativeIds,
    required this.cladeSearchQuery,
    required this.cladeSpotlightId,
    required this.onCladeSpotlight,
    required this.metrics,
    required this.paleoEcology,
  });

  final TimelineLayoutSnapshot layout;
  final TimelineMarkerCatalog markers;
  final DeepTimePalette palette;
  final int? selectedId;
  final ValueChanged<TimelineBandSegment> onBandSelect;
  final ValueChanged<TimelineRowSegment> onSelect;
  final ScrollController scrollController;
  final List<Clade> clades;
  final CladeViewMode cladeViewMode;
  final String cladeCategoryId;
  final List<String> cladeRepresentativeIds;
  final String cladeSearchQuery;
  final String? cladeSpotlightId;
  final ValueChanged<Clade> onCladeSpotlight;
  final TimelineBodyMetrics metrics;
  final List<PaleoEcologyEntry> paleoEcology;

  @override
  Widget build(BuildContext context) {
    final columnHeight = math.max(metrics.minHeight, metrics.scrollHeight);
    return LayoutBuilder(
      builder: (context, constraints) {
        final useFixedHeights = layout.fixedHeight != null;
        final stageLabelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: DeepTimePalette.darkLabel,
          fontWeight: FontWeight.w700,
        );
        final periodLabelStyle = stageLabelStyle;
        final minHeights = buildMinHeightMaps(
          layout,
          stageLabelStyle,
          periodStyle: periodLabelStyle,
          divisions: layout.divisions,
          paleoEcology: paleoEcology,
          paleoWidth: metrics.trackWidth(TimelineTrack.paleoEcology),
          paleoStyle: stageLabelStyle,
        );
        final trackWidths = resolveTimelineTrackWidths(
          metrics: metrics,
          maxWidth: constraints.maxWidth,
        );
        final stageHeightsForPaleo = useFixedHeights
            ? _computeProportionalHeights(
                layout.stageSegments,
                height: columnHeight,
                unitsTotal: metrics.stageTotalUnits,
                unitSpan: (segment) => segment.unitSpan,
              )
            : _computeHeightsWithMinimums(
                layout.stageSegments,
                height: columnHeight,
                unitsTotal: metrics.stageTotalUnits,
                minHeights: [
                  for (final segment in layout.stageSegments)
                    segment.isGap
                        ? minHeightFromParentRange(
                            segment.startMa,
                            segment.endMa,
                            layout.epochSegments,
                            minHeights.epochHeights,
                            (parent) => parent.startMa,
                            (parent) => parent.endMa,
                            (parent) => parent.id,
                          )
                        : (minHeights.stageHeights[segment.id] ??
                              minHeightForStageLabel(segment, stageLabelStyle)),
                ],
                unitSpan: (segment) => segment.unitSpan,
              );
        double scaledWidth(TimelineTrack track) =>
            trackWidths[track] ?? metrics.trackWidth(track);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final track in metrics.trackOrder) ...[
              if (metrics.gapBefore(track) > 0)
                SizedBox(width: metrics.gapBefore(track)),
              _buildVerticalTrack(
                track: track,
                scaledWidth: scaledWidth,
                columnHeight: columnHeight,
                layout: layout,
                metrics: metrics,
                selectedId: selectedId,
                onBandSelect: onBandSelect,
                onSelect: onSelect,
                palette: palette,
                useFixedHeights: useFixedHeights,
                minHeights: minHeights,
                markers: markers,
                scrollController: scrollController,
                clades: clades,
                cladeViewMode: cladeViewMode,
                cladeCategoryId: cladeCategoryId,
                cladeRepresentativeIds: cladeRepresentativeIds,
                cladeSearchQuery: cladeSearchQuery,
                cladeSpotlightId: cladeSpotlightId,
                onCladeSpotlight: onCladeSpotlight,
                paleoEcology: paleoEcology,
                stageHeightsForPaleo: stageHeightsForPaleo,
              ),
              if (metrics.gapAfter(track) > 0)
                SizedBox(width: metrics.gapAfter(track)),
            ],
          ],
        );
      },
    );
  }
}
