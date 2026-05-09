import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_service.dart';
import 'network_readings_service.dart';
import '../providers/sessions_provider.dart';
import '../models/network_reading.dart';
import '../models/sessions.dart';

class LoggingManager extends ChangeNotifier {
  final NetworkReadingsService readingsService;
  final SessionProvider sessionProvider;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  Timer? timer;
  Duration sendInterval = Duration(seconds: 2);
  List<NetworkReading> buffer = [];
  final int batchSize;
  bool _isLogging = false;
  bool _isSending = false;

  // keep track of how many samples were successfully sent in the session
  int samplesSentCount = 0;
  late DateTime sessionStart;
  late DateTime sessionEnd;
  bool sessionSaved = false;

  LoggingManager(
      this.readingsService,
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
    sendInterval = interval ?? Duration(seconds: 2);

    debugPrint("started logging");

    await readingsService.startBackgroundService();

    timer = Timer.periodic(sendInterval, (_) async {
      final latest = readingsService.latestReading;
      debugPrint("timer $latest");
      if (latest != null) {
        buffer.add(latest);
      }
      if (buffer.length >= batchSize  && !_isSending) {
        await sendBatch();
      }
    });
    print("NOTIFICATION");
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
    int flushAttempts = 0;
    const maxFlushAttempts = 20;
    while (buffer.isNotEmpty && flushAttempts < maxFlushAttempts) {
        await sendBatch();
        flushAttempts++;
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

    await readingsService.stopBackgroundService();
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
        final delay = Duration(seconds: 1 << attempts);
        await Future.delayed(delay);
      }
    }
    _isSending = false;
    notifyListeners();
  }

  bool get isLogging => _isLogging; // getter for private bool
}
