//db_helper.dart


import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:healthmate/features/health_records/models/health_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

// sqflite imports
import 'package:sqflite/sqflite.dart' show openDatabase, Database, inMemoryDatabasePath;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show sqfliteFfiInit, databaseFactoryFfi, databaseFactory;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;
  static const String _webKey = 'healthmate_records_json';
  final String tableName = 'health_records';

  Future<void> init() async {
    if (kIsWeb) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    if (_db != null) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'healthmate.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        water INTEGER NOT NULL
      )
    ''');

    final today = DateTime.now().toIso8601String().split('T').first;
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T').first;

    await db.insert(tableName, {'date': today, 'steps': 5600, 'calories': 220, 'water': 1500});
    await db.insert(tableName, {'date': yesterday, 'steps': 7300, 'calories': 300, 'water': 1800});
  }

  Future<Database> _getDb() async {
    if (_db != null) return _db!;
    await init();
    if (_db == null) {
      _db = await openDatabase(inMemoryDatabasePath, version: 1, onCreate: _onCreate);
    }
    return _db!;
  }

  Future<List<HealthRecord>> getAllRecords() async {
    if (kIsWeb) return _getAllWeb();
    final db = await _getDb();
    final maps = await db.query(tableName, orderBy: 'date DESC');
    return maps.map((m) => HealthRecord.fromMap(m)).toList();
  }

  Future<int> insertRecord(HealthRecord record) async {
    if (kIsWeb) return _insertWeb(record);
    final db = await _getDb();
    return await db.insert(tableName, record.toMap());
  }

  Future<List<HealthRecord>> getRecordsByDate(String dateIso) async {
    if (kIsWeb) {
      final all = await _getAllWeb();
      return all.where((r) => r.date == dateIso).toList();
    }
    final db = await _getDb();
    final maps = await db.query(tableName, where: 'date = ?', whereArgs: [dateIso], orderBy: 'date DESC');
    return maps.map((m) => HealthRecord.fromMap(m)).toList();
  }

  Future<int> updateRecord(HealthRecord record) async {
    if (kIsWeb) return _updateWeb(record);
    final db = await _getDb();
    return await db.update(tableName, record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<int> deleteRecord(int id) async {
    if (kIsWeb) return _deleteWeb(id);
    final db = await _getDb();
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }


  Future<List<HealthRecord>> _getAllWeb() async {
    final sp = await SharedPreferences.getInstance();
    final jsonStr = sp.getString(_webKey);
    if (jsonStr == null) {
      final today = DateTime.now().toIso8601String().split('T').first;
      final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T').first;
      final initial = [
        HealthRecord(date: today, steps: 5600, calories: 220, water: 1500).toMap(),
        HealthRecord(date: yesterday, steps: 7300, calories: 300, water: 1800).toMap(),
      ];
      await sp.setString(_webKey, json.encode(initial));
      return initial.map((m) => HealthRecord.fromMap(Map<String, dynamic>.from(m))).toList();
    }
    final List<dynamic> decoded = json.decode(jsonStr);
    final list = decoded.map((e) => HealthRecord.fromMap(Map<String, dynamic>.from(e))).toList();
    for (var i = 0; i < list.length; i++) {
      if (list[i].id == null) list[i].id = i + 1;
    }
    return list;
  }

  Future<int> _insertWeb(HealthRecord record) async {
    final sp = await SharedPreferences.getInstance();
    final current = await _getAllWeb();
    final nextId = (current.isEmpty) ? 1 : ((current.map((r) => r.id ?? 0).reduce((a, b) => a > b ? a : b)) + 1);
    record.id = nextId;
    current.insert(0, record);
    await sp.setString(_webKey, json.encode(current.map((r) => r.toMap()).toList()));
    return record.id ?? 0;
  }

  Future<int> _updateWeb(HealthRecord record) async {
    if (record.id == null) return 0;
    final sp = await SharedPreferences.getInstance();
    final current = await _getAllWeb();
    final idx = current.indexWhere((r) => r.id == record.id);
    if (idx == -1) return 0;
    current[idx] = record;
    await sp.setString(_webKey, json.encode(current.map((r) => r.toMap()).toList()));
    return 1;
  }

  Future<int> _deleteWeb(int id) async {
    final sp = await SharedPreferences.getInstance();
    final current = await _getAllWeb();
    final before = current.length;
    current.removeWhere((r) => r.id == id);
    await sp.setString(_webKey, json.encode(current.map((r) => r.toMap()).toList()));
    return (current.length < before) ? 1 : 0;
  }
}
