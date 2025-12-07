//add_record_screen.dart


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:healthmate/features/health_records/models/health_record.dart';
import 'package:healthmate/features/health_records/provider/health_provider.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({Key? key}) : super(key: key);

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();

  final _stepsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _waterController = TextEditingController();

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
    if (n == null) return 'Enter a valid value';
    if (min != null && n < min) return 'Value must be >= $min';
    if (max != null && n > max) return 'Value must be <= $max';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final record = HealthRecord(date: DateFormat('yyyy-MM-dd').format(_selectedDate), steps: int.parse(_stepsController.text), calories: int.parse(_caloriesController.text), water: int.parse(_waterController.text));
    final id = await Provider.of<HealthProvider>(context, listen: false).addRecord(record);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Record saved successfully. ID: $id')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Add Record')), body: Padding(padding: const EdgeInsets.all(12), child: Form(key: _formKey, child: ListView(children: [
      ListTile(title: const Text('Select Date'), subtitle: Text(DateFormat.yMMMMd().format(_selectedDate)), trailing: IconButton(icon: const Icon(Icons.calendar_month), onPressed: _pickDate)),
      const SizedBox(height: 12),
      TextFormField(controller: _stepsController, decoration: const InputDecoration(labelText: 'Steps walked'), keyboardType: TextInputType.number, validator: (v) => _validateNumber(v, min: 0, max: 1000000)),
      const SizedBox(height: 12),
      TextFormField(controller: _caloriesController, decoration: const InputDecoration(labelText: 'Calories burned'), keyboardType: TextInputType.number, validator: (v) => _validateNumber(v, min: 0, max: 100000)),
      const SizedBox(height: 12),
      TextFormField(controller: _waterController, decoration: const InputDecoration(labelText: 'Water intake (ml)'), keyboardType: TextInputType.number, validator: (v) => _validateNumber(v, min: 0, max: 1000000)),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: _save, child: const Text("Save")),
    ]))));
  }
}
