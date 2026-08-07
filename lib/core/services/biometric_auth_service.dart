import 'dart:convert';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthService {
  BiometricAuthService._();
  static final instance = BiometricAuthService._();

  final LocalAuthentication _auth = LocalAuthentication();
  String? _recentlyAuthenticatedUid;

  static const _lastUidKey = 'biometric_login_last_uid_v1';

  String _key(String uid) => 'biometric_unlock_v1_$uid';
  String _emailKey(String uid) => 'biometric_login_email_v1_$uid';
  String _storageName(String uid) => 'fitness_login_credentials_v1_$uid';

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  Future<bool> isAvailable() async {
    if (!_isMobile) return false;
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEnabled(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(uid)) ?? false;
  }

  Future<void> setEnabled(String uid, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(uid), enabled);
  }

  Future<void> saveLoginCredentials({
    required String uid,
    required String email,
    required String password,
  }) async {
    final storage = await _credentialStorage(uid);
    await storage.write(json.encode({'email': email, 'password': password}));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUidKey, uid);
    await prefs.setString(_emailKey(uid), email);
    await prefs.setBool(_key(uid), true);
  }

  Future<BiometricLoginCredentials?> readLoginCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_lastUidKey);
    if (uid == null || !(prefs.getBool(_key(uid)) ?? false)) return null;

    try {
      final raw = await (await _credentialStorage(uid)).read();
      if (raw == null) return null;
      final jsonData = Map<String, dynamic>.from(json.decode(raw) as Map);
      _recentlyAuthenticatedUid = uid;
      return BiometricLoginCredentials(
        uid: uid,
        email: jsonData['email'] as String,
        password: jsonData['password'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> savedLoginEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_lastUidKey);
    if (uid == null || !(prefs.getBool(_key(uid)) ?? false)) return null;
    return prefs.getString(_emailKey(uid));
  }

  Future<bool> hasCredentialsFor(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool(_key(uid)) ?? false) &&
        prefs.getString(_emailKey(uid)) != null;
  }

  Future<void> clearLoginCredentials(String uid) async {
    try {
      await (await _credentialStorage(uid)).delete();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey(uid));
    await prefs.setBool(_key(uid), false);
    if (prefs.getString(_lastUidKey) == uid) {
      await prefs.remove(_lastUidKey);
    }
  }

  void markRecentlyAuthenticated(String uid) {
    _recentlyAuthenticatedUid = uid;
  }

  bool consumeRecentAuthentication(String uid) {
    if (_recentlyAuthenticatedUid != uid) return false;
    _recentlyAuthenticatedUid = null;
    return true;
  }

  Future<BiometricStorageFile> _credentialStorage(String uid) =>
      BiometricStorage().getStorage(
        _storageName(uid),
        options: StorageFileInitOptions(
          authenticationRequired: true,
          androidBiometricOnly: true,
          darwinBiometricOnly: true,
        ),
        promptInfo: const PromptInfo(
          iosPromptInfo: IosPromptInfo(
            saveTitle: '啟用生物辨識登入',
            accessTitle: '使用生物辨識登入全方位健身',
          ),
          androidPromptInfo: AndroidPromptInfo(
            title: '生物辨識登入',
            subtitle: '驗證身分以存取登入資料',
            negativeButton: '取消',
          ),
        ),
      );

  Future<bool> authenticate() async {
    if (!await isAvailable()) return false;
    try {
      return await _auth.authenticate(
        localizedReason: '請驗證身分以開啟全方位健身',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }
}

class BiometricLoginCredentials {
  const BiometricLoginCredentials({
    required this.uid,
    required this.email,
    required this.password,
  });

  final String uid;
  final String email;
  final String password;
}
