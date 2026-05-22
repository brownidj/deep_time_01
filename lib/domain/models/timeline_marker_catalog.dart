enum TimelineEventKind { bar, point }

class TimelineEventDefinition {
  const TimelineEventDefinition({
    required this.label,
    required this.shortLabel,
    required this.kind,
    this.startMa,
    this.endMa,
    this.atMa,
  });

  final String label;
  final String shortLabel;
  final TimelineEventKind kind;
  final double? startMa;
  final double? endMa;
  final double? atMa;
}

enum ExtinctionAnchorType { period, stage, ma }

class ExtinctionAnchor {
  const ExtinctionAnchor({
    required this.type,
    this.label,
    this.ma,
  });

  final ExtinctionAnchorType type;
  final String? label;
  final double? ma;
}

class ExtinctionDefinition {
  const ExtinctionDefinition({
    required this.label,
    required this.shortLabel,
    required this.isMajor,
    required this.anchor,
  });

  final String label;
  final String shortLabel;
  final bool isMajor;
  final ExtinctionAnchor anchor;
}

class TimelineMarkerCatalog {
  const TimelineMarkerCatalog({
    required this.events,
    required this.extinctions,
  });

  final List<TimelineEventDefinition> events;
  final List<ExtinctionDefinition> extinctions;
}
