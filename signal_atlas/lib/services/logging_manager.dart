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
import '../utilities/constants.dart';

class LoggingManager extends ChangeNotifier {
  final NetworkReadingsService readingsService;
  final SessionProvider sessionProvider;
  final FlutterLocalNotificationsPlugin notificationsPlugin;
  final LocationTrackingService locationService;

  Timer? timer;
  Duration _sendInterval = Duration(seconds: 2);
  List<NetworkReading> buffer = [];
  final int batchSize;
  int? activeRequestId;
  String? activeRequestTitle;

  bool _isLogging = false;
  bool _isSending = false;
  bool _isStopping = false;
  bool get isStopping => _isStopping;
  DateTime? _stationarySince;
  DateTime? _movingSince;
  String? _lastSentSignature; // avoid sending same reading more than once

  // keep track of how many samples were successfully sent in the session
  int samplesSentCount = 0;
  int _samplesFailedCount = 0; // how many failed samples sent in the session
  late DateTime sessionStart;
  late DateTime sessionEnd;
  bool sessionSaved = false;

  // Upload status
  UploadStatus _uploadStatus = UploadStatus.idle;
  String? _statusMessage;

  UploadStatus get uploadStatus => _uploadStatus;
  String? get statusMessage => _statusMessage;

  LoggingManager(
      this.readingsService,
      this.locationService,
      this.sessionProvider,
      this.notificationsPlugin,
      {this.batchSize = 2}
  );

  // -------------- Core Functions --------------
  Future<void> startLogging({Duration? interval, int? requestId, String? requestTitle}) async {
    if (_isLogging) return;

    // reset EVERYTHING
    timer?.cancel();
    timer = null;

    _uploadStatus = UploadStatus.idle;
    _statusMessage = null;

    _samplesFailedCount = 0;
    samplesSentCount = 0;

    _lastSentSignature = null;
    buffer.clear();

    _stationarySince = null;
    _movingSince = null;

    sessionSaved = false;
    sessionStart = DateTime.now();

    activeRequestId = requestId;
    activeRequestTitle = requestTitle;

    _isLogging = true;
    _sendInterval = interval ?? const Duration(seconds: 2);

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
    if (!_isLogging) return;
    if (_isStopping) return;

    _isStopping = true;
    notifyListeners();

    try {
      timer?.cancel();
      _isLogging = false;
      // Keep sending until buffer is empty
      while (buffer.isNotEmpty && _isLogging == false) {
        final before = buffer.length;

        await sendBatch();

        // prevent infinite loop if nothing changed
        if (buffer.length == before) {
          debugPrint("Buffer stuck, aborting flush");
          break;
        }
      }

      // Save session once
      if (!sessionSaved && samplesSentCount != 0) {
        sessionEnd = DateTime.now();
        final sessionDuration = sessionEnd.difference(sessionStart);
        Session session = Session(
          date: DateTime.now(),
          duration: sessionDuration,
          sampleCount: samplesSentCount,
          isCoverageRequest: activeRequestId != null,
          requestId: activeRequestId,
          requestTitle: activeRequestTitle,
        );

        await sessionProvider.addSession(session);
        sessionSaved = true;
        debugPrint("Session saved: $session");
      }

      await notificationsPlugin.cancel(id: 2);

      activeRequestId = null;
    } finally {
      _isStopping = false;
      notifyListeners();
    }
  }

  Future<void> sendBatch() async {
    if (buffer.isEmpty) return;

    _isSending = true;

    try {
      List<NetworkReading> pendingBatch = buffer.take(batchSize).toList();

      const maxRetries = 5;
      int attempts = 0;

      final Set<String> permanentlyFailed = {};

      while (attempts < maxRetries && pendingBatch.isNotEmpty) {
        try {
          final result = await ApiService.sendBatch(pendingBatch);
          final int successful = result["successful"] ?? 0;
          final failedDetails = (result["details"] as List<dynamic>? ?? []);

          // count successful uploads
          samplesSentCount += successful;

          // determine failed indexes
          final failedIndexes = failedDetails
              .map((e) => e["index"] as int)
              .toSet();

          // keep only failed readings for retry
          final stillPending = pendingBatch
              .asMap()
              .entries
              .where((e) => failedIndexes.contains(e.key))
              .map((e) => e.value)
              .toList();

          // update retry set
          pendingBatch = stillPending;

          // remove successful ones from main buffer
          final failedSignatures = pendingBatch
              .map((e) => e.signature)
              .toSet();

          buffer.removeWhere((r) => !failedSignatures.contains(r.signature));

          if (stillPending.isEmpty) {
            _setStatus(
              UploadStatus.success,
              'Samples uploaded successfully',
            );
            break; // everything succeeded
          }

          attempts++;
          _setStatus(
            UploadStatus.retrying,
            'Retrying ${pendingBatch.length} failed samples '
                '($attempts/$maxRetries)',
          );

          final delay = Duration(seconds: 1 << attempts);
          await Future.delayed(delay);

        } catch (e) {
          attempts++;

          if (attempts >= maxRetries) {
            _setStatus(
              UploadStatus.failed,
              'Failed to upload samples',
            );
            debugPrint(
              'Batch failed after $maxRetries attempts: $e',
            );
            break;
          }

          _setStatus(
            UploadStatus.retrying,
            'Connection issue, retrying... '
                '($attempts/$maxRetries)',
          );

          // exponential backoff
          final delay = Duration(seconds: 1 << attempts); // 1 shifted left by attempts bits (1, 2, 4, 8, 16)
          await Future.delayed(delay);
        }
      }
      if (pendingBatch.isNotEmpty) {

        permanentlyFailed.addAll(
          pendingBatch.map((e) => e.signature),
        );

        // REMOVE permanently failed readings
        final failedSignatures = permanentlyFailed.toSet();

        buffer.removeWhere(
              (r) => failedSignatures.contains(r.signature),
        );

        _samplesFailedCount += permanentlyFailed.length;

        _setStatus(
          UploadStatus.failed,
          'Failed to send ${permanentlyFailed.length} readings',
        );
      }
    } finally {
      _isSending = false;
    }

    notifyListeners();
  }

  // -------------- Adaptive Sampling Functions --------------
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

      buffer.add(
        latest.copyWith(
          requestId: activeRequestId,
        ),
      );

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

  // -------------- Upload Status --------------
  void _setStatus(
      UploadStatus status,
      String? message,
      ) {
    _uploadStatus = status;
    _statusMessage = message;
    notifyListeners();
  }

  bool get isLogging => _isLogging; // getter for private bool
  int get samplesFailedCount => _samplesFailedCount;
}
