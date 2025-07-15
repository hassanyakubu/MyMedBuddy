class User {
  final String name;
  final int age;
  final List<String> conditions;
  final bool medicationReminders;
  final bool darkMode;
  final bool notifications;
  final bool dailyLogReminders;

  User({
    required this.name,
    required this.age,
    required this.conditions,
    required this.medicationReminders,
    this.darkMode = false,
    this.notifications = true,
    this.dailyLogReminders = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'conditions': conditions,
      'medicationReminders': medicationReminders,
      'darkMode': darkMode,
      'notifications': notifications,
      'dailyLogReminders': dailyLogReminders,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      conditions: List<String>.from(json['conditions'] ?? []),
      medicationReminders: json['medicationReminders'] ?? false,
      darkMode: json['darkMode'] ?? false,
      notifications: json['notifications'] ?? true,
      dailyLogReminders: json['dailyLogReminders'] ?? true,
    );
  }
}