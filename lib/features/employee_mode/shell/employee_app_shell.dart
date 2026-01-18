import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/riverpod/providers.dart';
import '../tasks/my_tasks_screen.dart';
import '../history/work_history_screen.dart';
import '../profile/employee_profile_screen.dart';
import '../../auth/login_screen.dart';

class EmployeeAppShell extends ConsumerStatefulWidget {
  const EmployeeAppShell({super.key});

  @override
  ConsumerState<EmployeeAppShell> createState() => _EmployeeAppShellState();
}

class _EmployeeAppShellState extends ConsumerState<EmployeeAppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MyTasksScreen(),
    WorkHistoryScreen(),
    EmployeeProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes - if unauthenticated, go to login
    ref.listen<EmployeeAuthStateData>(employeeAuthNotifierProvider, (previous, current) {
      if (current.state == EmployeeAuthState.unauthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: context.l10n.tasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: context.l10n.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: context.l10n.profile,
          ),
        ],
      ),
    );
  }
}
