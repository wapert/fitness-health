import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/fasting.dart';
import '../../../core/services/firebase_sync.dart';

/// Stores one current or most-recent fasting session per member.
///
/// Local storage keeps the clock working across app restarts and logout. The
/// Firestore copy restores it after login on another device or a reinstall.
class FastingService {
  final _sync = FirebaseSyncService.instance;

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Fasting sessions require an authenticated user.');
    }
    return uid;
  }

  String _key(String uid) => 'fasting_session_v1_$uid';

  Future<FastingSession?> load() async {
    final uid = _requireUid();
    final prefs = await SharedPreferences.getInstance();
    final local = _decode(prefs.getString(_key(uid)));
    final remote = await _sync.fetchFastingSession(uid);

    final latest = _latest(local, remote);
    if (latest == null) return null;

    await prefs.setString(_key(uid), json.encode(latest.toJson()));
    if (remote == null || latest.updatedAt.isAfter(remote.updatedAt)) {
      _sync.syncFastingSession(uid, latest);
    }
    return latest;
  }

  Future<void> save(FastingSession session) async {
    final uid = _requireUid();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(uid), json.encode(session.toJson()));
    _sync.syncFastingSession(uid, session);
  }

  FastingSession? _decode(String? raw) {
    if (raw == null) return null;
    try {
      return FastingSession.fromJson(
          Map<String, dynamic>.from(json.decode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  FastingSession? _latest(FastingSession? local, FastingSession? remote) {
    if (local == null) return remote;
    if (remote == null) return local;
    return remote.updatedAt.isAfter(local.updatedAt) ? remote : local;
  }
}
