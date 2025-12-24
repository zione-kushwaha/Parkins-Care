import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../../domain/entities/tremor_reading.dart';

class TremorDetectionService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final _tremorStreamController = StreamController<TremorReading>.broadcast();

  Stream<TremorReading> get tremorStream => _tremorStreamController.stream;

  final List<AccelerometerEvent> _readings = [];
  final int _windowSize = 50; // Number of readings to analyze
  final Duration _samplingInterval = const Duration(milliseconds: 20);

  bool _isMonitoring = false;
  DateTime? _lastReading;

  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _readings.clear();

    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final now = DateTime.now();
      if (_lastReading != null &&
          now.difference(_lastReading!) < _samplingInterval) {
        return;
      }
      _lastReading = now;

      _readings.add(event);

      if (_readings.length > _windowSize) {
        _readings.removeAt(0);
      }

      if (_readings.length == _windowSize) {
        final reading = _analyzeTremor();
        if (reading != null) {
          _tremorStreamController.add(reading);
        }
      }
    });
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _readings.clear();
  }

  TremorReading? _analyzeTremor() {
    if (_readings.isEmpty) return null;

    // Calculate magnitude for each reading
    final magnitudes = _readings.map((e) {
      return sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    }).toList();

    // Calculate average magnitude
    final avgMagnitude = magnitudes.reduce((a, b) => a + b) / magnitudes.length;

    // Calculate variance (measure of tremor intensity)
    final variance =
        magnitudes
            .map((m) {
              final diff = m - avgMagnitude;
              return diff * diff;
            })
            .reduce((a, b) => a + b) /
        magnitudes.length;

    final magnitude = sqrt(variance);

    // Estimate frequency using zero-crossing method
    int crossings = 0;
    for (int i = 1; i < magnitudes.length; i++) {
      if ((magnitudes[i] - avgMagnitude) * (magnitudes[i - 1] - avgMagnitude) <
          0) {
        crossings++;
      }
    }

    // Frequency in Hz (crossings per second)
    final duration = _windowSize * _samplingInterval.inMilliseconds / 1000;
    final frequency = crossings / (2 * duration);

    // Determine severity based on magnitude and frequency
    // Parkinsonian tremor is typically 4-6 Hz
    final severity = _determineSeverity(magnitude, frequency);

    // Get latest accelerometer values
    final latest = _readings.last;
    final accelerometerData = {'x': latest.x, 'y': latest.y, 'z': latest.z};

    return TremorReading(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      magnitude: magnitude,
      frequency: frequency,
      severity: severity,
      accelerometerData: accelerometerData,
    );
  }

  TremorSeverity _determineSeverity(double magnitude, double frequency) {
    // Typical Parkinsonian tremor is 4-6 Hz
    // Magnitude thresholds (calibrated for background monitoring)
    const mildThreshold = 0.4;
    const moderateThreshold = 0.8;
    const severeThreshold = 1.2;

    // Check if frequency is in Parkinsonian range (3-7 Hz)
    final isParkinsonianFrequency = frequency >= 3 && frequency <= 7;

    if (magnitude < mildThreshold) {
      return TremorSeverity.none;
    } else if (magnitude < moderateThreshold) {
      return isParkinsonianFrequency
          ? TremorSeverity.mild
          : TremorSeverity.none;
    } else if (magnitude < severeThreshold) {
      return isParkinsonianFrequency
          ? TremorSeverity.moderate
          : TremorSeverity.mild;
    } else {
      return isParkinsonianFrequency
          ? TremorSeverity.severe
          : TremorSeverity.moderate;
    }
  }

  void dispose() {
    stopMonitoring();
    _tremorStreamController.close();
  }
}
