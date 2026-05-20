import 'package:flutter_test/flutter_test.dart';
import 'package:gts_01/application/services/timeline_layout_service.dart';
import 'package:gts_01/domain/models/geologic_division.dart';
import 'package:gts_01/domain/models/geologic_rank.dart';

void main() {
  test(
    'build creates period/epoch rows and keeps Carboniferous epochs contiguous',
    () {
      final divisions = [
        const GeologicDivision(
          id: 1,
          name: 'Phanerozoic',
          rank: GeologicRank.eon,
          startMa: 541,
          endMa: 0,
          parentId: null,
        ),
        const GeologicDivision(
          id: 2,
          name: 'Paleozoic',
          rank: GeologicRank.era,
          startMa: 541,
          endMa: 252,
          parentId: 1,
        ),
        const GeologicDivision(
          id: 3,
          name: 'Carboniferous',
          rank: GeologicRank.period,
          startMa: 358.86,
          endMa: 298.9,
          parentId: 2,
        ),
        const GeologicDivision(
          id: 4,
          name: 'Mississippian',
          rank: GeologicRank.epoch,
          startMa: 358.86,
          endMa: 323.4,
          parentId: 3,
        ),
        const GeologicDivision(
          id: 5,
          name: 'Pennsylvanian',
          rank: GeologicRank.epoch,
          startMa: 323.4,
          endMa: 298.9,
          parentId: 3,
        ),
        const GeologicDivision(
          id: 6,
          name: 'Permian',
          rank: GeologicRank.period,
          startMa: 298.9,
          endMa: 252,
          parentId: 2,
        ),
        const GeologicDivision(
          id: 7,
          name: 'Cisuralian',
          rank: GeologicRank.epoch,
          startMa: 298.9,
          endMa: 272.95,
          parentId: 6,
        ),
        const GeologicDivision(
          id: 8,
          name: 'Asselian',
          rank: GeologicRank.period,
          startMa: 298.9,
          endMa: 293.5,
          parentId: 7,
        ),
      ];

      final service = TimelineLayoutService();
      final layout = service.build(divisions);
      final epochLabels = layout.epochSegments
          .where((segment) => !segment.isGap)
          .map((segment) {
            return segment.label;
          })
          .toList();
      final periodLabels = layout.periodSegments
          .where((segment) => !segment.isGap)
          .map((segment) {
            return segment.label;
          })
          .toList();

      expect(epochLabels, ['Mississippian', 'Pennsylvanian', 'Cisuralian']);
      expect(periodLabels, ['Carboniferous', 'Permian']);
      expect(
        layout.epochSegments
            .firstWhere((s) => s.label == 'Mississippian')
            .endMa,
        layout.epochSegments
            .firstWhere((s) => s.label == 'Pennsylvanian')
            .startMa,
      );
      expect(layout.eraSegments, hasLength(1));
      expect(layout.eonSegments, hasLength(1));
    },
  );

  test('build orders periods oldest to youngest regardless of input order', () {
    final divisions = [
      const GeologicDivision(
        id: 1,
        name: 'Phanerozoic',
        rank: GeologicRank.eon,
        startMa: 541,
        endMa: 0,
        parentId: null,
      ),
      const GeologicDivision(
        id: 2,
        name: 'Paleozoic',
        rank: GeologicRank.era,
        startMa: 541,
        endMa: 252,
        parentId: 1,
      ),
      const GeologicDivision(
        id: 3,
        name: 'Permian',
        rank: GeologicRank.period,
        startMa: 298.9,
        endMa: 252,
        parentId: 2,
      ),
      const GeologicDivision(
        id: 4,
        name: 'Carboniferous',
        rank: GeologicRank.period,
        startMa: 358.86,
        endMa: 298.9,
        parentId: 2,
      ),
      const GeologicDivision(
        id: 5,
        name: 'Devonian',
        rank: GeologicRank.period,
        startMa: 419.2,
        endMa: 358.86,
        parentId: 2,
      ),
    ];

    final service = TimelineLayoutService();
    final layout = service.build(divisions);
    final periodLabels = layout.periodSegments
        .where((segment) => !segment.isGap)
        .map((segment) => segment.label)
        .toList();

    expect(periodLabels, ['Devonian', 'Carboniferous', 'Permian']);
  });

  test('build orders eons oldest to youngest regardless of input order', () {
    final divisions = [
      const GeologicDivision(
        id: 1,
        name: 'Phanerozoic',
        rank: GeologicRank.eon,
        startMa: 541,
        endMa: 0,
        parentId: null,
      ),
      const GeologicDivision(
        id: 2,
        name: 'Hadean',
        rank: GeologicRank.eon,
        startMa: 4567,
        endMa: 4031,
        parentId: null,
      ),
      const GeologicDivision(
        id: 3,
        name: 'Archean',
        rank: GeologicRank.eon,
        startMa: 4031,
        endMa: 2500,
        parentId: null,
      ),
      const GeologicDivision(
        id: 4,
        name: 'Proterozoic',
        rank: GeologicRank.eon,
        startMa: 2500,
        endMa: 541,
        parentId: null,
      ),
    ];

    final service = TimelineLayoutService();
    final layout = service.build(divisions);
    final eonLabels = layout.eonSegments
        .where((segment) => !segment.isGap)
        .map((segment) => segment.label)
        .toList();

    expect(eonLabels, ['Hadean', 'Archean', 'Proterozoic', 'Phanerozoic']);
  });
}
