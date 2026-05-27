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
        );
        final scale = _widthScale(constraints.maxWidth);
        final cappedTracks = <TimelineTrack>{
          TimelineTrack.ma,
          TimelineTrack.eon,
          TimelineTrack.era,
          TimelineTrack.period,
          TimelineTrack.epoch,
          TimelineTrack.stage,
          TimelineTrack.rlife,
          TimelineTrack.extinctions,
          TimelineTrack.continents,
        };
        double scaledWidth(TimelineTrack track) =>
            metrics.trackWidth(track) *
            (cappedTracks.contains(track) ? 1.0 : scale);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MaColumn(
              width: scaledWidth(TimelineTrack.ma),
              height: columnHeight,
              layout: layout,
              metrics: metrics,
            ),
            _VerticalBandColumn(
              width: scaledWidth(TimelineTrack.eon),
              height: columnHeight,
              segments: layout.eonSegments,
              unitsTotal: metrics.eonTotalUnits,
              selectedId: selectedId,
              onTapSegment: onBandSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: true,
              horizontalPadding: 2,
              minHeightForSegment: useFixedHeights
                  ? null
                  : (segment, _) =>
                      minHeights.eonHeights[segment.id] ?? 0.0,
            ),
            _VerticalBandColumn(
              width: scaledWidth(TimelineTrack.era),
              height: columnHeight,
              segments: layout.eraSegments,
              unitsTotal: metrics.eraTotalUnits,
              selectedId: selectedId,
              onTapSegment: onBandSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: true,
              horizontalPadding: 2,
              minHeightForSegment: useFixedHeights
                  ? null
                  : (segment, _) => segment.isGap
                      ? minHeightFromParentRange(
                          segment.startMa,
                          segment.endMa,
                          layout.eonSegments,
                          minHeights.eonHeights,
                          (parent) => parent.startMa,
                          (parent) => parent.endMa,
                          (parent) => parent.id,
                        )
                      : (minHeights.eraHeights[segment.id] ?? 0.0),
            ),
            _VerticalRowColumn(
              width: scaledWidth(TimelineTrack.period),
              height: columnHeight,
              segments: layout.periodSegments,
              unitsTotal: metrics.periodUnits,
              selectedId: selectedId,
              onTapSegment: onSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: true,
              horizontalPadding: 6,
              minHeightForSegment: useFixedHeights
                  ? null
                  : (segment, _) => segment.isGap
                      ? minHeightFromParentRange(
                          segment.startMa,
                          segment.endMa,
                          layout.eraSegments,
                          minHeights.eraHeights,
                          (parent) => parent.startMa,
                          (parent) => parent.endMa,
                          (parent) => parent.id,
                        )
                      : (minHeights.periodHeights[segment.id] ?? 0.0),
            ),
            _VerticalRowColumn(
              width: scaledWidth(TimelineTrack.epoch),
              height: columnHeight,
              segments: layout.epochSegments,
              unitsTotal: metrics.epochTotalUnits,
              selectedId: selectedId,
              onTapSegment: onSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: false,
              horizontalPadding: 6,
              minHeightForSegment: useFixedHeights
                  ? null
                  : (segment, _) => segment.isGap
                      ? minHeightFromParentRange(
                          segment.startMa,
                          segment.endMa,
                          layout.periodSegments,
                          minHeights.periodHeights,
                          (parent) => parent.startMa,
                          (parent) => parent.endMa,
                          (parent) => parent.id,
                        )
                      : (minHeights.epochHeights[segment.id] ?? 0.0),
            ),
            _VerticalRowColumn(
              width: scaledWidth(TimelineTrack.stage),
              height: columnHeight,
              segments: layout.stageSegments,
              unitsTotal: metrics.stageTotalUnits,
              selectedId: selectedId,
              onTapSegment: onSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: false,
              horizontalPadding: 6,
              minHeightForSegment: useFixedHeights
                  ? null
                  : (segment, style) => segment.isGap
                      ? minHeightFromParentRange(
                          segment.startMa,
                          segment.endMa,
                          layout.epochSegments,
                          minHeights.epochHeights,
                          (parent) => parent.startMa,
                          (parent) => parent.endMa,
                          (parent) => parent.id,
                        )
                      : minHeightForStageLabel(segment, style),
            ),
            _VerticalEventsColumn(
              width: scaledWidth(TimelineTrack.continents),
              height: columnHeight,
              events: layout.continentSegments,
              totalUnits: metrics.periodUnits,
              palette: palette,
              horizontalPadding: 12,
              laneGap: 6,
              showPoints: false,
            ),
            _VerticalRowColumn(
              width: scaledWidth(TimelineTrack.rlife),
              height: columnHeight,
              segments: layout.rlifeSegments,
              unitsTotal: metrics.rlifeTotalUnits,
              selectedId: selectedId,
              onTapSegment: onSelect,
              colorForSegment: (segment) =>
                  palette.colorForKey(segment.colorKey),
              rotateLabel: false,
              horizontalPadding: 6,
              minHeightForSegment: null,
            ),
            _VerticalExtinctionColumn(
              width: scaledWidth(TimelineTrack.extinctions),
              height: columnHeight,
              periodSegments: layout.periodSegments,
              stageSegments: layout.stageSegments,
              extinctions: markers.extinctions,
            ),
            _VerticalEventsColumn(
              width: scaledWidth(TimelineTrack.events),
              height: columnHeight,
              events: layout.eventSegments,
              totalUnits: metrics.periodUnits,
              palette: palette,
            ),
            _VerticalCladeColumn(
              width: scaledWidth(TimelineTrack.clades),
              height: columnHeight,
              layout: layout,
              totalUnits: metrics.periodUnits,
              scrollController: scrollController,
              clades: clades,
              viewMode: cladeViewMode,
              displayGroupId: cladeCategoryId,
              representativeIds: cladeRepresentativeIds,
              searchQuery: cladeSearchQuery,
              spotlightId: cladeSpotlightId,
              onSpotlight: onCladeSpotlight,
            ),
          ],
        );
      },
    );
  }

  double _widthScale(double maxWidth) {
    if (!maxWidth.isFinite || maxWidth <= 0 || metrics.trackColumnsWidth <= 0) {
      return 1.0;
    }
    return maxWidth / metrics.trackColumnsWidth;
  }
}
