part of 'timeline_vertical_columns.dart';

class _VerticalCladeBarLayout {
  const _VerticalCladeBarLayout({
    required this.clade,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.parent,
  });

  final Clade clade;
  final double left;
  final double top;
  final double width;
  final double height;
  final Clade? parent;

  String get tooltip {
    return '${clade.label} • '
        '${formatTimeRange(startMa: clade.startMa, endMa: clade.endMa, startPrecision: 1, endPrecision: 1, durationPrecision: 1)}';
  }
}

class _VerticalCladeConnectorLayout {
  const _VerticalCladeConnectorLayout({
    required this.parent,
    required this.child,
    required this.left,
    required this.top,
    required this.width,
  });

  final Clade parent;
  final Clade child;
  final double left;
  final double top;
  final double width;
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
  static const Color labelBackgroundColor =
      DeepTimePalette.timelineGapBackground;

  @override
  Widget build(BuildContext context) {
    final color = isHighlighted ? highlightColor : baseColor;
    final opacity = isDimmed ? 0.35 : 1.0;
    final showLabel = height >= 32;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );
    final lineWidth = isHighlighted ? 3.0 : 2.0;
    const labelBandWidth = 28.0;

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: lineWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (showLabel)
              Positioned(
                left: -(labelBandWidth - lineWidth) / 2,
                top: 10,
                width: labelBandWidth,
                child: Center(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: labelBackgroundColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
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
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
