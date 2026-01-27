import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/widgets/app_drawer.dart';

import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../orders/orders_screen.dart';
import '../clients/clients_screen.dart';
import '../analytics/analytics_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadNotificationCount();
  }

  void _loadNotificationCount() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsNotifierProvider.notifier).refreshUnreadCount();
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  List<Widget> get _screens => [
    HomeScreen(onMenuPressed: _openDrawer),
    ClientsScreen(onMenuPressed: _openDrawer),
    OrdersScreen(onMenuPressed: _openDrawer),
    AnalyticsScreen(onMenuPressed: _openDrawer),
    ProfileScreen(onMenuPressed: _openDrawer),
  ];

  String get _currentRoute => const ['home', 'clients', 'orders', 'analytics', 'profile'][_currentIndex];

  List<NavigationDestination> _getDestinations(BuildContext context) => [
    NavigationDestination(
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home),
      label: context.l10n.home,
    ),
    NavigationDestination(
      icon: const Icon(Icons.people_outline),
      selectedIcon: const Icon(Icons.people),
      label: context.l10n.customers,
    ),
    NavigationDestination(
      icon: const Icon(Icons.receipt_long_outlined),
      selectedIcon: const Icon(Icons.receipt_long),
      label: context.l10n.orders,
    ),
    NavigationDestination(
      icon: const Icon(Icons.analytics_outlined),
      selectedIcon: const Icon(Icons.analytics),
      label: context.l10n.analytics,
    ),
    NavigationDestination(
      icon: const Icon(Icons.person_outline),
      selectedIcon: const Icon(Icons.person),
      label: context.l10n.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<AuthStateData>(authNotifierProvider, (previous, next) {
      if (!next.isAuthenticated && previous?.isAuthenticated == true) {
        // Navigate to login and clear navigation stack
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        });
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _getDestinations(context),
        backgroundColor: context.surfaceColor,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 65,
      ),
      drawer: AppDrawer(
        currentRoute: _currentRoute,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

}
