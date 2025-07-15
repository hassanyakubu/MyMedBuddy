import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/medication.dart';
import '../models/health_log.dart';
import '../models/appointment.dart';

class SharedPreferencesService {
  static const String _userKey = 'user_data';
  static const String _medicationsKey = 'medications';
  static const String _healthLogsKey = 'health_logs';
  static const String _appointmentsKey = 'appointments';
  static const String _isOnboardedKey = 'is_onboarded';

  // User data methods
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Onboarding status
  static Future<void> setOnboarded(bool isOnboarded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isOnboardedKey, isOnboarded);
  }

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isOnboardedKey) ?? false;
  }

  // Medication methods
  static Future<void> saveMedications(List<Medication> medications) async {
    final prefs = await SharedPreferences.getInstance();
    final medicationsJson = medications.map((m) => m.toJson()).toList();
    await prefs.setString(_medicationsKey, jsonEncode(medicationsJson));
  }

  static Future<List<Medication>> getMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final medicationsData = prefs.getString(_medicationsKey);
    if (medicationsData != null) {
      final List<dynamic> medicationsJson = jsonDecode(medicationsData);
      return medicationsJson.map((json) => Medication.fromJson(json)).toList();
    }
    return [];
  }

  // Health logs methods
  static Future<void> saveHealthLogs(List<HealthLog> healthLogs) async {
    final prefs = await SharedPreferences.getInstance();
    final healthLogsJson = healthLogs.map((h) => h.toJson()).toList();
    await prefs.setString(_healthLogsKey, jsonEncode(healthLogsJson));
  }

  static Future<List<HealthLog>> getHealthLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final healthLogsData = prefs.getString(_healthLogsKey);
    if (healthLogsData != null) {
      final List<dynamic> healthLogsJson = jsonDecode(healthLogsData);
      return healthLogsJson.map((json) => HealthLog.fromJson(json)).toList();
    }
    return [];
  }

  // Appointments methods
  static Future<void> saveAppointments(List<Appointment> appointments) async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson = appointments.map((a) => a.toJson()).toList();
    await prefs.setString(_appointmentsKey, jsonEncode(appointmentsJson));
  }

  static Future<List<Appointment>> getAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsData = prefs.getString(_appointmentsKey);
    if (appointmentsData != null) {
      final List<dynamic> appointmentsJson = jsonDecode(appointmentsData);
      return appointmentsJson.map((json) => Appointment.fromJson(json)).toList();
    }
    return [];
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 