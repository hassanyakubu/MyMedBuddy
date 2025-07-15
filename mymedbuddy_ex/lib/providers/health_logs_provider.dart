import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_log.dart';
import '../services/shared_preferences_service.dart';

class HealthLogsNotifier extends StateNotifier<List<HealthLog>> {
  HealthLogsNotifier() : super([]) {
    loadHealthLogs();
  }

  Future<void> loadHealthLogs() async {
    try {
      final logs = await SharedPreferencesService.getHealthLogs();
      state = logs;
    } catch (e) {
      state = [];
    }
  }

  Future<void> addHealthLog(HealthLog log) async {
    try {
      final updatedLogs = [...state, log];
      await SharedPreferencesService.saveHealthLogs(updatedLogs);
      state = updatedLogs;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateHealthLog(HealthLog updatedLog) async {
    try {
      final updatedLogs = state.map((log) {
        return log.id == updatedLog.id ? updatedLog : log;
      }).toList();
      await SharedPreferencesService.saveHealthLogs(updatedLogs);
      state = updatedLogs;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteHealthLog(String id) async {
    try {
      final updatedLogs = state.where((log) => log.id != id).toList();
      await SharedPreferencesService.saveHealthLogs(updatedLogs);
      state = updatedLogs;
    } catch (e) {
      // Handle error
    }
  }

  List<HealthLog> getLogsByDateRange(DateTime startDate, DateTime endDate) {
    return state.where((log) {
      return log.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             log.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<HealthLog> getLogsByMood(String mood) {
    return state.where((log) => log.mood.toLowerCase().contains(mood.toLowerCase())).toList();
  }

  List<HealthLog> getRecentLogs(int count) {
    final sortedLogs = List<HealthLog>.from(state);
    sortedLogs.sort((a, b) => b.date.compareTo(a.date));
    return sortedLogs.take(count).toList();
  }
}

final healthLogsProvider = StateNotifierProvider<HealthLogsNotifier, List<HealthLog>>(
  (ref) => HealthLogsNotifier(),
);

// Filtered providers
final recentHealthLogsProvider = Provider<List<HealthLog>>((ref) {
  final notifier = ref.read(healthLogsProvider.notifier);
  return notifier.getRecentLogs(5);
});

final weeklyHealthLogsProvider = Provider<List<HealthLog>>((ref) {
  final notifier = ref.read(healthLogsProvider.notifier);
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));
  return notifier.getLogsByDateRange(weekStart, weekEnd);
}); 