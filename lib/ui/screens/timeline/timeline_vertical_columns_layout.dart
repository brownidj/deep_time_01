import 'package:deep_time/ui/screens/timeline/timeline_orientation.dart';

class TimelineVerticalColumnsLayout {
  const TimelineVerticalColumnsLayout({
    required this.useFixedHeights,
    required this.extinctionLineLeft,
    required this.eventLineLeft,
  });

  final bool useFixedHeights;
  final double extinctionLineLeft;
  final double eventLineLeft;
}

TimelineVerticalColumnsLayout buildVerticalColumnsLayout({
  required List<TimelineTrack> trackOrder,
  required double Function(TimelineTrack track) scaledWidth,
  required double Function(TimelineTrack track) trackWidth,
  required bool useFixedHeights,
}) {
  final trackStarts = <TimelineTrack, double>{};
  var trackCursor = 0.0;
  for (final track in trackOrder) {
    trackStarts[track] = trackCursor;
    final isLast = track == trackOrder.last;
    trackCursor +=
        scaledWidth(track) + trailingGapForTrack(track, isLastVisible: isLast);
  }
  final eraRight =
      (trackStarts[TimelineTrack.era] ?? 0.0) + scaledWidth(TimelineTrack.era);
  final rlifeRight =
      (trackStarts[TimelineTrack.rlife] ?? 0.0) +
      scaledWidth(TimelineTrack.rlife);
  final extLeft = trackStarts[TimelineTrack.extinctions] ?? 0.0;
  final eventsLeft = trackStarts[TimelineTrack.events] ?? 0.0;
  final extinctionLineLeft = rlifeRight - extLeft;
  final eventLineLeft = eraRight - eventsLeft;
  return TimelineVerticalColumnsLayout(
    useFixedHeights: useFixedHeights,
    extinctionLineLeft: extinctionLineLeft,
    eventLineLeft: eventLineLeft,
  );
}
