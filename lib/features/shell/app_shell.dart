import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';

import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../orders/orders_screen.dart';
import '../clients/clients_screen.dart';
import '../analytics/analytics_screen.dart';
import '../forecasts/forecasts_screen.dart';
import '../workload/workload_screen.dart';
import '../profile/profile_screen.dart';
import '../models/models_screen.dart';
import '../finance/finance_screen.dart';
import '../employees/employees_screen.dart';
import '../payroll/payroll_screen.dart';
import '../worklogs/worklogs_screen.dart';
import '../subscription/subscription_screen.dart';
import '../materials/materials_screen.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AppProvider? _appProvider;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to auth state changes
    final provider = context.read<AppProvider>();
    if (_appProvider != provider) {
      _appProvider?.removeListener(_onAuthStateChanged);
      _appProvider = provider;
      _appProvider?.addListener(_onAuthStateChanged);
    }
  }

  @override
  void dispose() {
    _appProvider?.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (_appProvider?.state == AppState.unauthenticated) {
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
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final user = appProvider.user;

    return Drawer(
      backgroundColor: context.surfaceColor,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppSpacing.lg,
              bottom: AppSpacing.lg,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  user?.tenant?.name ?? context.l10n.myAtelierHint,
                  style: AppTypography.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: context.l10n.dashboard,
                  isSelected: _currentIndex == 0,
                  onTap: () => _navigateTo(0),
                ),
                _DrawerItem(
                  icon: Icons.receipt_long_outlined,
                  label: context.l10n.orders,
                  isSelected: _currentIndex == 2,
                  onTap: () => _navigateTo(2),
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  label: context.l10n.customers,
                  isSelected: _currentIndex == 1,
                  onTap: () => _navigateTo(1),
                ),
                _DrawerItem(
                  icon: Icons.analytics_outlined,
                  label: context.l10n.analytics,
                  isSelected: _currentIndex == 3,
                  onTap: () => _navigateTo(3),
                ),
                _DrawerItem(
                  icon: Icons.auto_graph_outlined,
                  label: context.l10n.forecast,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForecastsScreen()),
                    );
                  },
                ),
                const Divider(height: 32),
                _DrawerItem(
                  icon: Icons.calendar_month_outlined,
                  label: context.l10n.workload,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WorkloadScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.checkroom_outlined,
                  label: context.l10n.models,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ModelsScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Склад материалов',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MaterialsScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.people_alt_outlined,
                  label: context.l10n.employees,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EmployeesScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.calculate_outlined,
                  label: context.l10n.payroll,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PayrollScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.assignment_outlined,
                  label: context.l10n.workRecords,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WorklogsScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.attach_money_outlined,
                  label: context.l10n.finance,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FinanceScreen()),
                    );
                  },
                ),
                const Divider(height: 32),
                _DrawerItem(
                  icon: Icons.card_membership_outlined,
                  label: context.l10n.subscription,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: context.l10n.settings,
                  onTap: () => _navigateTo(4),
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  label: context.l10n.help,
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon();
                  },
                ),
              ],
            ),
          ),

          // Logout
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              title: Text(
                context.l10n.logout,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await context.read<AppProvider>().logout();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(int index) {
    Navigator.pop(context);
    setState(() {
      _currentIndex = index;
    });
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.comingSoon),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : context.surfaceVariantColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? AppColors.primary : context.textSecondaryColor,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: AppTypography.bodyLarge.copyWith(
            color: isSelected ? AppColors.primary : context.textPrimaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        selectedTileColor: AppColors.primary.withOpacity(0.05),
        onTap: onTap,
      ),
    );
  }
}
