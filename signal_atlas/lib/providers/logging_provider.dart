import 'package:flutter/material.dart';
import 'package:signal_atlas/utilities/constants.dart';
import 'package:signal_atlas/services/logging_manager.dart';
import 'package:signal_atlas/services/network_readings_service.dart';
import 'package:signal_atlas/providers/sessions_provider.dart';
import 'package:signal_atlas/providers/server_health_provider.dart';

class LoggingProvider extends ChangeNotifier {
  final LoggingManager _manager;
  final ServerHealthProvider serverHealthProvider;
  late VoidCallback _serverListener;

  LoggingProvider(
      NetworkReadingsService readingService,
      SessionProvider sessionProvider,
      this.serverHealthProvider
      ) : _manager = LoggingManager(readingService, sessionProvider) {

    // listen to stop logging if server offline
    _serverListener = () {
      if (serverHealthProvider.state != ServerState.success &&
          _manager.isLogging) {
        _manager.stopLogging();
        notifyListeners();
      }
    };

    serverHealthProvider.addListener(_serverListener);
  }

  bool get isLogging => _manager.isLogging;

  bool get canLog => serverHealthProvider.state == ServerState.success;


  void toggleLogging() {
    if (!canLog) return; // block logging if server offline

    if (_manager.isLogging) {
      _manager.stopLogging();
    } else {
      _manager.startLogging();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    serverHealthProvider.removeListener(_serverListener);
    _manager.stopLogging();
    super.dispose();
  }
}