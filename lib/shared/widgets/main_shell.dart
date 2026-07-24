import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    (icon: Icons.fitness_center,    label: '重訓',  path: '/training'),
    (icon: Icons.self_improvement,  label: '伸展',  path: '/stretching'),
    (icon: Icons.directions_run,    label: '超慢跑', path: '/jogging'),
    (icon: Icons.calendar_month,    label: '計畫',  path: '/plan'),
    (icon: Icons.restaurant_menu,   label: '營養',  path: '/nutrition'),
    (icon: Icons.timer_outlined,    label: '斷食',  path: '/fasting'),
    (icon: Icons.accessibility_new, label: '肌群圖', path: '/body-map'),
    (icon: Icons.person_outline,    label: '帳號',  path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    return _tabs.indexWhere((t) => loc.startsWith(t.path)).clamp(0, _tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}
