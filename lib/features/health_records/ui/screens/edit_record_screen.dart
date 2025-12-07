//edit_record_screen.dart


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:healthmate/features/health_records/models/health_record.dart';
import 'package:healthmate/features/health_records/provider/health_provider.dart';

class EditRecordScreen extends StatefulWidget {
  final HealthRecord record;
  const EditRecordScreen({required this.record, Key? key}) : super(key: key);

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;

  late final TextEditingController _stepsController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _waterController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.record.date);
    _stepsController = TextEditingController(text: widget.record.steps.toString());
    _caloriesController = TextEditingController(text: widget.record.calories.toString());
    _waterController = TextEditingController(text: widget.record.water.toString());
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String? _validateNumber(String? v, {int? min, int? max}) {
    if (v == null || v.isEmpty) return 'Enter a value';
    final n = int.tryParse(v);
    if (n == null) return 'Enter a valid integer';
    if (min != null && n < min) return 'Value must be >= $min';
    if (max != null && n > max) return 'Value must be <= $max';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = HealthRecord(id: widget.record.id, date: DateFormat('yyyy-MM-dd').format(_selectedDate), steps: int.parse(_stepsController.text), calories: int.parse(_caloriesController.text), water: int.parse(_waterController.text));
    final res = await Provider.of<HealthProvider>(context, listen: false).updateRecord(updated);
    if (!mounted) return;
    if (res > 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Record updated")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update failed")));
    }
  }

  Future<void> _delete() async {
    if (widget.record.id == null) return;
    final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete record?'), content: const Text('This action cannot be undone.'), actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
    ]));
    if (confirm != true) return;

    final res = await Provider.of<HealthProvider>(context, listen: false).deleteRecord(widget.record.id!);
    if (!mounted) return;
    if (res > 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Edit Record')), body: Padding(padding: const EdgeInsets.all(12), child: Form(key: _formKey, child: ListView(children: [
      ListTile(title: const Text('Date'), subtitle: Text(DateFormat.yMMMMd().format(_selectedDate)), trailing: IconButton(icon: const Icon(Icons.calendar_month), onPressed: _pickDate)),
      const SizedBox(height: 12),
      TextFormField(controller: _stepsController, decoration: const InputDecoration(labelText: 'Steps walked'), keyboardType: TextInputType.number, validator: (v) => _validateNumber(v, min: 0, max: 1000000)),
      const SizedBox(height: 12),
      TextFormField(controller: _caloriesController, decoration: const InputDecoration(labelText: 'Calories burned'), keyboardType: TextInputType.number, validator: (v) => _validateNumber(v, min: 0, max: 100000)),
      const SizedBox(height: 12),
      TextFormField(controller: _waterController, decoration: const InputDecoration(labelText: 'Water Intake (ml)'), keyboardType: TextInputType.number, validator: (v) => _validateNumber(v, min: 0, max: 1000000)),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: _save, child: const Text('Save'))),
        const SizedBox(width: 12),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(
            0xFFFFFFFF), shape: const StadiumBorder()), onPressed: _delete, child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text('Delete'))),
      ]),
    ]))));
  }
}
