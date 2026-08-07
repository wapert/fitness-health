import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'biometric_auth_service.dart';
import 'firebase_sync.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signUp(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  /// Permanently deletes the signed-in user's account: all Firestore data
  /// (training plan, completed days/exercises, fasting session), any saved
  /// biometric login credentials, local cached data, and the Firebase Auth
  /// account itself. Requires a recent sign-in, so [password] is used to
  /// reauthenticate first — throws [FirebaseAuthException] (e.g.
  /// 'wrong-password') if that fails, before anything is deleted.
  Future<void> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user to delete.');
    }
    final uid = user.uid;
    final email = user.email;
    if (email != null) {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
    }

    await FirebaseSyncService.instance.deleteAllUserData(uid);
    await BiometricAuthService.instance.clearLoginCredentials(uid);

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where((k) => k.endsWith('_$uid')).toList()) {
      await prefs.remove(key);
    }

    // Deleting the Firebase user also signs them out; the app's auth
    // StreamBuilder picks up the null user and returns to the sign-in screen.
    await user.delete();
  }

  String errorMessage(FirebaseAuthException e) => switch (e.code) {
        'user-not-found'       => '找不到此帳號',
        'wrong-password'       => '密碼錯誤',
        'invalid-credential'   => 'Email 或密碼錯誤',
        'email-already-in-use' => '此 Email 已被使用',
        'weak-password'        => '密碼至少需要 6 個字元',
        'invalid-email'        => 'Email 格式不正確',
        'too-many-requests'    => '嘗試次數過多，請稍後再試',
        'requires-recent-login' => '請重新輸入密碼以確認身分',
        _                      => '發生錯誤：${e.message}',
      };
}
