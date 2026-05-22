part of 'timeline_extinction_markers.dart';

class _ExtinctionMarker extends StatelessWidget {
  const _ExtinctionMarker({
    required this.label,
    required this.isMajor,
  });

  final String label;
  final bool isMajor;

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ) ??
        const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        );
    final majorStyle = baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 12) + 4,
    );
    if (!isMajor) {
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: baseStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      final markerWidth = math.max(
        textPainter.width,
        ExtinctionMarkers.triangleWidth,
      );
      return SizedBox(
        width: markerWidth,
        height: ExtinctionMarkers.markerHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 0,
              left: (markerWidth - ExtinctionMarkers.triangleWidth) / 2,
              child: CustomPaint(
                size: const Size(
                  ExtinctionMarkers.triangleWidth,
                  ExtinctionMarkers.markerHeight,
                ),
                painter: _TrianglePainter(),
              ),
            ),
            Positioned(
              bottom: ExtinctionMarkers.markerHeight + 3,
              left: 0,
              right: 0,
              child: Text(
                label,
                style: baseStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: majorStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final triangleWidth = ExtinctionMarkers.majorTriangleWidth;
    final markerWidth = math.max(textPainter.width, triangleWidth);

    return SizedBox(
      width: markerWidth,
      height: ExtinctionMarkers.majorMarkerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: (markerWidth - triangleWidth) / 2,
            child: CustomPaint(
              size: Size(triangleWidth, ExtinctionMarkers.majorMarkerHeight),
              painter: _TrianglePainter(),
            ),
          ),
          Positioned(
            bottom: ExtinctionMarkers.majorMarkerHeight + 3,
            left: 0,
            right: 0,
            child: Text(
              label,
              style: majorStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ExtinctionMarkers.markerColor
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

class ExtinctionMarkerLayout {
  const ExtinctionMarkerLayout({
    required this.label,
    required this.shortLabel,
    required this.x,
    required this.isMajor,
  });

  final String label;
  final String shortLabel;
  final double x;
  final bool isMajor;
}
