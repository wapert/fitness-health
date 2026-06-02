import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/training_plan.dart';

class PlanService {
  static const _configKey    = 'plan_config_v1';
  static const _completedKey = 'completed_days_v1';

  // ── Config ──────────────────────────────────────────────────────────────

  Future<WeeklyPlanConfig?> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_configKey);
    if (raw == null) return null;
    try {
      return WeeklyPlanConfig.fromJson(json.decode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveConfig(WeeklyPlanConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, json.encode(config.toJson()));
  }

  // ── Completed days ───────────────────────────────────────────────────────

  Future<Map<String, CompletedDay>> loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_completedKey);
    if (raw == null) return {};
    try {
      final list = json.decode(raw) as List;
      return {
        for (final item in list)
          CompletedDay.keyFor(
                  DateTime.parse((item as Map)['date'] as String)):
              CompletedDay.fromJson(Map<String, dynamic>.from(item))
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> toggleCompleted(
      DateTime date, PlanActivity activity, bool completed,
      Map<String, CompletedDay> current) async {
    final key = CompletedDay.keyFor(date);
    if (completed) {
      current[key] = CompletedDay(date: date, activity: activity);
    } else {
      current.remove(key);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _completedKey, json.encode(current.values.map((c) => c.toJson()).toList()));
  }
}
