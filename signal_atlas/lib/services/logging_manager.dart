import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_service.dart';
import 'location_tracking_service.dart';
import 'network_readings_service.dart';
import '../providers/sessions_provider.dart';
import '../models/network_reading.dart';
import '../models/sessions.dart';

class LoggingManager extends ChangeNotifier {
  final NetworkReadingsService readingsService;
  final SessionProvider sessionProvider;
  final FlutterLocalNotificationsPlugin notificationsPlugin;
  final LocationTrackingService locationService;

  Timer? timer;
  Duration _sendInterval = Duration(seconds: 2);
  List<NetworkReading> buffer = [];
  final int batchSize;
  bool _isLogging = false;
  bool _isSending = false;
  DateTime? _stationarySince;
  DateTime? _movingSince;
  String? _lastSentSignature; // avoid sending same reading more than once

  // keep track of how many samples were successfully sent in the session
  int samplesSentCount = 0;
  late DateTime sessionStart;
  late DateTime sessionEnd;
  bool sessionSaved = false;

  LoggingManager(
      this.readingsService,
      this.locationService,
      this.sessionProvider,
      this.notificationsPlugin,
      {this.batchSize = 2}
  );

  Future<void> startLogging({Duration? interval}) async {
    if (_isLogging) return;

    sessionSaved = false;
    samplesSentCount = 0;
    sessionStart = DateTime.now();
    _isLogging = true;
    _sendInterval = interval ?? Duration(seconds: 2);

    _scheduleNextTick();

    await notificationsPlugin.show(
      id: 2,
      title: 'Signal Atlas',
      body: 'Logging is running in background',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'logging_channel',
          'Logging',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
        ),
      ),
    );
  }

  Future<void> stopLogging() async {
    debugPrint("stopped logging ${buffer.length}");
    if (!_isLogging) return;

    timer?.cancel();
    _isLogging = false;
    // Keep sending until buffer is empty
    while (buffer.isNotEmpty) {
        await sendBatch();
    }

    // Save session once
    if (!sessionSaved && samplesSentCount != 0) {
      sessionEnd = DateTime.now();
      final sessionDuration = sessionEnd.difference(sessionStart);
      Session session = Session(
        date: DateTime.now(),
        duration: sessionDuration,
        sampleCount: samplesSentCount,
      );

      await sessionProvider.addSession(session);
      sessionSaved = true;
      debugPrint("Session saved: $session");
    }

    await notificationsPlugin.cancel(id: 2);
  }

  Future<void> sendBatch() async {
    if (buffer.isEmpty) return;

    _isSending = true;
    final batchToSend = buffer.take(batchSize).toList();

    const maxRetries = 5;
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        await ApiService.sendBatch(batchToSend);
        // Remove readings that hae been successfully sent
        final removeCount = batchToSend.length <= buffer.length
            ? batchToSend.length
            : buffer.length;

        buffer.removeRange(0, removeCount);
        samplesSentCount += removeCount;

        break; // sent successfully
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          debugPrint('Batch failed after $maxRetries attempts: $e');
          break;
        }
        // exponential backoff
        final delay = Duration(seconds: 1 << attempts); // 1 shifted left by attempts bits (1, 2, 4, 8, 16)
        await Future.delayed(delay);
      }
      finally {
        _isSending = false;
      }
    }
    notifyListeners();
  }

  void _scheduleNextTick() {
    if (!_isLogging) return;

    final speed = effectiveSpeedMps;
    _sendInterval = _calculateInterval(speed);

    timer = Timer(_sendInterval, () async {
      final latest = readingsService.latestReading;

      if (latest == null) return;

      final sig = latest.signature;

      // prevent duplicates from being re-added
      if (sig == _lastSentSignature) {
        _scheduleNextTick();
        return;
      }

      buffer.add(latest);
      _lastSentSignature = sig;

      if (buffer.length >= batchSize && !_isSending) {
        await sendBatch();
      }

      _scheduleNextTick(); // reschedule with new interval
    });
  }

  Duration _calculateInterval(double speed) {
    const movingThreshold = 1.2;
    const stationaryThreshold = 0.7;

    if (speed > movingThreshold) {
      _movingSince ??= DateTime.now();

      final movingDuration = DateTime.now().difference(_movingSince!).inSeconds;

      if (movingDuration > 2) {
        _stationarySince = null;
      }

      return _calculateMovingInterval(speed);
    }

    if (speed < stationaryThreshold) {
      _movingSince = null;
      return _calculateStationaryInterval();
    }

    // hysteresis zone -> DO NOT reset timers
    if (_stationarySince != null) {
      return _calculateStationaryInterval();
    } else {
      return _calculateMovingInterval(speed);
    }
  }

  Duration _calculateMovingInterval(double speed) {
    // if (speed < 3) return const Duration(seconds: 6);
    // if (speed < 8) return const Duration(seconds: 4);
    // if (speed < 20) return const Duration(seconds: 3);

    return const Duration(milliseconds: 2500); // hardware limit
  }

  Duration _calculateStationaryInterval() {
    final now = DateTime.now();

    _stationarySince ??= now;

    final secondsStationary =
        now.difference(_stationarySince!).inSeconds;

    // First 10 minutes: keep interval fixed
    const stationaryGracePeriod = 600; // 10 min

    if (secondsStationary < stationaryGracePeriod) {
      return const Duration(milliseconds: 2500);
    }

    // After 10 minutes: begin exponential backoff
    final growthSeconds =
        secondsStationary - stationaryGracePeriod;

    const base = 2.5;
    const growth = 1.5;

    final exponent = (growthSeconds / 30).clamp(0, 10);

    final intervalSeconds =
        base * pow(growth, exponent);

    final capped = intervalSeconds.clamp(2.5, 600);

    return Duration(seconds: capped.toInt());
  }

  double get effectiveSpeedMps {
    final readingSpeed = readingsService.latestReading?.speedMps ?? 0.0;
    final gpsSpeed = locationService.speedMps.value;

    return max(readingSpeed, gpsSpeed);
  }

  double get currentSpeedMps => effectiveSpeedMps;

  double get currentSendingRatePerMinute {
    final seconds = _sendInterval.inMilliseconds / 1000;
    if (seconds <= 0) return 0;
    final minutes = seconds / 60;

    return batchSize / minutes;
  }

  bool get isLogging => _isLogging; // getter for private bool
}
