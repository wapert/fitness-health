import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/firebase_sync.dart';

/// Persists which exercises are scheduled on which weekday (1=Mon … 7=Sun).
/// Local-first (SharedPreferences) with background Firebase sync.
class ExerciseScheduleService {
  static const _key = 'exercise_schedule_v1';
  final _sync = FirebaseSyncService.instance;

  Future<Map<int, List<String>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw != null) {
      try {
        final local = _decode(json.decode(raw) as Map<String, dynamic>);
        _refreshFromFirebase(prefs); // background
        return local;
      } catch (_) {}
    }

    final remote = await _sync.fetchExerciseSchedule();
    if (remote.isNotEmpty) {
      await prefs.setString(_key, json.encode(_encode(remote)));
    }
    return remote;
  }

  Future<void> save(Map<int, List<String>> schedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(_encode(schedule)));
    _sync.syncExerciseSchedule(schedule); // fire-and-forget
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

  Future<void> _refreshFromFirebase(SharedPreferences prefs) async {
    final remote = await _sync.fetchExerciseSchedule();
    if (remote.isEmpty) return;
    await prefs.setString(_key, json.encode(_encode(remote)));
  }

  Map<String, dynamic> _encode(Map<int, List<String>> m) =>
      {for (final e in m.entries) '${e.key}': e.value};

  Map<int, List<String>> _decode(Map<String, dynamic> j) => {
        for (final e in j.entries)
          int.parse(e.key): List<String>.from(e.value as List),
      };
}
