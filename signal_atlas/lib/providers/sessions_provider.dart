import 'package:flutter/material.dart';
import '../models/sessions.dart';
import '../services/sessions_service.dart';

class SessionProvider extends ChangeNotifier {
  final SessionsService _service;

  SessionProvider(SessionsService sessionsService)
      : _service = sessionsService;

  List<Session> sessions = [];
  int totalSamples = 0;

  // Load everything
  Future<void> loadData() async {
    sessions = await _service.getAllSessions();
    totalSamples = await _service.getTotalSamples();
    notifyListeners();
  }

  // Add session
  Future<void> addSession(Session session) async {
    await _service.insertSession(session);
    await loadData();
  }

  // Delete all
  Future<void> deleteAll() async {
    await _service.deleteAll();
    sessions = [];
    totalSamples = 0;
    notifyListeners();
  }
}