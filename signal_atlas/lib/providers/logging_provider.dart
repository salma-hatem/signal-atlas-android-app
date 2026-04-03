import 'package:flutter/material.dart';
import 'package:signal_atlas/services/logging_manager.dart';
import 'package:signal_atlas/services/network_readings_service.dart';
import 'package:signal_atlas/services/sessions_service.dart';

class LoggingProvider extends ChangeNotifier {
  final LoggingManager _manager;

  LoggingProvider(NetworkReadingsService readingService, SessionsService sessionsService)
      : _manager = LoggingManager(readingService, sessionsService);

  bool get isLogging => _manager.isLogging;

  void toggleLogging() {
    if (_manager.isLogging) {
      _manager.stopLogging();
    } else {
      _manager.startLogging();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _manager.stopLogging();
    super.dispose();
  }
}