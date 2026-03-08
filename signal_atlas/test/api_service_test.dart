import 'package:flutter_test/flutter_test.dart';
import 'package:signal_atlas/services/api_service.dart';

void main() {
  group('ApiService', () {
    test('health check returns true', () async {
      final result = await ApiService.checkHealth();
      expect(result, true);
    });
  });
}
