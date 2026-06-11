import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/network_reading.dart';
import '../utilities//constants.dart';

class ApiService {
  static final baseUrl = ApiConfig.baseUrl;
  static const _apiKey = ApiConfig.apiKey;
  static const _tokenKey = 'signal_atlas_access_token';
  static const _refreshTokenKey = 'signal_atlas_refresh_token';

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-API-Key': _apiKey,
    };
    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<String?> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode != 200) {
        await prefs.remove(_tokenKey);
        await prefs.remove(_refreshTokenKey);
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final newToken = data['access_token'] as String?;
      final newRefresh = data['refresh_token'] as String?;

      if (newToken != null) await prefs.setString(_tokenKey, newToken);
      if (newRefresh != null) await prefs.setString(_refreshTokenKey, newRefresh);

      return newToken;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return null;
    }
  }

  static Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: query?.map((key, value) => MapEntry(key, value.toString())),
    );

    final headers = await _headers(auth: auth);

    http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'PATCH':
        response = await http.patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // Token expired — try refresh once
    if (response.statusCode == 401 && auth) {
      final newToken = await _refreshToken();
      if (newToken != null) {
        headers['Authorization'] = 'Bearer $newToken';
        switch (method) {
          case 'GET':
            response = await http.get(uri, headers: headers);
            break;
          case 'POST':
            response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
            break;
          case 'PATCH':
            response = await http.patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers);
            break;
        }
      }
    }

    if (response.statusCode == 204) return null;

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(
      (data is Map ? (data['detail'] ?? data['message'] ?? 'API error') : 'API error') as String,
    );
  }

  /// Store auth tokens after login/register
  static Future<void> storeTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  /// Clear auth tokens on logout
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Convenience methods
  static Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = false}) {
    return _request('GET', path, query: query, auth: auth);
  }

  static Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = false}) {
    return _request('POST', path, body: body, auth: auth);
  }

  static Future<dynamic> patch(String path, {Map<String, dynamic>? body, bool auth = false}) {
    return _request('PATCH', path, body: body, auth: auth);
  }

  static Future<bool> delete(String path, {Map<String, dynamic>? query, bool auth = false}) async {
    try {
      await _request('DELETE', path, query: query, auth: auth);
      return true;
    } catch (e) {
      debugPrint('DELETE error: $e');
      return false;
    }
  }

  // ── Legacy methods (kept for backward compatibility) ──

  static Future<bool> sendReading(NetworkReading reading) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse('$baseUrl/api/network-data'),
        headers: headers,
        body: jsonEncode(reading.toApiPayload()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Upload failed: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> sendBatch(List<NetworkReading> readings) async {
    final jsonList = readings.map((r) => r.toApiPayload()).toList();
    final payload = {"readings": jsonList};

    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse('$baseUrl/api/network-data/batch'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  static Future<bool> checkHealth() async {
    try {
      final headers = await _headers();
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      );
      debugPrint('Health check response status: ${response.statusCode} on server $baseUrl/health');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check error: $e');
      return false;
    }
  }
}
