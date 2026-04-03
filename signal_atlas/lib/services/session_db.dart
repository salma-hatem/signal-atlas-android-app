import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// this class is responsible for creating and initialize it a static instance of the database

class SessionDB {
  static final SessionDB instance = SessionDB._init();
  static Database? _database;

  SessionDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sessions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        duration INTEGER NOT NULL,
        sampleCount INTEGER NOT NULL
      )
    ''');
  }
}