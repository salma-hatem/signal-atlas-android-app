import 'package:flutter/material.dart';
import '../models/sessions.dart';
import '../services/sessions_service.dart';
import '../services/api_service.dart';
import '../services/logging_manager.dart';
import '../utilities/get_device_id.dart';

class SessionProvider extends ChangeNotifier {
  final SessionsService _service;

  SessionProvider(SessionsService sessionsService)
      : _service = sessionsService;

  // ------------------------------------------------
  // Historical sessions
  // ------------------------------------------------
  List<Session> sessions = [];
  int totalSamples = 0;
  int? totalSamplesServer;

  // Load everything
  Future<void> loadData() async {
    sessions = await _service.getAllSessions();
    totalSamples = await _service.getTotalSamples();
    notifyListeners();
    await getSamplesServer();
  }

  // Add session
  Future<void> addSession(Session session) async {
    await _service.insertSession(session);
    await loadData();
  }

  // Get samples on server
  Future<void> getSamplesServer() async {
    try {
      final deviceId = await waitForDeviceId();
      final res = await ApiService.get(
        "/api/mobile/users_samples",
        query: {"device_id": deviceId},
      );
      totalSamplesServer = (res["total_samples_count"] ?? 0) as int;
    } catch (e) {
      debugPrint("ERROR in getSamplesServer: $e");
    }

    notifyListeners();
  }

  // Delete all
  Future<void> deleteAll() async {
    await _service.deleteNonRequestSessions();

    try {
      final deviceId = await waitForDeviceId();
      await ApiService.delete(
        "/api/mobile/users_samples",
        query: {
          "device_id": deviceId,
        },
      );
    } catch (e) {
      debugPrint("ERROR in deleting samples: $e");
    }

    // refresh local state
    sessions = await _service.getAllSessions();
    totalSamples = await _service.getTotalSamples();

    notifyListeners();
  }

  // ------------------------------------------------
  // Live session
  // ------------------------------------------------
  LoggingManager? _loggingManager;

  bool get isLogging => _loggingManager?.isLogging ?? false;

  int get liveSamples => _loggingManager?.samplesSentCount ?? 0;

  Duration get liveDuration {
    if (_loggingManager == null) return Duration.zero;
    if (!_loggingManager!.isLogging) return Duration.zero;
    return DateTime.now().difference(_loggingManager!.sessionStart);
  }

  void attachLoggingManager(LoggingManager manager) {
    _loggingManager = manager;

    manager.addListener(() {
      notifyListeners();
    });
  }

}