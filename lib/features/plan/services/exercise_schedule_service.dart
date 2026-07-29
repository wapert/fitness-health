import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/firebase_sync.dart';

/// Persists which exercises are scheduled on which weekday (1=Mon … 7=Sun).
/// Local-first (SharedPreferences) with background Firebase sync.
class ExerciseScheduleService {
  static const _legacyKey = 'exercise_schedule_v1';
  static const _legacyCompletedKey = 'completed_exercises_v1';
  final _sync = FirebaseSyncService.instance;

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Exercise schedule requires an authenticated user.');
    }
    return uid;
  }

  String _key(String uid) => 'exercise_schedule_v2_$uid';
  String _completedKey(String uid) => 'completed_exercises_v2_$uid';

  Future<void> _discardLegacyCache(SharedPreferences prefs) async {
    await prefs.remove(_legacyKey);
    await prefs.remove(_legacyCompletedKey);
  }

  Future<Map<int, List<String>>> load() async {
    final uid = _requireUid();
    final prefs = await SharedPreferences.getInstance();
    await _discardLegacyCache(prefs);
    final raw = prefs.getString(_key(uid));

    if (raw != null) {
      try {
        final local = _decode(json.decode(raw) as Map<String, dynamic>);
        _refreshFromFirebase(prefs, uid); // background
        return local;
      } catch (_) {}
    }

    final remote = await _sync.fetchExerciseSchedule(uid);
    if (remote.isNotEmpty) {
      await prefs.setString(_key(uid), json.encode(_encode(remote)));
    }
    return remote;
  }

  Future<void> save(Map<int, List<String>> schedule) async {
    final uid = _requireUid();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(uid), json.encode(_encode(schedule)));
    _sync.syncExerciseSchedule(uid, schedule); // fire-and-forget
  }

  /// Toggle an exercise on/off for a weekday, persist, and return the new map.
  Future<Map<int, List<String>>> toggle(
      Map<int, List<String>> current, int weekday, String exerciseId) async {
    final next = {
      for (final e in current.entries) e.key: List<String>.from(e.value),
    };
    final list = next.putIfAbsent(weekday, () => <String>[]);
    if (list.contains(exerciseId)) {
      list.remove(exerciseId);
      if (list.isEmpty) next.remove(weekday);
    } else {
      list.add(exerciseId);
    }
    await save(next);
    return next;
  }

  Future<void> _refreshFromFirebase(SharedPreferences prefs, String uid) async {
    final remote = await _sync.fetchExerciseSchedule(uid);
    if (remote.isEmpty) return;
    if (FirebaseAuth.instance.currentUser?.uid != uid) return;
    await prefs.setString(_key(uid), json.encode(_encode(remote)));
  }

  // ── Completed exercises (dateKey → set of exerciseIds) ─────────────────────

  Future<Map<String, Set<String>>> loadCompletedExercises() async {
    final uid = _requireUid();
    final prefs = await SharedPreferences.getInstance();
    await _discardLegacyCache(prefs);
    final raw = prefs.getString(_completedKey(uid));

    if (raw != null) {
      try {
        final local =
            _decodeCompleted(json.decode(raw) as Map<String, dynamic>);
        _refreshCompletedFromFirebase(prefs, uid); // background
        return local;
      } catch (_) {}
    }

    final remote = await _sync.fetchCompletedExercises(uid);
    if (remote.isNotEmpty) {
      await prefs.setString(
          _completedKey(uid), json.encode(_encodeCompleted(remote)));
    }
    return remote;
  }

  /// Toggle a single exercise done/undone for a given date key.
  Future<Map<String, Set<String>>> toggleExerciseDone(
      Map<String, Set<String>> current,
      String dateKey,
      String exerciseId) async {
    final uid = _requireUid();
    final next = {
      for (final e in current.entries) e.key: Set<String>.from(e.value),
    };
    final set = next.putIfAbsent(dateKey, () => <String>{});
    if (set.contains(exerciseId)) {
      set.remove(exerciseId);
      if (set.isEmpty) next.remove(dateKey);
    } else {
      set.add(exerciseId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _completedKey(uid), json.encode(_encodeCompleted(next)));
    _sync.syncCompletedExercises(uid, next); // fire-and-forget
    return next;
  }

  Future<void> _refreshCompletedFromFirebase(
      SharedPreferences prefs, String uid) async {
    final remote = await _sync.fetchCompletedExercises(uid);
    if (remote.isEmpty) return;
    if (FirebaseAuth.instance.currentUser?.uid != uid) return;
    await prefs.setString(
        _completedKey(uid), json.encode(_encodeCompleted(remote)));
  }

  Map<String, dynamic> _encodeCompleted(Map<String, Set<String>> m) =>
      {for (final e in m.entries) e.key: e.value.toList()};

  Map<String, Set<String>> _decodeCompleted(Map<String, dynamic> j) => {
        for (final e in j.entries) e.key: Set<String>.from(e.value as List),
      };

  Map<String, dynamic> _encode(Map<int, List<String>> m) =>
      {for (final e in m.entries) '${e.key}': e.value};

  Map<int, List<String>> _decode(Map<String, dynamic> j) => {
        for (final e in j.entries)
          int.parse(e.key): List<String>.from(e.value as List),
      };
}
