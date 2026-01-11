import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/employee_provider.dart';
import '../../../core/services/storage_service.dart';
import '../tasks/my_tasks_screen.dart';
import '../history/work_history_screen.dart';
import '../profile/employee_profile_screen.dart';
import '../../auth/login_screen.dart';

class EmployeeAppShell extends StatefulWidget {
  const EmployeeAppShell({super.key});

  @override
  State<EmployeeAppShell> createState() => _EmployeeAppShellState();
}

class _EmployeeAppShellState extends State<EmployeeAppShell> {
  int _currentIndex = 0;
  EmployeeProvider? _employeeProvider;

  final List<Widget> _screens = const [
    MyTasksScreen(),
    WorkHistoryScreen(),
    EmployeeProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<EmployeeProvider>();
    if (_employeeProvider != provider) {
      _employeeProvider?.removeListener(_onAuthStateChanged);
      _employeeProvider = provider;
      _employeeProvider?.addListener(_onAuthStateChanged);
    }
  }

  @override
  void dispose() {
    _employeeProvider?.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (_employeeProvider?.isAuthenticated == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Задачи',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'История',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
