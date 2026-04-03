import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'api_service.dart';
import 'network_readings_service.dart';
import '../providers/sessions_provider.dart';
import '../models/network_reading.dart';
import '../models/sessions.dart';

class LoggingManager {
  final NetworkReadingsService readingsService;
  final SessionProvider sessionProvider;

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

  LoggingManager(this.readingsService, this.sessionProvider, {this.batchSize = 2});

  void startLogging({Duration? interval}) {
    if (_isLogging) return;

    sessionSaved = false;
    samplesSentCount = 0;
    sessionStart = DateTime.now();
    _isLogging = true;
    sendInterval = interval ?? Duration(seconds: 2);

    debugPrint("started logging");

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
    if (!sessionSaved) {
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
  }

  bool get isLogging => _isLogging; // getter for private bool
}
