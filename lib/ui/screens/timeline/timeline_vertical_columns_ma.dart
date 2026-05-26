part of 'timeline_vertical_columns.dart';

class _MaColumn extends StatelessWidget {
  const _MaColumn({
    required this.width,
    required this.height,
    required this.layout,
    required this.metrics,
  });

  final double width;
  final double height;
  final TimelineLayoutSnapshot layout;
  final TimelineBodyMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
    final minLabelGap = _minLabelGap(labelStyle);
    final labels = <_MaLabel>[];
    final seen = <String>{};
    final eonBoundaries = metrics.eonBoundaryYs;
    for (var i = 0; i < eonBoundaries.length; i++) {
      final boundaryStartMa = layout.eonSegments[i + 1].startMa;
      final text = _formatMaLabel(boundaryStartMa);
      if (seen.add(text)) {
        labels.add(_MaLabel(text: text, y: eonBoundaries[i]));
      }
    }
    final eraBoundaries = metrics.eraBoundaryYs;
    for (var i = 0; i < eraBoundaries.length; i++) {
      final boundaryStartMa = layout.eraSegments[i + 1].startMa;
      final text = _formatMaLabel(boundaryStartMa);
      if (seen.add(text)) {
        labels.add(_MaLabel(text: text, y: eraBoundaries[i]));
      }
    }
    final periodBoundaries = metrics.periodBoundaryYs;
    for (var i = 0; i < periodBoundaries.length; i++) {
      final boundaryStartMa = layout.periodSegments[i + 1].startMa;
      final text = _formatMaLabel(boundaryStartMa);
      if (seen.add(text)) {
        labels.add(_MaLabel(text: text, y: periodBoundaries[i]));
      }
    }
    final resolved = _resolveLabelCollisions(labels, minGap: minLabelGap);

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: DeepTimePalette.frameBorder),
        child: Stack(
          children: [
            for (final label in resolved)
              _MaLabelWidget(
                label: label,
                width: width,
                height: height,
                style: labelStyle,
              ),
          ],
        ),
      ),
    );
  }
}

class _MaLabelWidget extends StatelessWidget {
  const _MaLabelWidget({
    required this.label,
    required this.width,
    required this.height,
    required this.style,
  });

  final _MaLabel label;
  final double width;
  final double height;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: label.text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final top = (label.y - (painter.height / 2)).clamp(0.0, height);
    return Positioned(
      top: top,
      width: width,
      child: Center(child: Text(label.text, style: style)),
    );
  }
}

class _MaLabel {
  const _MaLabel({required this.text, required this.y});

  final String text;
  final double y;
}

double _minLabelGap(TextStyle? style) {
  final painter = TextPainter(
    text: TextSpan(text: '9999', style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.height + 6;
}

List<_MaLabel> _resolveLabelCollisions(
  List<_MaLabel> labels, {
  required double minGap,
}) {
  if (labels.isEmpty) {
    return labels;
  }
  final sorted = labels.toList()..sort((a, b) => a.y.compareTo(b.y));
  final resolved = <_MaLabel>[];
  var lastY = -double.infinity;
  for (final label in sorted) {
    final y = label.y < lastY + minGap ? lastY + minGap : label.y;
    resolved.add(_MaLabel(text: label.text, y: y));
    lastY = y;
  }
  return resolved;
}

String _formatMaLabel(double value) {
  return value.toStringAsFixed(1);
}
