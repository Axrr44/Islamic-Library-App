import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/tafseer_content.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'tafseer.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tafseerContent(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            surahId INTEGER,
            verseId INTEGER,
            verseText TEXT,
            tafseerText TEXT,
            surahText TEXT,
            tafseerId INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertTafseerContent(TafseerContent content) async {
    final db = await database;
    await db.insert('tafseerContent', content.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TafseerContent>> getTafseerContents(int surahId, int tafseerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tafseerContent',
      where: 'surahId = ? AND tafseerId = ?',
      whereArgs: [surahId, tafseerId],
    );

    return List.generate(maps.length, (i) {
      return TafseerContent(
        tafseerId: tafseerId,
        surahId: maps[i]['surahId'],
        verseId: maps[i]['verseId'],
        verseText: maps[i]['verseText'],
        tafseerText: maps[i]['tafseerText'],
        surahText: maps[i]['surahText'],
      );
    });
  }
}