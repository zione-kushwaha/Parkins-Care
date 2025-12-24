class TremorReading {
  final String id;
  final DateTime timestamp;
  final double magnitude;
  final double frequency;
  final TremorSeverity severity;
  final Map<String, double> accelerometerData; // x, y, z values

  const TremorReading({
    required this.id,
    required this.timestamp,
    required this.magnitude,
    required this.frequency,
    required this.severity,
    required this.accelerometerData,
  });
}

enum TremorSeverity { none, mild, moderate, severe }

extension TremorSeverityExtension on TremorSeverity {
  String get label {
    switch (this) {
      case TremorSeverity.none:
        return 'No Tremor';
      case TremorSeverity.mild:
        return 'Mild';
      case TremorSeverity.moderate:
        return 'Moderate';
      case TremorSeverity.severe:
        return 'Severe';
    }
  }

  String get description {
    switch (this) {
      case TremorSeverity.none:
        return 'No significant tremor detected';
      case TremorSeverity.mild:
        return 'Slight tremor, minimal impact';
      case TremorSeverity.moderate:
        return 'Noticeable tremor, may affect activities';
      case TremorSeverity.severe:
        return 'Severe tremor, significant impact';
    }
  }
}
