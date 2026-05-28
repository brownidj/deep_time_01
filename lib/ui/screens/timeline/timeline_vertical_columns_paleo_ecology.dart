part of 'timeline_vertical_columns.dart';

class _VerticalPaleoEcologyColumn extends StatelessWidget {
  const _VerticalPaleoEcologyColumn({
    required this.width,
    required this.height,
    required this.layout,
    required this.entries,
    required this.palette,
    required this.stageHeights,
  });

  final double width;
  final double height;
  final TimelineLayoutSnapshot layout;
  final List<PaleoEcologyEntry> entries;
  final DeepTimePalette palette;
  final List<double> stageHeights;
  static const double _rightGutter = 10.0;

  @override
  Widget build(BuildContext context) {
    if (width <= 0 || height <= 0) {
      return const SizedBox.shrink();
    }
    final blocks = _buildBlocks(
      layout,
      stageHeights: stageHeights,
      columnHeight: height,
    );
    final entriesByStage = {for (final entry in entries) entry.stage: entry};
    final entriesByStageNormalized = {
      for (final entry in entries) _normalizeStageKey(entry.stage): entry,
    };
    PaleoEcologyEntry? resolveEntry(String? stageLabel) {
      if (stageLabel == null || stageLabel.trim().isEmpty) {
        return null;
      }
      return entriesByStage[stageLabel] ??
          entriesByStageNormalized[_normalizeStageKey(stageLabel)];
    }

    var matched = 0;
    var labelled = 0;
    for (final block in blocks) {
      if (block.stageLabel == null) {
        continue;
      }
      labelled += 1;
      if (resolveEntry(block.stageLabel) != null) {
        matched += 1;
      }
    }
    AppDebug.log(
      'Paleo-ecology column: blocks=${blocks.length} '
      'labelled=$labelled matched=$matched entries=${entries.length}',
    );
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          for (final block in blocks)
            _buildBlock(
              context,
              block: block,
              width: width - _rightGutter,
              entry: resolveEntry(block.stageLabel),
              palette: palette,
            ),
        ],
      ),
    );
  }

  Widget _buildBlock(
    BuildContext context, {
    required _PaleoBlock block,
    required double width,
    required PaleoEcologyEntry? entry,
    required DeepTimePalette palette,
  }) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: DeepTimePalette.darkLabel,
      fontWeight: FontWeight.w600,
      height: 1.15,
    );
    final isVisibleAgeBlock = block.stageLabel != null;
    final summary = entry == null
        ? null
        : 'Temp:\u00A0${_withSign(entry.avgTempDeltaC)}\u00B0C; '
              'CO2\u00A0${_formatUnsigned(entry.avgCo2Ppm)}ppm; '
              'RH:\u00A0${_withSign(entry.avgHumidityDeltaPercent)}%; '
              'SL\u00A0${_withSign(entry.seaLevelDeltaM)}m';
    final backgroundColor = !isVisibleAgeBlock
        ? Colors.transparent
        : block.colorKey == null
        ? DeepTimePalette.timelineGapBackground
        : _safeColorForKey(block.colorKey!, palette);
    return SizedBox(
      width: width,
      height: block.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: isVisibleAgeBlock
              ? Border(
                  right: BorderSide(color: DeepTimePalette.periodDivider),
                  bottom: BorderSide(color: DeepTimePalette.periodDivider),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: summary == null
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    summary,
                    style: textStyle,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
        ),
      ),
    );
  }
}

