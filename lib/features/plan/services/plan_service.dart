import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/training_plan.dart';
import '../../../core/services/firebase_sync.dart';

class PlanService {
  static const _legacyConfigKey = 'plan_config_v1';
  static const _legacyCompletedKey = 'completed_days_v1';

  final _sync = FirebaseSyncService.instance;

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Training plan requires an authenticated user.');
    }
    return uid;
  }

  String _configKey(String uid) => 'plan_config_v2_$uid';
  String _completedKey(String uid) => 'completed_days_v2_$uid';

  Future<void> _discardLegacyCache(SharedPreferences prefs) async {
    await prefs.remove(_legacyConfigKey);
    await prefs.remove(_legacyCompletedKey);
  }

  // ── Config ──────────────────────────────────────────────────────────────

  Future<WeeklyPlanConfig?> loadConfig() async {
    final uid = _requireUid();
    final prefs = await SharedPreferences.getInstance();
    await _discardLegacyCache(prefs);
    final key = _configKey(uid);
    final raw = prefs.getString(key);

    if (raw != null) {
      try {
        // Local data available — use it, then refresh from Firebase in background
        final local = WeeklyPlanConfig.fromJson(json.decode(raw));
        _refreshConfigFromFirebase(prefs, uid);
        return local;
      } catch (_) {}
    }

    // No local data — try Firebase (first install / new device)
    final remote = await _sync.fetchConfig(uid);
    if (remote != null) {
      await prefs.setString(key, json.encode(remote.toJson()));
    }
    return remote;
  }

  Future<void> saveConfig(WeeklyPlanConfig config) async {
    final uid = _requireUid();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey(uid), json.encode(config.toJson()));
    _sync.syncConfig(uid, config); // fire-and-forget
  }

  // Fetch remote config silently; update local cache if it differs
  Future<void> _refreshConfigFromFirebase(
      SharedPreferences prefs, String uid) async {
    final remote = await _sync.fetchConfig(uid);
    if (remote == null) return;
    if (FirebaseAuth.instance.currentUser?.uid != uid) return;
    await prefs.setString(_configKey(uid), json.encode(remote.toJson()));
  }

  // ── Completed days ───────────────────────────────────────────────────────

  Future<Map<String, CompletedDay>> loadCompleted() async {
    final uid = _requireUid();
    final prefs = await SharedPreferences.getInstance();
    await _discardLegacyCache(prefs);
    final raw = prefs.getString(_completedKey(uid));

    if (raw != null) {
      try {
        final local = _parseCompleted(json.decode(raw) as List);
        _refreshCompletedFromFirebase(prefs, uid, local);
        return local;
      } catch (_) {}
    }

    // No local data — try Firebase
    final remote = await _sync.fetchCompleted(uid);
    if (remote.isNotEmpty) {
      await _cacheCompleted(prefs, uid, remote);
    }
    return remote;
  }

  Future<void> toggleCompleted(DateTime date, PlanActivity activity,
      bool completed, Map<String, CompletedDay> current) async {
    final uid = _requireUid();
    final key = CompletedDay.keyFor(date);
    if (completed) {
      current[key] = CompletedDay(date: date, activity: activity);
      _sync.setCompletedDay(uid, date, activity); // fire-and-forget
    } else {
      current.remove(key);
      _sync.deleteCompletedDay(uid, date); // fire-and-forget
    }
    final prefs = await SharedPreferences.getInstance();
    await _cacheCompleted(prefs, uid, current);
  }

  // Merge remote completed days into local (union — any device's completions win)
  Future<void> _refreshCompletedFromFirebase(SharedPreferences prefs,
      String uid, Map<String, CompletedDay> local) async {
    final remote = await _sync.fetchCompleted(uid);
    if (remote.isEmpty) return;
    if (FirebaseAuth.instance.currentUser?.uid != uid) return;
    final merged = {...local, ...remote};
    if (merged.length != local.length) {
      await _cacheCompleted(prefs, uid, merged);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Map<String, CompletedDay> _parseCompleted(List list) => {
        for (final item in list)
          CompletedDay.keyFor(DateTime.parse((item as Map)['date'] as String)):
              CompletedDay.fromJson(Map<String, dynamic>.from(item))
      };

  Future<void> _cacheCompleted(SharedPreferences prefs, String uid,
      Map<String, CompletedDay> data) async {
    await prefs.setString(_completedKey(uid),
        json.encode(data.values.map((c) => c.toJson()).toList()));
  }
}
