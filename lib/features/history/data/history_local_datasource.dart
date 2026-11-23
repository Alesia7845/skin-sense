import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:skinsense/features/history/domain/entities/history_record.dart';
import 'package:sqflite/sqflite.dart';

class HistoryLocalDataSource {
  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'skinsense.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE history ('
        'id TEXT PRIMARY KEY, '
        'created_at INTEGER NOT NULL, '
        'payload TEXT NOT NULL)',
      ),
    );
    return _db!;
  }

  Future<void> insert(HistoryRecord record) async {
    final db = await _database;
    await db.insert(
      'history',
      {
        'id': record.id,
        'created_at': record.createdAt.millisecondsSinceEpoch,
        'payload': jsonEncode(record.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HistoryRecord>> getAll() async {
    final db = await _database;
    final rows = await db.query('history', orderBy: 'created_at DESC');
    final result = <HistoryRecord>[];
    for (final row in rows) {
      try {
        result.add(HistoryRecord.fromJson(
            jsonDecode(row['payload'] as String) as Map<String, dynamic>));
      } catch (_) {
        // entri rusak dilewati
      }
    }
    return result;
  }

  Future<void> delete(String id) async {
    final db = await _database;
    await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _database;
    await db.delete('history');
  }
}
