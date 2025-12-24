import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tremor_reading.dart';

class TremorReadingModel extends TremorReading {
  const TremorReadingModel({
    required super.id,
    required super.timestamp,
    required super.magnitude,
    required super.frequency,
    required super.severity,
    required super.accelerometerData,
  });

  factory TremorReadingModel.fromEntity(TremorReading reading) {
    return TremorReadingModel(
      id: reading.id,
      timestamp: reading.timestamp,
      magnitude: reading.magnitude,
      frequency: reading.frequency,
      severity: reading.severity,
      accelerometerData: reading.accelerometerData,
    );
  }

  factory TremorReadingModel.fromJson(Map<String, dynamic> json) {
    return TremorReadingModel(
      id: json['id'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      magnitude: (json['magnitude'] as num).toDouble(),
      frequency: (json['frequency'] as num).toDouble(),
      severity: TremorSeverity.values.firstWhere(
        (e) => e.toString() == json['severity'],
        orElse: () => TremorSeverity.none,
      ),
      accelerometerData: Map<String, double>.from(
        (json['accelerometerData'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': Timestamp.fromDate(timestamp),
      'magnitude': magnitude,
      'frequency': frequency,
      'severity': severity.toString(),
      'accelerometerData': accelerometerData,
    };
  }
}
