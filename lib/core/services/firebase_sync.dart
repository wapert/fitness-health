import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fasting.dart';
import '../models/training_plan.dart';

/// Syncs training plan data to Firestore.
///
/// Firestore layout:
///   users/{uid}/plan/config          — WeeklyPlanConfig document
///   users/{uid}/completed_days/{key} — one doc per completed day
///
/// The caller supplies the authenticated UID so an account change during an
/// asynchronous operation cannot redirect data to another member.
class FirebaseSyncService {
  FirebaseSyncService._();
  static final FirebaseSyncService instance = FirebaseSyncService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference _configDoc(String uid) =>
      _db.collection('users').doc(uid).collection('plan').doc('config');

  DocumentReference _completedDoc(String uid, String dateKey) => _db
      .collection('users')
      .doc(uid)
      .collection('completed_days')
      .doc(dateKey);

  CollectionReference _completedCol(String uid) =>
      _db.collection('users').doc(uid).collection('completed_days');

  DocumentReference _fastingDoc(String uid) =>
      _db.collection('users').doc(uid).collection('fasting').doc('current');

  // ── Fasting session ───────────────────────────────────────────────────────

  Future<void> syncFastingSession(String uid, FastingSession session) async {
    try {
      await _fastingDoc(uid).set(session.toJson());
    } catch (_) {}
  }

  Future<FastingSession?> fetchFastingSession(String uid) async {
    try {
      final snap = await _fastingDoc(uid).get();
      if (!snap.exists) return null;
      return FastingSession.fromJson(
          Map<String, dynamic>.from(snap.data()! as Map));
    } catch (_) {
      return null;
    }
  }

  // ── Config ─────────────────────────────────────────────────────────────────

  Future<void> syncConfig(String uid, WeeklyPlanConfig config) async {
    try {
      await _configDoc(uid).set(config.toJson());
    } catch (_) {}
  }

  Future<WeeklyPlanConfig?> fetchConfig(String uid) async {
    try {
      final snap = await _configDoc(uid).get();
      if (!snap.exists) return null;
      return WeeklyPlanConfig.fromJson(snap.data()! as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Completed days ─────────────────────────────────────────────────────────

  Future<void> setCompletedDay(
      String uid, DateTime date, PlanActivity activity) async {
    try {
      final key = CompletedDay.keyFor(date);
      await _completedDoc(uid, key)
          .set(CompletedDay(date: date, activity: activity).toJson());
    } catch (_) {}
  }

  Future<void> deleteCompletedDay(String uid, DateTime date) async {
    try {
      await _completedDoc(uid, CompletedDay.keyFor(date)).delete();
    } catch (_) {}
  }

  Future<Map<String, CompletedDay>> fetchCompleted(String uid) async {
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

  Future<void> syncExerciseSchedule(
      String uid, Map<int, List<String>> schedule) async {
    try {
      await _exerciseScheduleDoc(uid)
          .set({for (final e in schedule.entries) '${e.key}': e.value});
    } catch (_) {}
  }

  Future<Map<int, List<String>>> fetchExerciseSchedule(String uid) async {
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

  // ── Completed exercises (dateKey → exerciseIds done that date) ───────────────

  DocumentReference _completedExercisesDoc(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('plan')
      .doc('completed_exercises');

  Future<void> syncCompletedExercises(
      String uid, Map<String, Set<String>> data) async {
    try {
      await _completedExercisesDoc(uid)
          .set({for (final e in data.entries) e.key: e.value.toList()});
    } catch (_) {}
  }

  Future<Map<String, Set<String>>> fetchCompletedExercises(String uid) async {
    try {
      final snap = await _completedExercisesDoc(uid).get();
      if (!snap.exists) return {};
      final data = snap.data()! as Map<String, dynamic>;
      return {
        for (final e in data.entries) e.key: Set<String>.from(e.value as List),
      };
    } catch (_) {
      return {};
    }
  }

  // ── Account deletion ─────────────────────────────────────────────────────────

  /// Permanently deletes every Firestore document owned by [uid]:
  /// users/{uid}/plan/*, users/{uid}/completed_days/*, users/{uid}/fasting/*,
  /// and the users/{uid} document itself.
  Future<void> deleteAllUserData(String uid) async {
    final userDoc = _db.collection('users').doc(uid);

    // Named documents with known paths.
    final docs = [
      _configDoc(uid),
      _exerciseScheduleDoc(uid),
      _completedExercisesDoc(uid),
      _fastingDoc(uid),
    ];
    for (final doc in docs) {
      try {
        await doc.delete();
      } catch (_) {}
    }

    // completed_days is a collection — enumerate and batch-delete.
    try {
      final snap = await _completedCol(uid).get();
      if (snap.docs.isNotEmpty) {
        final batch = _db.batch();
        for (final d in snap.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }
    } catch (_) {}

    try {
      await userDoc.delete();
    } catch (_) {}
  }
}
