import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/network_reading.dart';
import '../utilities//constants.dart';

class ApiService {
  static final baseUrl = ApiConfig.baseUrl; 
  static const _headers = {
    'Content-Type': 'application/json',
    'X-API-Key': ApiConfig.apiKey,
  };

  // Sending data using POST
  static Future<bool> sendReading(NetworkReading reading) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/network-data'),
        headers: _headers,
        body: jsonEncode(reading.toApiPayload()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Upload failed: $e');
      return false;
    }
  }

  // Send Batch of readings
  static Future<Map<String, dynamic>> sendBatch(List<NetworkReading> readings) async {
    final jsonList = readings.map((r) => r.toApiPayload()).toList();
    final payload = {"readings": jsonList};

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/network-data/batch'),
        headers: _headers,
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
      debugPrint('Error sending batch: $e');
      rethrow;
    }
  }

  // Health-check function
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );
      debugPrint('Health check response status: ${response.statusCode} on server $baseUrl/health');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check error: $e');
      return false;
    }
  }

  // GET function
  static Future<dynamic> get(String path, {Map<String, dynamic>? query,}) async {

    final uri = Uri.parse("$baseUrl$path").replace(
      queryParameters: query?.map(
            (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception("API error");
    }

    return jsonDecode(response.body);
  }
}
