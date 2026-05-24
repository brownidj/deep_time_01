part of 'timeline_vertical_columns.dart';

class _RightTrianglePainter extends CustomPainter {
  const _RightTrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width, size.height / 2)
      ..lineTo(0, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RightTrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
