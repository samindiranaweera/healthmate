//dashboard_screen.dart


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthmate/features/health_records/provider/health_provider.dart';
import 'package:healthmate/features/health_records/ui/widgets/record_tile.dart';
import 'package:healthmate/utils/constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  Future<Map<String,int>> _loadGoals() async {
    final sp = await SharedPreferences.getInstance();
    return {
      'stepsGoal': sp.getInt('stepsGoal') ?? 8000,
      'waterGoal': sp.getInt('waterGoal') ?? 2000,
      'caloriesGoal': sp.getInt('caloriesGoal') ?? 2000,
    };
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<HealthProvider>(context);
    final todayIso = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todays = prov.records.where((r) => r.date == todayIso).toList();

    final int totalSteps = todays.fold(0, (p, e) => p + e.steps);
    final int totalCalories = todays.fold(0, (p, e) => p + e.calories);
    final int totalWater = todays.fold(0, (p, e) => p + e.water);

    final Color filledColor = AppColors.primary;
    final Color remainingColor = const Color(0xFFDCFCE7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthMate'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(icon: const Icon(Icons.list), onPressed: () => Navigator.pushNamed(context, '/list')),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Today • ${DateFormat.yMMMEd().format(DateTime.now())}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                _SmallStatCard(title: 'Steps', value: totalSteps.toString(), icon: Icons.directions_walk, color: AppColors.steps),
                const SizedBox(width: 8),
                _SmallStatCard(title: 'Calories', value: totalCalories.toString(), icon: Icons.local_fire_department, color: AppColors.calories),
                const SizedBox(width: 8),
                _SmallStatCard(title: 'Water (ml)', value: totalWater.toString(), icon: Icons.water_drop, color: AppColors.water),
              ],
            ),
            FutureBuilder<Map<String,int>>(
              future: _loadGoals(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox(height: 12);
                final goals = snap.data!;
                final stepsGoal = goals['stepsGoal']!;
                final waterGoal = goals['waterGoal']!;
                final caloriesGoal = goals['caloriesGoal']!;
                final stepsPct = (stepsGoal == 0) ? 0.0 : (totalSteps / stepsGoal).clamp(0.0,1.0);
                final waterPct = (waterGoal == 0) ? 0.0 : (totalWater / waterGoal).clamp(0.0,1.0);
                final caloriesPct = (caloriesGoal == 0) ? 0.0 : (totalCalories / caloriesGoal).clamp(0.0,1.0);

                Widget progressRow(String label, int current, int goal, double pct) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text('$label $current/$goal', style: const TextStyle(fontWeight: FontWeight.w600))),
                        Text('${(pct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final filledWidth = width * pct;
                            return Stack(
                              children: [
                                Container(width: width, height: 10, color: remainingColor),
                                AnimatedContainer(duration: const Duration(milliseconds: 400), width: filledWidth, height: 10, color: filledColor),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }

                return Column(children: [
                  progressRow('Steps progress', totalSteps, stepsGoal, stepsPct),
                  progressRow('Water progress', totalWater, waterGoal, waterPct),
                  progressRow('Calories progress', totalCalories, caloriesGoal, caloriesPct),
                ]);
              },
            ),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Recent records', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Add'), onPressed: () => Navigator.pushNamed(context, '/add')),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: prov.records.isEmpty ? const Center(child: Text('No records yet. Tap Add to create one.')) : ListView.builder(
                itemCount: prov.records.length > 6 ? 6 : prov.records.length,
                itemBuilder: (_, i) => RecordTile(record: prov.records[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _SmallStatCard({required this.title, required this.value, required this.icon, required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Card(elevation: 2, child: Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), child: Column(children: [
      Row(children: [Icon(icon, color: color), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
    ]))));
  }
}
