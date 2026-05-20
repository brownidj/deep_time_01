import 'package:flutter/material.dart';
import 'package:gts_01/application/services/timeline_layout_service.dart';

class ExtinctionMarkers extends StatelessWidget {
  const ExtinctionMarkers({
    super.key,
    required this.width,
    required this.periodSegments,
    required this.stageSegments,
  });

  final double width;
  final List<TimelineRowSegment> periodSegments;
  final List<TimelineRowSegment> stageSegments;

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers();
    if (markers.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 10,
      child: Stack(
        children: [
          for (final marker in markers)
            Positioned(
              left: (marker.x - 6).clamp(0.0, width - 12),
              child: Tooltip(
                message: marker.label,
                child: _ExtinctionMarker(label: marker.shortLabel),
              ),
            ),
        ],
      ),
    );
  }

  List<_MarkerData> _buildMarkers() {
    final markers = <_MarkerData>[];
    final periodTotal = _totalUnits(periodSegments);
    final stageTotal = _totalUnits(stageSegments);
    if (periodTotal <= 0) {
      return markers;
    }

    double? boundaryForPeriod(String label) {
      var sum = 0.0;
      for (final segment in periodSegments) {
        sum += segment.unitSpan;
        if (!segment.isGap && segment.label == label) {
          return width * (sum / periodTotal);
        }
      }
      return null;
    }

    double? boundaryForStage(String label) {
      if (stageTotal <= 0) {
        return null;
      }
      var sum = 0.0;
      for (final segment in stageSegments) {
        sum += segment.unitSpan;
        if (!segment.isGap && segment.label == label) {
          return width * (sum / stageTotal);
        }
      }
      return null;
    }

    final ordovician = boundaryForPeriod('Ordovician');
    if (ordovician != null) {
      markers.add(
        _MarkerData(
          label: 'End-Ordovician extinction',
          shortLabel: 'E-O',
          x: ordovician,
        ),
      );
    }

    final lateDevonian = boundaryForStage('Frasnian');
    if (lateDevonian != null) {
      markers.add(
        _MarkerData(
          label: 'Late Devonian extinctions',
          shortLabel: 'LD',
          x: lateDevonian,
        ),
      );
    }

    final permian = boundaryForPeriod('Permian');
    if (permian != null) {
      markers.add(
        _MarkerData(
          label: 'End-Permian extinction',
          shortLabel: 'E-P',
          x: permian,
        ),
      );
    }

    final triassic = boundaryForPeriod('Triassic');
    if (triassic != null) {
      markers.add(
        _MarkerData(
          label: 'End-Triassic extinction',
          shortLabel: 'E-T',
          x: triassic,
        ),
      );
    }

    final cretaceous = boundaryForPeriod('Cretaceous');
    if (cretaceous != null) {
      markers.add(
        _MarkerData(
          label: 'End-Cretaceous / K-Pg extinction',
          shortLabel: 'K-Pg',
          x: cretaceous,
        ),
      );
    }

    return markers;
  }

  double _totalUnits(List<TimelineRowSegment> segments) {
    return segments.fold<double>(0.0, (sum, segment) => sum + segment.unitSpan);
  }
}

class _ExtinctionMarker extends StatelessWidget {
  const _ExtinctionMarker({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFFFFD978),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        CustomPaint(
          size: const Size(12, 10),
          painter: _TrianglePainter(),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD978)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MarkerData {
  const _MarkerData({
    required this.label,
    required this.shortLabel,
    required this.x,
  });

  final String label;
  final String shortLabel;
  final double x;
}
