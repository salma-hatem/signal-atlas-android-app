import 'package:flutter/services.dart';

class ApiConfig {
  static const String baseUrl = String.fromEnvironment('BASE_URL'); // Container backend url
  static const String apiKey = String.fromEnvironment('API_KEY'); 
}

enum ServerState {
  unknown,
  loading,
  success,
  error,
}

class AndroidChannel {
  static const channel = MethodChannel('com.example.signal_atlas');
}
