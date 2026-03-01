
class ApiConfig {
  static const String baseUrl = String.fromEnvironment('BASE_URL'); // Container backend url
}

enum ServerState {
  unknown,
  loading,
  success,
  error,
}
