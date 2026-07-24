import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/training_plan.dart';
import '../../../core/services/firebase_sync.dart';

class PlanService {
  static const _configKey    = 'plan_config_v1';
  static const _completedKey = 'completed_days_v1';

  final _sync = FirebaseSyncService.instance;

  // ── Config ──────────────────────────────────────────────────────────────

  Future<WeeklyPlanConfig?> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_configKey);

    if (raw != null) {
      try {
        // Local data available — use it, then refresh from Firebase in background
        final local = WeeklyPlanConfig.fromJson(json.decode(raw));
        _refreshConfigFromFirebase(prefs);
        return local;
      } catch (_) {}
    }

    // No local data — try Firebase (first install / new device)
    final remote = await _sync.fetchConfig();
    if (remote != null) {
      await prefs.setString(_configKey, json.encode(remote.toJson()));
    }
    return remote;
  }

  Future<void> saveConfig(WeeklyPlanConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, json.encode(config.toJson()));
    _sync.syncConfig(config); // fire-and-forget
  }

  // Fetch remote config silently; update local cache if it differs
  Future<void> _refreshConfigFromFirebase(SharedPreferences prefs) async {
    final remote = await _sync.fetchConfig();
    if (remote == null) return;
    await prefs.setString(_configKey, json.encode(remote.toJson()));
  }

  // ── Completed days ───────────────────────────────────────────────────────

  Future<Map<String, CompletedDay>> loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_completedKey);

    if (raw != null) {
      try {
        final local = _parseCompleted(json.decode(raw) as List);
        _refreshCompletedFromFirebase(prefs, local);
        return local;
      } catch (_) {}
    }

    // No local data — try Firebase
    final remote = await _sync.fetchCompleted();
    if (remote.isNotEmpty) {
      await _cacheCompleted(prefs, remote);
    }
    return remote;
  }

  Future<void> toggleCompleted(
      DateTime date, PlanActivity activity, bool completed,
      Map<String, CompletedDay> current) async {
    final key = CompletedDay.keyFor(date);
    if (completed) {
      current[key] = CompletedDay(date: date, activity: activity);
      _sync.setCompletedDay(date, activity); // fire-and-forget
    } else {
      current.remove(key);
      _sync.deleteCompletedDay(date); // fire-and-forget
    }
    final prefs = await SharedPreferences.getInstance();
    await _cacheCompleted(prefs, current);
  }

  // Merge remote completed days into local (union — any device's completions win)
  Future<void> _refreshCompletedFromFirebase(
      SharedPreferences prefs, Map<String, CompletedDay> local) async {
    final remote = await _sync.fetchCompleted();
    if (remote.isEmpty) return;
    final merged = {...local, ...remote};
    if (merged.length != local.length) {
      await _cacheCompleted(prefs, merged);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Map<String, CompletedDay> _parseCompleted(List list) => {
        for (final item in list)
          CompletedDay.keyFor(
                  DateTime.parse((item as Map)['date'] as String)):
              CompletedDay.fromJson(Map<String, dynamic>.from(item))
      };

  Future<void> _cacheCompleted(
      SharedPreferences prefs, Map<String, CompletedDay> data) async {
    await prefs.setString(
        _completedKey,
        json.encode(data.values.map((c) => c.toJson()).toList()));
  }
}
