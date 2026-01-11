import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../../features/shell/app_shell.dart';
import '../../features/forecasts/forecasts_screen.dart';
import '../../features/workload/workload_screen.dart';
import '../../features/models/models_screen.dart';
import '../../features/finance/finance_screen.dart';
import '../../features/employees/employees_screen.dart';
import '../../features/payroll/payroll_screen.dart';

class AppDrawer extends StatelessWidget {
  final String? currentRoute;

  const AppDrawer({super.key, this.currentRoute});

  @override
  Widget build(BuildContext context) {
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                  user?.tenant?.name ?? 'Моё ателье',
                  style: AppTypography.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
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
                // AppShell tabs (index 0-4)
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Дашборд',
                  isSelected: currentRoute == 'home',
                  onTap: () => _navigateToShell(context, 0, 'home'),
                ),
                _DrawerItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Заказы',
                  isSelected: currentRoute == 'orders',
                  onTap: () => _navigateToShell(context, 2, 'orders'),
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  label: 'Заказчики',
                  isSelected: currentRoute == 'clients',
                  onTap: () => _navigateToShell(context, 1, 'clients'),
                ),
                _DrawerItem(
                  icon: Icons.analytics_outlined,
                  label: 'Аналитика',
                  isSelected: currentRoute == 'analytics',
                  onTap: () => _navigateToShell(context, 3, 'analytics'),
                ),
                _DrawerItem(
                  icon: Icons.auto_graph_outlined,
                  label: 'Прогнозы',
                  isSelected: currentRoute == 'forecasts',
                  onTap: () => _navigateToPushed(context, const ForecastsScreen(), 'forecasts'),
                ),
                const Divider(height: 32),
                _DrawerItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'Загрузка',
                  isSelected: currentRoute == 'workload',
                  onTap: () => _navigateToPushed(context, const WorkloadScreen(), 'workload'),
                ),
                _DrawerItem(
                  icon: Icons.checkroom_outlined,
                  label: 'Модели',
                  isSelected: currentRoute == 'models',
                  onTap: () => _navigateToPushed(context, const ModelsScreen(), 'models'),
                ),
                _DrawerItem(
                  icon: Icons.people_alt_outlined,
                  label: 'Сотрудники',
                  isSelected: currentRoute == 'employees',
                  onTap: () => _navigateToPushed(context, const EmployeesScreen(), 'employees'),
                ),
                _DrawerItem(
                  icon: Icons.calculate_outlined,
                  label: 'Зарплата',
                  isSelected: currentRoute == 'payroll',
                  onTap: () => _navigateToPushed(context, const PayrollScreen(), 'payroll'),
                ),
                _DrawerItem(
                  icon: Icons.attach_money_outlined,
                  label: 'Финансы',
                  isSelected: currentRoute == 'finance',
                  onTap: () => _navigateToPushed(context, const FinanceScreen(), 'finance'),
                ),
                const Divider(height: 32),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Настройки',
                  isSelected: currentRoute == 'profile',
                  onTap: () => _navigateToShell(context, 4, 'profile'),
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
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              title: Text(
                'Выйти',
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

  /// Navigate to AppShell with specific tab index
  void _navigateToShell(BuildContext context, int tabIndex, String route) {
    Navigator.pop(context); // Close drawer
    if (currentRoute != route) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AppShell(initialIndex: tabIndex)),
        (route) => false,
      );
    }
  }

  /// Navigate to pushed screen (on top of AppShell)
  void _navigateToPushed(BuildContext context, Widget screen, String route) {
    Navigator.pop(context); // Close drawer
    if (currentRoute != route) {
      // First go back to AppShell, then push the screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AppShell()),
        (route) => false,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
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
                ? AppColors.primary.withValues(alpha: 0.1)
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
        selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
        onTap: onTap,
      ),
    );
  }
}
