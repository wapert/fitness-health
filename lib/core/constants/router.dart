import 'package:go_router/go_router.dart';
import '../../features/training/screens/training_home_screen.dart';
import '../../features/stretching/screens/stretching_home_screen.dart';
import '../../features/nutrition/screens/nutrition_home_screen.dart';
import '../../features/fasting/screens/fasting_screen.dart';
import '../../features/body_map/screens/body_map_screen.dart';
import '../../features/jogging/screens/jogging_home_screen.dart';
import '../../features/plan/screens/plan_screen.dart';
import '../../shared/widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/training',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/training',    builder: (_, __) => const TrainingHomeScreen()),
        GoRoute(path: '/stretching',  builder: (_, __) => const StretchingHomeScreen()),
        GoRoute(path: '/nutrition',   builder: (_, __) => const NutritionHomeScreen()),
        GoRoute(path: '/fasting',     builder: (_, __) => const FastingScreen()),
        GoRoute(path: '/body-map',    builder: (_, __) => const BodyMapScreen()),
        GoRoute(path: '/jogging',     builder: (_, __) => const JoggingHomeScreen()),
        GoRoute(path: '/plan',        builder: (_, __) => const PlanScreen()),
      ],
    ),
  ],
);
