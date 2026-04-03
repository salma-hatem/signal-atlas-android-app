import 'dart:async';

import 'package:flutter/material.dart';
import '../models/sessions.dart';
import '../services/sessions_service.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';

class SessionProvider extends ChangeNotifier {
  final SessionsService _service;

  SessionProvider(SessionsService sessionsService)
      : _service = sessionsService;

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
      final deviceId = await _waitForDeviceId();
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
    await _service.deleteAll();
    sessions = [];
    totalSamples = 0;

    try {
      final deviceId = await _waitForDeviceId();
      await ApiService.delete(
        "/api/mobile/users_samples",
        query: {
          "device_id": deviceId,
        },
      );
    } catch (e) {
      debugPrint("ERROR in deleting samples: $e");
    }

    await getSamplesServer();
    notifyListeners();
  }

  Future<String> _waitForDeviceId() async {
    if (DeviceService.deviceId.value != null) {
      return DeviceService.deviceId.value!;
    }

    final completer = Completer<String>();

    late VoidCallback listener;
    listener = () {
      final id = DeviceService.deviceId.value;
      if (id != null) {
        DeviceService.deviceId.removeListener(listener);
        completer.complete(id);
      }
    };

    DeviceService.deviceId.addListener(listener);

    return completer.future;
  }
}