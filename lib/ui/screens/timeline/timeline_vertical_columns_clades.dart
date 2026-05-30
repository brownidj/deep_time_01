part of 'timeline_vertical_columns.dart';

class _VerticalCladeColumn extends StatelessWidget {
  const _VerticalCladeColumn({
    required this.width,
    required this.height,
    required this.layout,
    required this.totalUnits,
    required this.scrollController,
    required this.clades,
    required this.stageSegments,
    required this.stageHeights,
    required this.epochSegments,
    required this.epochHeights,
    required this.periodSegments,
    required this.periodHeights,
    required this.eraSegments,
    required this.eraHeights,
    required this.eonSegments,
    required this.eonHeights,
    required this.viewMode,
    required this.displayGroupId,
    required this.representativeIds,
    required this.searchQuery,
    required this.spotlightId,
    required this.onSpotlight,
  });

  final double width;
  final double height;
  final TimelineLayoutSnapshot layout;
  final double totalUnits;
  final ScrollController scrollController;
  final List<Clade> clades;
  final List<TimelineRowSegment> stageSegments;
  final List<double> stageHeights;
  final List<TimelineRowSegment> epochSegments;
  final List<double> epochHeights;
  final List<TimelineRowSegment> periodSegments;
  final List<double> periodHeights;
  final List<TimelineBandSegment> eraSegments;
  final List<double> eraHeights;
  final List<TimelineBandSegment> eonSegments;
  final List<double> eonHeights;
  final CladeViewMode viewMode;
  final String displayGroupId;
  final List<String> representativeIds;
  final String searchQuery;
  final String? spotlightId;
  final ValueChanged<Clade> onSpotlight;

  @override
  Widget build(BuildContext context) {
    if (width <= 0 || height <= 0 || totalUnits <= 0) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      key: const ValueKey('vertical-clade-column'),
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DeepTimePalette.timelineGapBackground,
          border: Border.all(color: DeepTimePalette.periodDivider, width: 1),
        ),
        child: AnimatedBuilder(
          animation: scrollController,
          builder: (context, child) {
            final mapper = _StageRangeMapper(
              stageSegments: stageSegments,
              stageHeights: stageHeights,
              epochSegments: epochSegments,
              epochHeights: epochHeights,
              periodSegments: periodSegments,
              periodHeights: periodHeights,
              eraSegments: eraSegments,
              eraHeights: eraHeights,
              eonSegments: eonSegments,
              eonHeights: eonHeights,
              totalHeight: height,
              oldestMa: layout.oldestMa,
              youngestMa: layout.youngestMa,
            );
            if (clades.isEmpty) {
              return _emptyColumn('No clades loaded');
            }
            var viewportHeight = height;
            var scrollOffset = 0.0;
            if (scrollController.hasClients) {
              final position = scrollController.position;
              if (position.hasContentDimensions) {
                viewportHeight = position.viewportDimension;
              }
              if (position.hasPixels) {
                scrollOffset = position.pixels;
              }
            }
            final visibleStart = mapper.maForY(scrollOffset) ?? layout.oldestMa;
            final visibleEnd =
                mapper.maForY(scrollOffset + viewportHeight) ??
                layout.youngestMa;
            final filtered = _filterCladesForMode(
              source: clades,
              representativeIds: representativeIds,
              viewMode: viewMode,
              searchQuery: searchQuery,
            );
            final filterId = viewMode == CladeViewMode.byCategory
                ? displayGroupId
                : null;
            final visible = _filterVisibleClades(
              clades: filtered,
              visibleStartMa: visibleStart,
              visibleEndMa: visibleEnd,
              displayGroupId: filterId,
            );
            if (visible.isEmpty) {
              return _emptyColumn(_emptyMessage());
            }
            final allById = {for (final clade in clades) clade.id: clade};
            final barLayouts = _layoutCladeBars(
              visible: visible,
              allById: allById,
              mapper: mapper,
              columnWidth: width,
              columnHeight: height,
            );
            return Stack(
              children: [
                for (final connector in _layoutCladeConnectors(barLayouts))
                  Positioned(
                    key: ValueKey(
                      'vertical-clade-connector-${connector.parent.id}-${connector.child.id}',
                    ),
                    left: connector.left,
                    top: connector.top,
                    width: connector.width,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _VerticalCladeBar.baseColor.withValues(
                          alpha: 0.9,
                        ),
                      ),
                    ),
                  ),
                for (final entry in barLayouts)
                  Positioned(
                    left: entry.left,
                    top: entry.top,
                    child: Tooltip(
                      message: entry.tooltip,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => onSpotlight(entry.clade),
                        onLongPress: () => showTimelineExplanationDialog(
                          context: context,
                          title: entry.clade.label,
                          explanation: _buildCladeDetailsText(entry),
                        ),
                        child: _VerticalCladeBar(
                          key: ValueKey('vertical-clade-${entry.clade.id}'),
                          clade: entry.clade,
                          width: entry.width,
                          height: entry.height,
                          isDimmed:
                              spotlightId != null &&
                              spotlightId != entry.clade.id,
                          isHighlighted: spotlightId == entry.clade.id,
                          onLongPress: () => showTimelineExplanationDialog(
                            context: context,
                            title: entry.clade.label,
                            explanation: _buildCladeDetailsText(entry),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _emptyMessage() {
    if (viewMode == CladeViewMode.searchSpotlight &&
        searchQuery.trim().isNotEmpty) {
      return 'No matching clades';
    }
    if (viewMode == CladeViewMode.byCategory &&
        displayGroupId.isNotEmpty &&
        displayGroupId != 'all') {
      return 'No clades in this category';
    }
    return 'No clades in view';
  }

  Widget _emptyColumn(String message) {
    const style = TextStyle(color: DeepTimePalette.panelText, fontSize: 12);
    return Center(
      child: Text(message, style: style, textAlign: TextAlign.center),
    );
  }
}
