import 'session_db.dart';
import '../models/sessions.dart';

class SessionsService {
  final dbInstance = SessionDB.instance;

  // Insert session
  Future<void> insertSession(Session session) async {
    final db = await dbInstance.database;

    await db.insert(
      'sessions',
      {
        'date': session.date.toIso8601String(),
        'duration': session.duration.inMinutes,
        'sampleCount': session.sampleCount,
      },
    );
  }

  // Get total samples
  Future<int> getTotalSamples() async {
    final db = await dbInstance.database;

    final result = await db.rawQuery(
      'SELECT SUM(sampleCount) as total FROM sessions',
    );

    return result.first['total'] as int? ?? 0;
  }

  // Delete all
  Future<void> deleteAll() async {
    final db = await dbInstance.database;
    await db.delete('sessions');
  }

  // Get all sessions
  Future<List<Session>> getAllSessions() async {
    final db = await dbInstance.database;

    final maps = await db.query('sessions', orderBy: 'date DESC');

    return maps.map((e) {
      return Session(
        date: DateTime.parse(e['date'] as String),
        duration: Duration(minutes: e['duration'] as int),
        sampleCount: e['sampleCount'] as int,
      );
    }).toList();
  }

  Future<List<Session>> getLast5Sessions() async {
    final db = await dbInstance.database;

    final maps = await db.query('sessions', orderBy: 'date DESC', limit: 5);

    return maps.map((e) {
      return Session(
        date: DateTime.parse(e['date'] as String),
        duration: Duration(minutes: e['duration'] as int),
        sampleCount: e['sampleCount'] as int,
      );
    }).toList();
  }

}