import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._init();

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'library.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async => createDB(db, version),
      );
    } catch (e) {
      throw Exception('Не вдалося ініціалізувати базу даних: $e');
    }
  }

  Future<void> createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        pages INTEGER NOT NULL,
        genre TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        addedDate TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_author ON books(author)',
    );
  }
}
