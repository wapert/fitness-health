import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/auth_screen.dart';
import '../../features/body_map/screens/body_map_screen.dart';
import '../../features/fasting/screens/fasting_screen.dart';
import '../../features/jogging/screens/jogging_home_screen.dart';
import '../../features/nutrition/screens/nutrition_home_screen.dart';
import '../../features/plan/screens/plan_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/stretching/screens/stretching_home_screen.dart';
import '../../features/training/screens/training_home_screen.dart';
import '../../firebase_options.dart';
import '../services/auth_service.dart';
import '../../shared/widgets/main_shell.dart';

final _authNotifier = _AuthChangeNotifier();

final appRouter = GoRouter(
  initialLocation: '/training',
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    if (!kFirebaseConfigured) return null; // local-only mode: no auth gate
    final isLoggedIn = AuthService.instance.currentUser != null;
    final isOnLogin  = state.matchedLocation == '/login';
    if (!isLoggedIn && !isOnLogin) return '/login';
    if (isLoggedIn  && isOnLogin)  return '/training';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const AuthScreen()),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/training',   builder: (_, __) => const TrainingHomeScreen()),
        GoRoute(path: '/stretching', builder: (_, __) => const StretchingHomeScreen()),
        GoRoute(path: '/nutrition',  builder: (_, __) => const NutritionHomeScreen()),
        GoRoute(path: '/fasting',    builder: (_, __) => const FastingScreen()),
        GoRoute(path: '/body-map',   builder: (_, __) => const BodyMapScreen()),
        GoRoute(path: '/jogging',    builder: (_, __) => const JoggingHomeScreen()),
        GoRoute(path: '/plan',       builder: (_, __) => const PlanScreen()),
        GoRoute(path: '/profile',    builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
);

// Listens to Firebase auth state changes and notifies GoRouter to re-evaluate
// its redirect. When kFirebaseConfigured is false this is a no-op.
class _AuthChangeNotifier extends ChangeNotifier {
  StreamSubscription<User?>? _sub;

  _AuthChangeNotifier() {
    if (kFirebaseConfigured) {
      _sub = AuthService.instance.authStateChanges.listen((_) => notifyListeners());
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
