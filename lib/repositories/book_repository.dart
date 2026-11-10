import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/book.dart';

class BookRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Book book) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('books', book.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);
    } catch (e) {
      throw Exception('Не вдалося додати книгу: $e');
    }
  }

  Future<List<Book>> getAll({bool newestFirst = true}) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'books',
        orderBy: 'addedDate ${newestFirst ? 'DESC' : 'ASC'}',
      );
      return maps.map(Book.fromMap).toList();
    } catch (e) {
      throw Exception('Не вдалося отримати книги: $e');
    }
  }

  Future<List<Book>> searchByAuthor(String author) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'books',
        where: 'author LIKE ?',
        whereArgs: ['%$author%'],
        orderBy: 'addedDate DESC',
      );
      return maps.map(Book.fromMap).toList();
    } catch (e) {
      throw Exception('Помилка пошуку: $e');
    }
  }

  Future<List<Book>> filterByReadStatus(bool? isRead) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'books',
        where: isRead == null ? null : 'isRead = ?',
        whereArgs: isRead == null ? null : [isRead ? 1 : 0],
        orderBy: 'addedDate DESC',
      );
      return maps.map(Book.fromMap).toList();
    } catch (e) {
      throw Exception('Помилка фільтрації: $e');
    }
  }

  Future<int> updateReadStatus(int id, bool isRead) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'books',
        {'isRead': isRead ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Не вдалося оновити статус книги: $e');
    }
  }

  Future<int> delete(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete('books', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Не вдалося видалити книгу: $e');
    }
  }

  Future<Map<String, int>> getStatistics() async {
    try {
      final db = await _dbHelper.database;
      final total = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM books'),
          ) ??
          0;
      final read = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM books WHERE isRead = 1'),
          ) ??
          0;
      return {'total': total, 'read': read};
    } catch (e) {
      throw Exception('Не вдалося отримати статистику: $e');
    }
  }
}
