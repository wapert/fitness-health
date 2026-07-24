import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/router.dart';
import 'features/auth/screens/auth_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: FitnessApp()));
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.data != null;

        // Not signed in → login screen (own MaterialApp = full Navigator/Overlay)
        if (!isLoggedIn) {
          return MaterialApp(
            title: '全方位健身',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: const AuthScreen(),
          );
        }

        // Signed in → full app with bottom-nav router
        return MaterialApp.router(
          title: '全方位健身',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: appRouter,
        );
      },
    );
  }
}
