import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/tremor_reading.dart';

class TremorApiService {
  static const String baseUrl = 'https://pleasing-guppy-hardy.ngrok-free.app';
  static const String token = 'ed225003a17d6a1f59ed894d364c58a2979fa4df';

  /// Send tremor reading data to the backend
  Future<bool> sendTremorData(TremorReading reading) async {
    try {
      final url = Uri.parse('$baseUrl/api/tremor/');

      final payload = {
        'id': reading.id,
        'timestamp': reading.timestamp.toIso8601String(),
        'magnitude': reading.magnitude,
        'frequency': reading.frequency,
        'severity': reading.severity.label,
        'severity_level': reading.severity.index,
        'accelerometer_data': reading.accelerometerData,
        'x_axis': reading.accelerometerData['x'],
        'y_axis': reading.accelerometerData['y'],
        'z_axis': reading.accelerometerData['z'],
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Tremor data sent successfully: ${response.body}');
        return true;
      } else {
        print('❌ Failed to send tremor data: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending tremor data: $e');
      return false;
    }
  }

  /// Send batch tremor readings
  Future<bool> sendBatchTremorData(List<TremorReading> readings) async {
    try {
      final url = Uri.parse('$baseUrl/tremor/batch/');

      final payload = readings
          .map(
            (reading) => {
              'id': reading.id,
              'timestamp': reading.timestamp.toIso8601String(),
              'magnitude': reading.magnitude,
              'frequency': reading.frequency,
              'severity': reading.severity.label,
              'severity_level': reading.severity.index,
              'accelerometer_data': reading.accelerometerData,
              'x_axis': reading.accelerometerData['x'],
              'y_axis': reading.accelerometerData['y'],
              'z_axis': reading.accelerometerData['z'],
            },
          )
          .toList();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
        body: json.encode({'readings': payload}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Batch tremor data sent successfully');
        return true;
      } else {
        print('❌ Failed to send batch tremor data: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending batch tremor data: $e');
      return false;
    }
  }

  /// Get tremor statistics from backend
  Future<Map<String, dynamic>?> getTremorStats() async {
    try {
      final url = Uri.parse('$baseUrl/tremor/stats/');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('❌ Failed to get tremor stats: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting tremor stats: $e');
      return null;
    }
  }
}
