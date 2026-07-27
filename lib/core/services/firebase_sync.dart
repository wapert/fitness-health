import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/training_plan.dart';

/// Syncs training plan data to Firestore.
///
/// Firestore layout:
///   users/{uid}/plan/config          — WeeklyPlanConfig document
///   users/{uid}/completed_days/{key} — one doc per completed day
///
/// All methods silently no-op when the user is not signed in.
class FirebaseSyncService {
  FirebaseSyncService._();
  static final FirebaseSyncService instance = FirebaseSyncService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference _configDoc(String uid) =>
      _db.collection('users').doc(uid).collection('plan').doc('config');

  DocumentReference _completedDoc(String uid, String dateKey) =>
      _db.collection('users').doc(uid).collection('completed_days').doc(dateKey);

  CollectionReference _completedCol(String uid) =>
      _db.collection('users').doc(uid).collection('completed_days');

  // ── Config ─────────────────────────────────────────────────────────────────

  Future<void> syncConfig(WeeklyPlanConfig config) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _configDoc(uid).set(config.toJson());
    } catch (_) {}
  }

  Future<WeeklyPlanConfig?> fetchConfig() async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final snap = await _configDoc(uid).get();
      if (!snap.exists) return null;
      return WeeklyPlanConfig.fromJson(snap.data()! as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Completed days ─────────────────────────────────────────────────────────

  Future<void> setCompletedDay(DateTime date, PlanActivity activity) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final key = CompletedDay.keyFor(date);
      await _completedDoc(uid, key)
          .set(CompletedDay(date: date, activity: activity).toJson());
    } catch (_) {}
  }

  Future<void> deleteCompletedDay(DateTime date) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _completedDoc(uid, CompletedDay.keyFor(date)).delete();
    } catch (_) {}
  }

  Future<Map<String, CompletedDay>> fetchCompleted() async {
    final uid = _uid;
    if (uid == null) return {};
    try {
      final snap = await _completedCol(uid).get();
      return {
        for (final doc in snap.docs)
          doc.id: CompletedDay.fromJson(doc.data()! as Map<String, dynamic>)
      };
    } catch (_) {
      return {};
    }
  }

  // ── Exercise schedule (weekday → exerciseIds) ────────────────────────────────

  DocumentReference _exerciseScheduleDoc(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('plan')
      .doc('exercise_schedule');

  Future<void> syncExerciseSchedule(Map<int, List<String>> schedule) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _exerciseScheduleDoc(uid).set(
          {for (final e in schedule.entries) '${e.key}': e.value});
    } catch (_) {}
  }

  Future<Map<int, List<String>>> fetchExerciseSchedule() async {
    final uid = _uid;
    if (uid == null) return {};
    try {
      final snap = await _exerciseScheduleDoc(uid).get();
      if (!snap.exists) return {};
      final data = snap.data()! as Map<String, dynamic>;
      return {
        for (final e in data.entries)
          int.parse(e.key): List<String>.from(e.value as List),
      };
    } catch (_) {
      return {};
    }
  }
}
