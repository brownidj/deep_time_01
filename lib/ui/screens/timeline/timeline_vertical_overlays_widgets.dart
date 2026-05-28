part of 'timeline_vertical_overlays.dart';

class _DebugBoundaryLabel extends StatelessWidget {
  const _DebugBoundaryLabel({
    required this.x,
    required this.text,
    required this.color,
  });

  final double x;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x + 2,
      top: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        color: Colors.black87,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HorizontalBoundaryMarker extends StatelessWidget {
  const _HorizontalBoundaryMarker({
    required this.left,
    required this.right,
    required this.top,
    required this.contentHeight,
  });

  final double left;
  final double right;
  final double top;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    final width = right - left;
    if (width <= 0) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: left,
      top: (top - 1.5).clamp(0.0, contentHeight - 3),
      width: width,
      child: Container(height: 3, color: DeepTimePalette.periodDivider),
    );
  }
}
