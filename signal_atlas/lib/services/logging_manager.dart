import 'dart:async';
import 'api_service.dart';
import 'network_readings_service.dart';
import '../models/network_reading.dart';

class LoggingManager {
  final NetworkReadingsService readingsService;

  Timer? timer;
  Duration sendInterval = Duration(seconds: 2);
  List<NetworkReading> buffer = [];
  final int batchSize;
  bool _isLogging = false;
  bool _isSending = false;

  LoggingManager(this.readingsService, {this.batchSize = 2});

  void startLogging({Duration? interval}) {
    if (_isLogging) return;

    _isLogging = true;
    sendInterval = interval ?? Duration(seconds: 2);

    print("started logging");

    timer = Timer.periodic(sendInterval, (_) async {
      final latest = readingsService.latestReading;
      print("timer ${latest}");
      if (latest != null) {
        buffer.add(latest);
      }
      if (buffer.length >= batchSize  && !_isSending) {
        await sendBatch();
      }
    });
  }

  Future<void> stopLogging() async {
    print("stopped logging ${buffer.length}");

    timer?.cancel();
    _isLogging = false;
    // Keep sending until buffer is empty
    while (buffer.isNotEmpty) {
        await sendBatch();
    }
  }

  Future<void> sendBatch() async {
    print("called sendbatch");
    if (buffer.isEmpty) return;

    _isSending = true;

    final batchToSend = buffer.take(batchSize).toList();

    const maxRetries = 5;
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        await ApiService.sendBatch(batchToSend);
        // Remove readings that hae been successfully sent
        buffer.removeRange(0, batchToSend.length);
        break; // sent successfully
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          print('Batch failed after $maxRetries attempts: $e');
          break;
        }
        // exponential backoff
        final delay = Duration(seconds: 1 << attempts); // 1 shifted left by attempts bits (1, 2, 4, 8, 16)
        await Future.delayed(delay);
      }
      _isSending = false;
    }
  }

  bool get isLogging => _isLogging; // getter for private bool
}
