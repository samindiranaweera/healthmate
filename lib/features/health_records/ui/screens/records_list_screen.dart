//records_list_screen.dart


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:healthmate/features/health_records/provider/health_provider.dart';
import 'package:healthmate/features/health_records/ui/widgets/record_tile.dart';
import 'package:healthmate/features/health_records/models/health_record.dart';
import 'package:healthmate/features/health_records/ui/screens/edit_record_screen.dart';

class RecordsListScreen extends StatefulWidget {
  const RecordsListScreen({Key? key}) : super(key: key);

  @override
  State<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends State<RecordsListScreen> {
  DateTime? _selectedDate;
  List<HealthRecord>? _filteredRecords;

  Future<void> _pickFilterDate() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) {
      setState(() => _selectedDate = picked);
      final iso = DateFormat('yyyy-MM-dd').format(picked);
      final results = await Provider.of<HealthProvider>(context, listen: false).searchByDate(iso);
      setState(() => _filteredRecords = results);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final records = _selectedDate == null ? provider.records : (_filteredRecords ?? []);

    return Scaffold(appBar: AppBar(title: const Text('All Records'), actions: [
      IconButton(icon: const Icon(Icons.calendar_month), onPressed: _pickFilterDate),
      IconButton(icon: const Icon(Icons.refresh), onPressed: () { setState(() { _selectedDate = null; _filteredRecords = null; }); provider.loadRecords(); }),
    ]), body: provider.loading ? const Center(child: CircularProgressIndicator()) : records.isEmpty ? const Center(child: Text("No records found")) : ListView.builder(itemCount: records.length, itemBuilder: (_, i) {
      final r = records[i];
      final dismissKey = ValueKey(r.id ?? '${r.date}_${r.steps}_${r.calories}_${r.water}');
      return Dismissible(
        key: dismissKey,
        direction: DismissDirection.endToStart,
        background: Container(color: Colors.white, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Text("Delete", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16))),
        confirmDismiss: (_) async {
          return await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text("Delete record?"), content: const Text("This action cannot be undone."), actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
          ]));
        },
        onDismissed: (_) async {
          final prov = Provider.of<HealthProvider>(context, listen: false);
          int res = 0;
          if (r.id != null) {
            res = await prov.deleteRecord(r.id!);
          } else {
            final candidates = await prov.searchByDate(r.date);
            HealthRecord? match;
            for (var c in candidates) {
              if (c.steps == r.steps && c.calories == r.calories && c.water == r.water) {
                match = c;
                break;
              }
            }
            if (match != null && match.id != null) {
              res = await prov.deleteRecord(match.id!);
            }
          }
          await prov.loadRecords();
          if (!mounted) return;
          if (res > 0) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Record deleted"))); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not delete record")));
        },
        child: GestureDetector(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditRecordScreen(record: r))), child: RecordTile(record: r)),
      );
    }), floatingActionButton: FloatingActionButton(onPressed: () => Navigator.pushNamed(context, '/add'), child: const Icon(Icons.add)));
  }
}
