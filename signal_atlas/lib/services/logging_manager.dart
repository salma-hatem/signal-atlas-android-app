import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'network_readings_service.dart';
import '../providers/sessions_provider.dart';
import '../models/sessions.dart';

class LoggingManager extends ChangeNotifier {
  final NetworkReadingsService readingsService;
  final SessionProvider sessionProvider;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  StreamSubscription? _samplesSub;
  bool _isLogging = false;
  int samplesSentCount = 0;
  late DateTime sessionStart;
  late DateTime sessionEnd;
  bool sessionSaved = false;

  LoggingManager(
      this.readingsService,
      this.sessionProvider,
      this.notificationsPlugin,
  );

  Future<void> startLogging() async {
    if (_isLogging) return;

    sessionSaved = false;
    samplesSentCount = 0;
    sessionStart = DateTime.now();
    _isLogging = true;

    debugPrint("started logging");

    _samplesSub = readingsService.samplesCountStream.listen((count) {
      samplesSentCount = count;
      notifyListeners();
    });

    await readingsService.startBatching();

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
    debugPrint("stopped logging");
    if (!_isLogging) return;

    _isLogging = false;

    samplesSentCount = await readingsService.stopBatching();

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

    await _samplesSub?.cancel();
    await notificationsPlugin.cancel(id: 2);
  }

  bool get isLogging => _isLogging;
}
