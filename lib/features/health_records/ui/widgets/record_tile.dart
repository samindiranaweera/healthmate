//record_tile.dart


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:healthmate/features/health_records/models/health_record.dart';
import 'package:healthmate/utils/constants.dart';

class RecordTile extends StatelessWidget {
  final HealthRecord record;
  const RecordTile({required this.record, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMd().format(DateTime.parse(record.date));
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withAlpha((0.12 * 255).round()),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    record.steps.toString(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  const Text('steps', style: TextStyle(fontSize: 9, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(dateLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.local_fire_department, size: 16, color: AppColors.calories),
                  const SizedBox(width: 6),
                  Text('${record.calories} kcal'),
                  const SizedBox(width: 12),
                  Icon(Icons.water_drop, size: 16, color: AppColors.water),
                  const SizedBox(width: 6),
                  Text('${record.water} ml'),
                ])
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
