import 'package:audio_session/audio_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/router.dart';
import 'core/services/auth_service.dart';
import 'core/services/biometric_auth_service.dart';
import 'features/auth/screens/auth_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final audioSession = await AudioSession.instance;
  await audioSession.configure(const AudioSessionConfiguration.music());
  runApp(const ProviderScope(child: FitnessApp()));
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '全方位健身',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
      builder: (context, child) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        initialData: FirebaseAuth.instance.currentUser,
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) return const AuthScreen();

          return _AuthenticatedApp(
            key: ValueKey(user.uid),
            user: user,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _AuthenticatedApp extends StatefulWidget {
  const _AuthenticatedApp({
    super.key,
    required this.user,
    required this.child,
  });
  final User user;
  final Widget child;

  @override
  State<_AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<_AuthenticatedApp>
    with WidgetsBindingObserver {
  final _biometrics = BiometricAuthService.instance;
  bool _loading = true;
  bool _unlocked = false;
  bool _authenticating = false;
  String? _error;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_biometrics.consumeRecentAuthentication(widget.user.uid)) {
      _loading = false;
      _unlocked = true;
      return;
    }
    _initialize();
  }

  Future<void> _initialize() async {
    final enabled = await _biometrics.isEnabled(widget.user.uid);
    if (!mounted) return;
    setState(() {
      _unlocked = !enabled;
      _loading = false;
    });
    if (enabled) await _unlock();
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _error = null;
    });
    final authenticated = await _biometrics.authenticate();
    if (!mounted) return;
    setState(() {
      _authenticating = false;
      _unlocked = authenticated;
      if (!authenticated) _error = '驗證未完成，請再試一次';
    });
  }

  Future<void> _handleResume() async {
    final enabled = await _biometrics.isEnabled(widget.user.uid);
    if (!mounted || _lifecycle != AppLifecycleState.resumed) return;
    if (enabled && !_unlocked) await _unlock();
  }

  Future<void> _handleBackground() async {
    final enabled = await _biometrics.isEnabled(widget.user.uid);
    if (!mounted || _lifecycle == AppLifecycleState.resumed) return;
    setState(() {
      if (enabled) _unlocked = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    if (_authenticating) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _handleBackground();
    } else if (state == AppLifecycleState.resumed) {
      _handleResume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_unlocked) {
      return _BiometricLockScreen(
        authenticating: _authenticating,
        error: _error,
        onUnlock: _unlock,
        onSignOut: _signOut,
      );
    }

    return widget.child;
  }
}

class _BiometricLockScreen extends StatelessWidget {
  const _BiometricLockScreen({
    required this.authenticating,
    required this.error,
    required this.onUnlock,
    required this.onSignOut,
  });

  final bool authenticating;
  final String? error;
  final VoidCallback onUnlock;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fingerprint, size: 72, color: scheme.primary),
                  const SizedBox(height: 20),
                  Text(
                    '解鎖全方位健身',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '使用裝置的生物辨識驗證身分',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Text(error!, style: TextStyle(color: scheme.error)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: authenticating ? null : onUnlock,
                      icon: authenticating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.fingerprint),
                      label: const Text('使用生物辨識解鎖'),
                    ),
                  ),
                  TextButton(
                    onPressed: onSignOut,
                    child: const Text('改用其他帳號'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
