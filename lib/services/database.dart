import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/tutorial.dart';

class DatabaseService {
  static DatabaseService? _instance;
  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  DatabaseService._internal();

  static const String _name = 'database.db';
  static const int _version = 1;

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _name);
    return await openDatabase(path, version: _version, onCreate: _onCreate);
  }

  _onCreate(Database db, int intVersion) async {
    await db.execute('CREATE TABLE IF NOT EXISTS Tutorials ('
        ' id INTEGER PRIMARY KEY AUTOINCREMENT, '
        ' title TEXT NOT NULL, '
        ' description TEXT'
        ')');
  }

  Future<List<TutorialModel>> getAllTutorial() async {
    final db = await database;
    final result = await db.query('Tutorials', orderBy: 'id ASC');
    return result.map((json) => TutorialModel.fromJson(json)).toList();
  }

  Future<TutorialModel> readTutorial(int id) async {
    final db = await database;
    final result =
        await db.query('Tutorials', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return TutorialModel.fromJson(result.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<void> insertTutorial(TutorialModel val) async {
    final db = await database;
    await db.insert('Tutorials', val.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateTutorial(TutorialModel val) async {
    final db = await database;
    return await db.update('Tutorials', val.toJson(),
        where: 'id = ?', whereArgs: [val.id]);
  }

  Future<void> deleteTutorial(int id) async {
    final db = await database;
    try {
      await db.delete('Tutorials', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Something went wrong when deleting an item: $e');
    }
  }

  Future close() async {
    final db = await database;
    _database = null;
    return db.close();
  }
}
