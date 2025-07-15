import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/shared_preferences_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // Load user from SharedPreferences
  Future<void> loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await SharedPreferencesService.getUser();
    } catch (e) {
      _error = 'Failed to load user data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save user to SharedPreferences
  Future<void> saveUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SharedPreferencesService.saveUser(user);
      _user = user;
    } catch (e) {
      _error = 'Failed to save user data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences({
    bool? darkMode,
    bool? notifications,
    bool? dailyLogReminders,
    bool? medicationReminders,
  }) async {
    if (_user == null) return;

    final updatedUser = User(
      name: _user!.name,
      age: _user!.age,
      conditions: _user!.conditions,
      medicationReminders: medicationReminders ?? _user!.medicationReminders,
      darkMode: darkMode ?? _user!.darkMode,
      notifications: notifications ?? _user!.notifications,
      dailyLogReminders: dailyLogReminders ?? _user!.dailyLogReminders,
    );

    await saveUser(updatedUser);
  }

  // Clear user data
  Future<void> clearUser() async {
    _user = null;
    _error = null;
    notifyListeners();
  }
} 