String _normalizeStageKey(String value) {
  final lower = value.toLowerCase().trim();
  return lower.replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

String _formatUnsigned(double value) {
  final magnitude = value.abs();
  if (magnitude == magnitude.roundToDouble()) {
    return magnitude.toStringAsFixed(0);
  }
  return magnitude
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String _withSign(double value) {
  final sign = value >= 0 ? '+' : '-';
  final magnitude = value.abs();
  final rounded = magnitude == magnitude.roundToDouble()
      ? magnitude.toStringAsFixed(0)
      : magnitude
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
  return '$sign$rounded';
}

class _PaleoBlock {
  const _PaleoBlock({
    required this.startMa,
    required this.endMa,
    required this.height,
    required this.stageLabel,
    required this.colorKey,
  });

  final double startMa;
  final double endMa;
  final double height;
  final String? stageLabel;
  final String? colorKey;
}

class _RangeRef {
  const _RangeRef({
    required this.startMa,
    required this.endMa,
    required this.isGap,
    this.stageLabel,
    this.colorKey,
  });

  final double startMa;
  final double endMa;
  final bool isGap;
  final String? stageLabel;
  final String? colorKey;

  bool contains(double ma) => ma <= startMa && ma >= endMa;
}

List<_PaleoBlock> _buildBlocks(
  TimelineLayoutSnapshot layout, {
  required List<double> stageHeights,
  required double columnHeight,
}) {
  final stageRanges = [
    for (final segment in layout.stageSegments)
      _RangeRef(
        startMa: segment.startMa,
        endMa: segment.endMa,
        isGap: segment.isGap,
        stageLabel: segment.isGap ? null : segment.label,
        colorKey: segment.isGap ? null : segment.colorKey,
      ),
  ];
  final geologicColumns = <List<_RangeRef>>[
    stageRanges,
    [
      for (final segment in layout.epochSegments)
        _RangeRef(
          startMa: segment.startMa,
          endMa: segment.endMa,
          isGap: segment.isGap,
          colorKey: segment.isGap ? null : segment.colorKey,
        ),
    ],
    [
      for (final segment in layout.periodSegments)
        _RangeRef(
          startMa: segment.startMa,
          endMa: segment.endMa,
          isGap: segment.isGap,
          colorKey: segment.isGap ? null : segment.colorKey,
        ),
    ],
    [
      for (final segment in layout.eraSegments)
        _RangeRef(
          startMa: segment.startMa,
          endMa: segment.endMa,
          isGap: segment.isGap,
          colorKey: segment.isGap ? null : segment.colorKey,
        ),
    ],
    [
      for (final segment in layout.eonSegments)
        _RangeRef(
          startMa: segment.startMa,
          endMa: segment.endMa,
          isGap: segment.isGap,
          colorKey: segment.isGap ? null : segment.colorKey,
        ),
    ],
  ];

  _RangeRef? firstNonGapAt(double ma) {
    for (final column in geologicColumns) {
      for (final range in column) {
        if (range.contains(ma) && !range.isGap) {
          return range;
        }
      }
    }
    return null;
  }

  if (layout.stageSegments.isEmpty ||
      stageHeights.length != layout.stageSegments.length) {
    return const [];
  }
  final blocks = <_PaleoBlock>[];
  var consumed = 0.0;
  for (var i = 0; i < layout.stageSegments.length; i += 1) {
    final stage = layout.stageSegments[i];
    final rawHeight = stageHeights[i].clamp(0.0, columnHeight);
    final blockHeight = i == layout.stageSegments.length - 1
        ? (columnHeight - consumed).clamp(0.0, columnHeight)
        : rawHeight;
    consumed += blockHeight;
    if (blockHeight <= 0) {
      continue;
    }
    final span = stage.startMa - stage.endMa;
    if (span <= 0) {
      continue;
    }
    if (stage.isGap) {
      blocks.add(
        _PaleoBlock(
          startMa: stage.startMa,
          endMa: stage.endMa,
          height: blockHeight,
          stageLabel: null,
          colorKey: null,
        ),
      );
      continue;
    }
    final mid = stage.startMa - (span / 2.0);
    final source = firstNonGapAt(mid);
    blocks.add(
      _PaleoBlock(
        startMa: stage.startMa,
        endMa: stage.endMa,
        height: blockHeight,
        stageLabel: stage.label,
        colorKey: source?.colorKey ?? stage.colorKey,
      ),
    );
  }
  return blocks;
}
