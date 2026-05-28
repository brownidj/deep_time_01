class PaleoEcologyEntry {
  const PaleoEcologyEntry({
    required this.stage,
    required this.avgTempDeltaC,
    required this.avgHumidityDeltaPercent,
    required this.avgCo2Ppm,
    required this.seaLevelDeltaM,
  });

  final String stage;
  final double avgTempDeltaC;
  final double avgHumidityDeltaPercent;
  final double avgCo2Ppm;
  final double seaLevelDeltaM;
}
