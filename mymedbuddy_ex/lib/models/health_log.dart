class HealthLog {
  final String id;
  final DateTime date;
  final String symptoms;
  final String mood;
  final String notes;
  final double weight;
  final int bloodPressureSystolic;
  final int bloodPressureDiastolic;
  final int heartRate;

  HealthLog({
    required this.id,
    required this.date,
    this.symptoms = '',
    this.mood = '',
    this.notes = '',
    this.weight = 0.0,
    this.bloodPressureSystolic = 0,
    this.bloodPressureDiastolic = 0,
    this.heartRate = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'symptoms': symptoms,
      'mood': mood,
      'notes': notes,
      'weight': weight,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'heartRate': heartRate,
    };
  }

  factory HealthLog.fromJson(Map<String, dynamic> json) {
    return HealthLog(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      symptoms: json['symptoms'] ?? '',
      mood: json['mood'] ?? '',
      notes: json['notes'] ?? '',
      weight: json['weight']?.toDouble() ?? 0.0,
      bloodPressureSystolic: json['bloodPressureSystolic'] ?? 0,
      bloodPressureDiastolic: json['bloodPressureDiastolic'] ?? 0,
      heartRate: json['heartRate'] ?? 0,
    );
  }
} 