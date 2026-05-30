part of 'timeline_vertical_columns.dart';

List<Clade> _filterCladesForMode({
  required List<Clade> source,
  required List<String> representativeIds,
  required CladeViewMode viewMode,
  required String searchQuery,
}) {
  if (viewMode == CladeViewMode.representativeOnly) {
    return _filterRepresentativeClades(source, representativeIds);
  }
  if (viewMode == CladeViewMode.searchSpotlight) {
    final query = searchQuery.trim();
    if (query.isEmpty) {
      return _filterRepresentativeClades(source, representativeIds);
    }
    return searchClades(source, query);
  }
  return source;
}

List<Clade> _filterRepresentativeClades(
  List<Clade> source,
  List<String> representativeIds,
) {
  if (representativeIds.isEmpty) {
    return source;
  }
  final byId = {for (final clade in source) clade.id: clade};
  final idSet = <String>{};
  void addWithAncestors(String id) {
    if (!idSet.add(id)) {
      return;
    }
    final parentId = byId[id]?.parentId;
    if (parentId != null) {
      addWithAncestors(parentId);
    }
  }

  for (final id in representativeIds) {
    addWithAncestors(id);
  }
  return source.where((clade) => idSet.contains(clade.id)).toList();
}

List<Clade> _filterVisibleClades({
  required List<Clade> clades,
  required double visibleStartMa,
  required double visibleEndMa,
  String? displayGroupId,
}) {
  return clades.where((clade) {
    if (!_overlapsVisibleRange(clade, visibleStartMa, visibleEndMa)) {
      return false;
    }
    if (displayGroupId != null &&
        displayGroupId.isNotEmpty &&
        displayGroupId != 'all') {
      return clade.displayGroups.contains(displayGroupId);
    }
    return true;
  }).toList();
}

bool _overlapsVisibleRange(
  Clade clade,
  double visibleStartMa,
  double visibleEndMa,
) {
  final cladeMin = clade.endMa;
  final cladeMax = clade.startMa;
  final viewMin = visibleEndMa;
  final viewMax = visibleStartMa;
  return !(cladeMax < viewMin || cladeMin > viewMax);
}

List<_VerticalCladeBarLayout> _layoutCladeBars({
  required List<Clade> visible,
  required Map<String, Clade> allById,
  required _StageRangeMapper mapper,
  required double columnWidth,
  required double columnHeight,
}) {
  const labelHalfWidth = 14.0;
  const padding = labelHalfWidth;
  const minBarHeight = 12.0;
  const lineHitWidth = 72.0;
  final visibleById = {for (final clade in visible) clade.id: clade};

  final layouts = <_VerticalCladeBarLayout>[];
  final ordered = _orderedTreeClades(visible);
  final usable = math.max(0.0, columnWidth - (padding * 2) - 2);
  for (var i = 0; i < ordered.length; i += 1) {
    final clade = ordered[i];
    final start = (mapper.yForMa(clade.startMa) ?? 0.0).clamp(
      0.0,
      columnHeight,
    );
    final end = (mapper.yForMa(clade.endMa) ?? columnHeight).clamp(
      0.0,
      columnHeight,
    );
    final top = math.min(start, end).toDouble();
    final span = (end - start).abs();
    var barHeight = math.max(minBarHeight, span);
    if (top + barHeight > columnHeight) {
      barHeight = math.max(0.0, columnHeight - top);
    }
    if (barHeight <= 0) {
      continue;
    }
    final laneFraction = ordered.length <= 1 ? 0.0 : i / (ordered.length - 1);
    final left = padding + (usable * laneFraction);
    final hitWidth = math.max(12.0, math.min(lineHitWidth, columnWidth - left));
    layouts.add(
      _VerticalCladeBarLayout(
        clade: clade,
        left: left,
        top: top,
        width: hitWidth,
        height: barHeight,
        parent: clade.parentId == null ? null : visibleById[clade.parentId],
        parentLabel: clade.parentId == null
            ? null
            : allById[clade.parentId]?.label,
      ),
    );
  }
  return layouts;
}

String _formatCladeStartMa(double value) {
  return value
      .toStringAsFixed(3)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String _buildCladeDetailsText(_VerticalCladeBarLayout entry) {
  final clade = entry.clade;
  final parts = <String>[
    'Rank: ${clade.scientificRank}',
    'Parent: ${entry.parentLabel ?? '-'}',
    'Started: ${_formatCladeStartMa(clade.startMa)} Ma ${clade.confidence ?? '-'}',
    clade.shortDescription ?? '-',
    'Range: ${clade.rangeNote ?? '-'}',
    (clade.tags == null || clade.tags!.isEmpty) ? '-' : clade.tags!.join('; '),
  ];
  return parts.join('\n');
}

List<Clade> _orderedTreeClades(List<Clade> visible) {
  final byId = {for (final clade in visible) clade.id: clade};
  final childrenByParentId = <String, List<Clade>>{};
  final roots = <Clade>[];
  for (final clade in visible) {
    final parentId = clade.parentId;
    if (parentId == null || !byId.containsKey(parentId)) {
      roots.add(clade);
      continue;
    }
    childrenByParentId.putIfAbsent(parentId, () => []).add(clade);
  }

  int compareClades(Clade a, Clade b) {
    final startCompare = b.startMa.compareTo(a.startMa);
    if (startCompare != 0) {
      return startCompare;
    }
    final priorityCompare = a.displayPriority.compareTo(b.displayPriority);
    if (priorityCompare != 0) {
      return priorityCompare;
    }
    return a.label.compareTo(b.label);
  }

  roots.sort(compareClades);
  for (final children in childrenByParentId.values) {
    children.sort(compareClades);
  }

  final ordered = <Clade>[];
  void visit(Clade clade) {
    ordered.add(clade);
    for (final child in childrenByParentId[clade.id] ?? const <Clade>[]) {
      visit(child);
    }
  }

  for (final root in roots) {
    visit(root);
  }
  return ordered;
}

List<_VerticalCladeConnectorLayout> _layoutCladeConnectors(
  List<_VerticalCladeBarLayout> bars,
) {
  final byId = {for (final bar in bars) bar.clade.id: bar};
  final connectors = <_VerticalCladeConnectorLayout>[];
  for (final child in bars) {
    final parentId = child.clade.parentId;
    if (parentId == null) {
      continue;
    }
    final parent = byId[parentId];
    if (parent == null) {
      continue;
    }
    final parentX = parent.left;
    final childX = child.left;
    if ((parentX - childX).abs() < 1) {
      continue;
    }
    connectors.add(
      _VerticalCladeConnectorLayout(
        parent: parent.clade,
        child: child.clade,
        left: math.min(parentX, childX),
        top: child.top,
        width: (childX - parentX).abs(),
      ),
    );
  }
  return connectors;
}
