//settings_screen.dart


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepsCtrl = TextEditingController();
  final _waterCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    final sp = await SharedPreferences.getInstance();
    _stepsCtrl.text = (sp.getInt('stepsGoal') ?? 8000).toString();
    _waterCtrl.text = (sp.getInt('waterGoal') ?? 2000).toString();
    _caloriesCtrl.text = (sp.getInt('caloriesGoal') ?? 2000).toString();
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('stepsGoal', int.parse(_stepsCtrl.text));
    await sp.setInt('waterGoal', int.parse(_waterCtrl.text));
    await sp.setInt('caloriesGoal', int.parse(_caloriesCtrl.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Goals saved")));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _stepsCtrl.dispose();
    _waterCtrl.dispose();
    _caloriesCtrl.dispose();
    super.dispose();
  }

  String? _validateNumber(String? v) {
    if (v == null || v.isEmpty) return 'Enter a valid number';
    if (int.tryParse(v) == null) return 'Enter a valid number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Settings")), body: Padding(padding: const EdgeInsets.all(12), child: Form(key: _formKey, child: ListView(children: [
      TextFormField(controller: _stepsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Daily steps goal"), validator: _validateNumber),
      const SizedBox(height: 12),
      TextFormField(controller: _waterCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Daily water goal (ml)"), validator: _validateNumber),
      const SizedBox(height: 12),
      TextFormField(controller: _caloriesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Daily calories goal (kcal)"), validator: _validateNumber),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: _save, child: const Text("Save")),
    ]))));
  }
}
