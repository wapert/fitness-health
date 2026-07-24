import 'package:firebase_auth/firebase_auth.dart';

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

  String errorMessage(FirebaseAuthException e) => switch (e.code) {
        'user-not-found'       => '找不到此帳號',
        'wrong-password'       => '密碼錯誤',
        'invalid-credential'   => 'Email 或密碼錯誤',
        'email-already-in-use' => '此 Email 已被使用',
        'weak-password'        => '密碼至少需要 6 個字元',
        'invalid-email'        => 'Email 格式不正確',
        'too-many-requests'    => '嘗試次數過多，請稍後再試',
        _                      => '發生錯誤：${e.message}',
      };
}
