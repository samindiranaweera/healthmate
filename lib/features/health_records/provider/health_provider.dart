//health_provider.dart


import 'package:flutter/material.dart';
import 'package:healthmate/features/health_records/models/health_record.dart';
import 'package:healthmate/features/health_records/data/db_helper.dart';

class HealthProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<HealthRecord> _records = [];
  List<HealthRecord> get records => _records;

  bool _loading = true;
  bool get loading => _loading;

  HealthProvider() {
    loadRecords();
  }


  Future<void> initForAppStart() async {
    await _db.init();
  }

  Future<void> loadRecords() async {
    _loading = true;
    notifyListeners();
    await _db.init();
    _records = await _db.getAllRecords();
    _loading = false;
    notifyListeners();
  }

  Future<int> addRecord(HealthRecord r) async {
    final id = await _db.insertRecord(r);
    await loadRecords();
    return id;
  }

  Future<int> updateRecord(HealthRecord r) async {
    final res = await _db.updateRecord(r);
    await loadRecords();
    return res;
  }

  Future<int> deleteRecord(int id) async {
    final res = await _db.deleteRecord(id);
    await loadRecords();
    return res;
  }

  Future<List<HealthRecord>> searchByDate(String date) async {
    return await _db.getRecordsByDate(date);
  }
}
