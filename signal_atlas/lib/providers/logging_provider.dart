import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:signal_atlas/utilities/constants.dart';
import 'package:signal_atlas/services/logging_manager.dart';
import 'package:signal_atlas/services/network_readings_service.dart';
import 'package:signal_atlas/providers/sessions_provider.dart';
import 'package:signal_atlas/providers/server_health_provider.dart';

class LoggingProvider extends ChangeNotifier {
  final LoggingManager _manager;
  final ServerHealthProvider serverHealthProvider;
  final SessionProvider sessionProvider;
  late VoidCallback _serverListener;
  late StreamSubscription _readingSub;

  LoggingProvider(
      NetworkReadingsService readingService,
      this.sessionProvider,
      this.serverHealthProvider,
      FlutterLocalNotificationsPlugin notificationsPlugin,
      ) : _manager = LoggingManager(readingService, sessionProvider, notificationsPlugin,) {
    sessionProvider.attachLoggingManager(_manager);

    // Update UI when new readings arrive in the stream
    _readingSub = readingService.readingStream.listen((_) {
      notifyListeners();
    });

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
  double get currentSendingRatePerMinute => _manager.currentSendingRatePerMinute;

  bool get canLog => serverHealthProvider.state == ServerState.success;


  Future<void> toggleLogging() async {
    if (!canLog) return; // block logging if server offline

    if (_manager.isLogging) {
      await _manager.stopLogging();
    } else {
      _manager.startLogging();
    }
    notifyListeners();
  }

  double? get currentSpeedKmh => _manager.currentSpeedMps;

  @override
  void dispose() {
    _readingSub.cancel();
    serverHealthProvider.removeListener(_serverListener);
    _manager.stopLogging();
    super.dispose();
  }
}