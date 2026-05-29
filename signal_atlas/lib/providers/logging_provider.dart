import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signal_atlas/utilities/constants.dart';
import 'package:signal_atlas/services/logging_manager.dart';
import 'package:signal_atlas/services/network_readings_service.dart';
import 'package:signal_atlas/providers/sessions_provider.dart';
import 'package:signal_atlas/providers/server_health_provider.dart';
import '../services/location_tracking_service.dart';


class LoggingProvider extends ChangeNotifier {
  final LoggingManager _manager;
  late VoidCallback _managerListener;
  final ServerHealthProvider serverHealthProvider;
  final SessionProvider sessionProvider;
  late VoidCallback _serverListener;
  late StreamSubscription _readingSub;
  final LocationTrackingService locationService;

  LoggingProvider(
      NetworkReadingsService readingService,
      this.sessionProvider,
      this.serverHealthProvider,
      this.locationService,
      FlutterLocalNotificationsPlugin notificationsPlugin,
      ) : _manager = LoggingManager(readingService, locationService, sessionProvider, notificationsPlugin,) {
    sessionProvider.attachLoggingManager(_manager);

    // Update UI when new readings arrive in the stream
    _readingSub = readingService.readingStream.listen((_) {
      notifyListeners();
    });

    // listen to stop logging if server offline
    _serverListener = () {
      final isOffline =
          serverHealthProvider.state != ServerState.success;

      // stop logging only when needed
      if (isOffline && _manager.isLogging) {
        _manager.stopLogging();
      }

      notifyListeners();
    };

    serverHealthProvider.addListener(_serverListener);

    // listen to update upload status
    _managerListener = () {
      notifyListeners();
    };

    _manager.addListener(_managerListener);
  }

  bool get isLogging => _manager.isLogging;
  double get currentSendingRatePerMinute => _manager.currentSendingRatePerMinute;
  double get currentSpeedMps => _manager.currentSpeedMps;
  int? get activeRequestId => _manager.activeRequestId;

  bool get canLog => serverHealthProvider.state == ServerState.success;
  bool get isStopping => _manager.isStopping;

  UploadStatus get uploadStatus => _manager.uploadStatus;
  String? get statusMessage => _manager.statusMessage;
  int get samplesFailedCount => _manager.samplesFailedCount;

  bool _skipCoverageWarning = false;
  bool get skipCoverageWarning => _skipCoverageWarning;

  Future<void> toggleLogging({
    int? requestId,
    String? requestTitle,
  }) async {
    if (!canLog) return; // block logging if server offline

    if (_manager.isLogging) {
      await _manager.stopLogging();
    } else {
      await _manager.startLogging(requestId: requestId, requestTitle: requestTitle);
    }
    notifyListeners();
  }

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _skipCoverageWarning = prefs.getBool('skipCoverageWarning') ?? false;
    notifyListeners();
  }

  Future<void> setSkipCoverageWarning(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('skipCoverageWarning', value);
    _skipCoverageWarning = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _readingSub.cancel();
    serverHealthProvider.removeListener(_serverListener);
    _manager.stopLogging();
    _manager.removeListener(_managerListener);
    super.dispose();
  }
}