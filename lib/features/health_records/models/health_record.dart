//health_record.dart


class HealthRecord {
  int? id;
  String date; //yyyy-MM-dd
  int steps;
  int calories;
  int water;

  HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'date': date,
      'steps': steps,
      'calories': calories,
      'water': water,
    };
    if (id != null) m['id'] = id;
    return m;
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] is int ? map['id'] as int : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
      date: map['date'] as String,
      steps: (map['steps'] as num).toInt(),
      calories: (map['calories'] as num).toInt(),
      water: (map['water'] as num).toInt(),
    );
  }
}
