import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/training_plan.dart';
import '../../firebase_options.dart';

/// Syncs training plan data to Firestore using anonymous auth.
///
/// Firestore layout:
///   users/{uid}/plan/config          — WeeklyPlanConfig document
///   users/{uid}/completed_days/{key} — one doc per completed day
///
/// All methods are no-ops when [kFirebaseConfigured] is false, so the app
/// works in local-only mode until the project is connected.
class FirebaseSyncService {
  FirebaseSyncService._();
  static final FirebaseSyncService instance = FirebaseSyncService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  String? _uid;

  Future<String?> _getUid() async {
    if (!kFirebaseConfigured) return null;
    if (_uid != null) return _uid;
    try {
      final user = _auth.currentUser ?? (await _auth.signInAnonymously()).user;
      _uid = user?.uid;
      return _uid;
    } catch (_) {
      return null;
    }
  }

  DocumentReference _configDoc(String uid) =>
      _db.collection('users').doc(uid).collection('plan').doc('config');

  DocumentReference _completedDoc(String uid, String dateKey) =>
      _db.collection('users').doc(uid).collection('completed_days').doc(dateKey);

  CollectionReference _completedCol(String uid) =>
      _db.collection('users').doc(uid).collection('completed_days');

  // ── Config ─────────────────────────────────────────────────────────────────

  Future<void> syncConfig(WeeklyPlanConfig config) async {
    final uid = await _getUid();
    if (uid == null) return;
    try {
      await _configDoc(uid).set(config.toJson());
    } catch (_) {}
  }

  Future<WeeklyPlanConfig?> fetchConfig() async {
    final uid = await _getUid();
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
    final uid = await _getUid();
    if (uid == null) return;
    try {
      final key = CompletedDay.keyFor(date);
      await _completedDoc(uid, key)
          .set(CompletedDay(date: date, activity: activity).toJson());
    } catch (_) {}
  }

  Future<void> deleteCompletedDay(DateTime date) async {
    final uid = await _getUid();
    if (uid == null) return;
    try {
      await _completedDoc(uid, CompletedDay.keyFor(date)).delete();
    } catch (_) {}
  }

  Future<Map<String, CompletedDay>> fetchCompleted() async {
    final uid = await _getUid();
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
}
