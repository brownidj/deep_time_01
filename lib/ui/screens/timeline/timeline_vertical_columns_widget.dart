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
        final scale = _widthScale(constraints.maxWidth);
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
        final cappedTracks = <TimelineTrack>{
          TimelineTrack.ma,
          TimelineTrack.eon,
          TimelineTrack.era,
          TimelineTrack.period,
          TimelineTrack.epoch,
          TimelineTrack.stage,
          TimelineTrack.paleoEcology,
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

  double _widthScale(double maxWidth) {
    if (!maxWidth.isFinite || maxWidth <= 0 || metrics.trackColumnsWidth <= 0) {
      return 1.0;
    }
    final cappedTracks = <TimelineTrack>{
      TimelineTrack.ma,
      TimelineTrack.eon,
      TimelineTrack.era,
      TimelineTrack.period,
      TimelineTrack.epoch,
      TimelineTrack.stage,
      TimelineTrack.paleoEcology,
      TimelineTrack.rlife,
      TimelineTrack.extinctions,
      TimelineTrack.continents,
    };
    var fixed = 0.0;
    var scalable = 0.0;
    for (final track in metrics.trackOrder) {
      final width = metrics.trackWidth(track);
      fixed += metrics.gapBefore(track);
      if (cappedTracks.contains(track)) {
        fixed += width;
      } else {
        scalable += width;
      }
      fixed += metrics.gapAfter(track);
    }
    if (scalable <= 0) {
      return 1.0;
    }
    final available = (maxWidth - fixed).clamp(0.0, double.infinity);
    return available / scalable;
  }
}
