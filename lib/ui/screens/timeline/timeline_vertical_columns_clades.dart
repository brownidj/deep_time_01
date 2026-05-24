part of 'timeline_vertical_columns.dart';

class _VerticalCladeColumn extends StatelessWidget {
  const _VerticalCladeColumn({
    required this.width,
    required this.height,
    required this.layout,
    required this.totalUnits,
    required this.scrollController,
    required this.clades,
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
            final mapper = TimelineRangeMapper(
              segments: layout.periodSegments,
              totalUnits: totalUnits,
              scrollWidth: height,
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
            final visibleStart = mapper.maForX(scrollOffset) ?? layout.oldestMa;
            final visibleEnd =
                mapper.maForX(scrollOffset + viewportHeight) ??
                layout.youngestMa;
            final resolver = CladeVisibilityResolver();
            final zoomLevel = resolver.zoomLevelForScale(
              AppDebug.timelineScale,
            );
            final filtered = _filterCladesForMode();
            final filterId = viewMode == CladeViewMode.byCategory
                ? displayGroupId
                : null;
            final visible = resolver.resolve(
              clades: filtered,
              zoomLevel: zoomLevel,
              visibleStartMa: visibleStart,
              visibleEndMa: visibleEnd,
              displayGroupId: filterId,
            );
            if (visible.isEmpty) {
              return _emptyColumn(_emptyMessage());
            }
            return Stack(
              children: [
                for (final entry in _layoutBars(visible, mapper))
                  Positioned(
                    left: entry.left,
                    top: entry.top,
                    child: Tooltip(
                      message: entry.tooltip,
                      child: GestureDetector(
                        onTap: () => onSpotlight(entry.clade),
                        child: _VerticalCladeBar(
                          key: ValueKey('vertical-clade-${entry.clade.id}'),
                          clade: entry.clade,
                          width: entry.width,
                          height: entry.height,
                          isDimmed:
                              spotlightId != null &&
                              spotlightId != entry.clade.id,
                          isHighlighted: spotlightId == entry.clade.id,
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

  List<Clade> _filterCladesForMode() {
    if (viewMode == CladeViewMode.representativeOnly) {
      return _filterRepresentative(clades);
    }
    if (viewMode == CladeViewMode.searchSpotlight) {
      final query = searchQuery.trim();
      if (query.isEmpty) {
        return _filterRepresentative(clades);
      }
      return searchClades(clades, query);
    }
    return clades;
  }

  List<Clade> _filterRepresentative(List<Clade> source) {
    if (representativeIds.isEmpty) {
      return source;
    }
    final idSet = representativeIds.toSet();
    return source.where((clade) => idSet.contains(clade.id)).toList();
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

  List<_VerticalCladeBarLayout> _layoutBars(
    List<Clade> visible,
    TimelineRangeMapper mapper,
  ) {
    const padding = 10.0;
    const spacing = 4.0;
    const minBarHeight = 12.0;
    final count = visible.length;
    final available = width - padding * 2 - math.max(0, count - 1) * spacing;
    final laneWidth = count > 0 ? math.max(8.0, available / count) : 0.0;

    final layouts = <_VerticalCladeBarLayout>[];
    for (var i = 0; i < visible.length; i++) {
      final clade = visible[i];
      final start = (mapper.xForMa(clade.startMa) ?? 0.0).clamp(0.0, height);
      final end = (mapper.xForMa(clade.endMa) ?? height).clamp(0.0, height);
      final top = math.min(start, end);
      final span = (end - start).abs();
      var barHeight = math.max(minBarHeight, span);
      if (top + barHeight > height) {
        barHeight = math.max(0.0, height - top);
      }
      if (barHeight <= 0) {
        continue;
      }
      final left = padding + i * (laneWidth + spacing);
      if (left + laneWidth > width - padding) {
        break;
      }
      layouts.add(
        _VerticalCladeBarLayout(
          clade: clade,
          left: left,
          top: top,
          width: laneWidth,
          height: barHeight,
        ),
      );
    }
    return layouts;
  }
}

class _VerticalCladeBarLayout {
  const _VerticalCladeBarLayout({
    required this.clade,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final Clade clade;
  final double left;
  final double top;
  final double width;
  final double height;

  String get tooltip {
    return '${clade.label} • '
        '${formatTimeRange(startMa: clade.startMa, endMa: clade.endMa, startPrecision: 1, endPrecision: 1, durationPrecision: 1)}';
  }
}

class _VerticalCladeBar extends StatelessWidget {
  const _VerticalCladeBar({
    super.key,
    required this.clade,
    required this.width,
    required this.height,
    required this.isDimmed,
    required this.isHighlighted,
  });

  final Clade clade;
  final double width;
  final double height;
  final bool isDimmed;
  final bool isHighlighted;

  static const Color baseColor = Color(0xFF4DB6AC);
  static const Color highlightColor = Color(0xFFFFD978);
  static const Color textColor = DeepTimePalette.darkLabel;

  @override
  Widget build(BuildContext context) {
    final color = isHighlighted ? highlightColor : baseColor;
    final opacity = isDimmed ? 0.35 : 1.0;
    final radius = math.min(width / 2, 12.0);
    final showLabel = height >= 32;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w600,
    );

    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: DeepTimePalette.frameBorder),
        ),
        alignment: Alignment.center,
        child: showLabel
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    clade.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
