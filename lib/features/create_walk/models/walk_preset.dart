class WalkPreset {
  const WalkPreset({
    required this.key,
    required this.name,
    required this.minSpeedMph,
    required this.warningSeconds,
    required this.warnings,
    required this.decayMinutes,
  });

  final String key;
  final String name;
  final double minSpeedMph;
  final int warningSeconds;
  final int warnings;
  final int decayMinutes;
}
