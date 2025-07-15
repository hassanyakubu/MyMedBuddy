class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String location;
  final String notes;
  bool isConfirmed;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.location,
    this.notes = '',
    this.isConfirmed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'specialty': specialty,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'notes': notes,
      'isConfirmed': isConfirmed,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      doctorName: json['doctorName'] ?? '',
      specialty: json['specialty'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
      location: json['location'] ?? '',
      notes: json['notes'] ?? '',
      isConfirmed: json['isConfirmed'] ?? false,
    );
  }
} 