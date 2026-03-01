import 'package:flutter/material.dart';
import 'package:signal_atlas/utilities/constants.dart';
import 'package:signal_atlas/services/api_service.dart';

class ServerHealthProvider extends ChangeNotifier {
  ServerState _state = ServerState.unknown;
  ServerState get state => _state;

  Future<void> checkHealth() async {
    _state = ServerState.loading;
    notifyListeners();

    final isHealthy = await ApiService.checkHealth();

    _state = isHealthy
        ? ServerState.success
        : ServerState.error;

    notifyListeners();
  }
}
