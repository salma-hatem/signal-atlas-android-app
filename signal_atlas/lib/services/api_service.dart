import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/network_reading.dart';
import '../utilities//constants.dart';

class ApiService {
  static final baseUrl = ApiConfig.baseUrl;

  // Sending data using POST
  static Future<bool> sendReading(NetworkReading reading) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/network-data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reading.toApiPayload()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Upload failed: $e');
      return false;
    }
  }

  // Send Batch of readings
  static Future<Map<String, dynamic>> sendBatch(List<NetworkReading> readings) async {
    final jsonList = readings.map((r) => r.toApiPayload()).toList();
    final payload = {"readings": jsonList};

    print("sending batch: ${jsonEncode(payload)}");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/network-data/batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse JSON response
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending batch: $e');
      rethrow;
    }
  }

  // Health-check function
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      print('Health check response status: ${response.statusCode} on server $baseUrl/health');
      return response.statusCode == 200;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

}