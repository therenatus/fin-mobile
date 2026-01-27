import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../riverpod/providers.dart';
import '../../features/shell/app_shell.dart';
import '../../features/forecasts/forecasts_screen.dart';
import '../../features/workload/workload_screen.dart';
import '../../features/models/models_screen.dart';
import '../../features/finance/finance_screen.dart';
import '../../features/employees/employees_screen.dart';
import '../../features/payroll/payroll_screen.dart';
import '../../features/worklogs/worklogs_screen.dart';
import '../../features/production/production_screen.dart';
import '../../features/materials/materials_screen.dart';
import '../../features/qc/qc_screen.dart';
import '../../features/subscription/subscription_screen.dart';
import '../../features/notifications/notification_center_screen.dart';
import '../../features/help/help_screen.dart';

class AppDrawer extends ConsumerWidget {
  final String? currentRoute;
  final void Function(int index)? onTabSelected;

  const AppDrawer({super.key, this.currentRoute, this.onTabSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

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
                  label: context.l10n.dashboard,
                  isSelected: currentRoute == 'home',
                  onTap: () => _navigateToShell(context, 0, 'home'),
                ),
                _DrawerItem(
                  icon: Icons.receipt_long_outlined,
                  label: context.l10n.orders,
                  isSelected: currentRoute == 'orders',
                  onTap: () => _navigateToShell(context, 2, 'orders'),
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  label: context.l10n.customers,
                  isSelected: currentRoute == 'clients',
                  onTap: () => _navigateToShell(context, 1, 'clients'),
                ),
                _DrawerItem(
                  icon: Icons.analytics_outlined,
                  label: context.l10n.analytics,
                  isSelected: currentRoute == 'analytics',
                  onTap: () => _navigateToShell(context, 3, 'analytics'),
                ),
                _DrawerItem(
                  icon: Icons.auto_graph_outlined,
                  label: context.l10n.forecast,
                  isSelected: currentRoute == 'forecasts',
                  onTap: () => _navigateToPushed(context, const ForecastsScreen(), 'forecasts'),
                ),
                const Divider(height: 32),
                _DrawerItem(
                  icon: Icons.calendar_month_outlined,
                  label: context.l10n.workload,
                  isSelected: currentRoute == 'workload',
                  onTap: () => _navigateToPushed(context, const WorkloadScreen(), 'workload'),
                ),
                _DrawerItem(
                  icon: Icons.precision_manufacturing_outlined,
                  label: 'Производство',
                  isSelected: currentRoute == 'production',
                  onTap: () => _navigateToPushed(context, const ProductionScreen(), 'production'),
                ),
                _DrawerItem(
                  icon: Icons.checkroom_outlined,
                  label: context.l10n.models,
                  isSelected: currentRoute == 'models',
                  onTap: () => _navigateToPushed(context, const ModelsScreen(), 'models'),
                ),
                _DrawerItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Склад материалов',
                  isSelected: currentRoute == 'materials',
                  onTap: () => _navigateToPushed(context, const MaterialsScreen(), 'materials'),
                ),
                _DrawerItem(
                  icon: Icons.fact_check_outlined,
                  label: 'Контроль качества',
                  isSelected: currentRoute == 'qc',
                  onTap: () => _navigateToPushed(context, const QcScreen(), 'qc'),
                ),
                _DrawerItem(
                  icon: Icons.people_alt_outlined,
                  label: context.l10n.employees,
                  isSelected: currentRoute == 'employees',
                  onTap: () => _navigateToPushed(context, const EmployeesScreen(), 'employees'),
                ),
                _DrawerItem(
                  icon: Icons.calculate_outlined,
                  label: context.l10n.payroll,
                  isSelected: currentRoute == 'payroll',
                  onTap: () => _navigateToPushed(context, const PayrollScreen(), 'payroll'),
                ),
                _DrawerItem(
                  icon: Icons.assignment_outlined,
                  label: context.l10n.workRecords,
                  isSelected: currentRoute == 'worklogs',
                  onTap: () => _navigateToPushed(context, const WorklogsScreen(), 'worklogs'),
                ),
                _DrawerItem(
                  icon: Icons.attach_money_outlined,
                  label: context.l10n.finance,
                  isSelected: currentRoute == 'finance',
                  onTap: () => _navigateToPushed(context, const FinanceScreen(), 'finance'),
                ),
                const Divider(height: 32),
                _buildNotificationsItem(context, ref),
                _DrawerItem(
                  icon: Icons.card_membership_outlined,
                  label: context.l10n.subscription,
                  isSelected: currentRoute == 'subscription',
                  onTap: () => _navigateToPushed(context, const SubscriptionScreen(), 'subscription'),
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: context.l10n.settings,
                  isSelected: currentRoute == 'profile',
                  onTap: () => _navigateToShell(context, 4, 'profile'),
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  label: context.l10n.help,
                  isSelected: currentRoute == 'help',
                  onTap: () => _navigateToPushed(context, const HelpScreen(), 'help'),
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
                context.l10n.logout,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authNotifierProvider.notifier).logout();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsItem(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: ListTile(
        leading: Badge(
          isLabelVisible: unreadCount > 0,
          label: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: const TextStyle(fontSize: 10),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: currentRoute == 'notifications'
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : context.surfaceVariantColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: currentRoute == 'notifications'
                  ? AppColors.primary
                  : context.textSecondaryColor,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Уведомления',
          style: AppTypography.bodyLarge.copyWith(
            color: currentRoute == 'notifications'
                ? AppColors.primary
                : context.textPrimaryColor,
            fontWeight: currentRoute == 'notifications'
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        selected: currentRoute == 'notifications',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
        onTap: () => _navigateToPushed(context, const NotificationCenterScreen(), 'notifications'),
      ),
    );
  }

  /// Navigate to AppShell with specific tab index
  void _navigateToShell(BuildContext context, int tabIndex, String route) {
    Navigator.pop(context); // Close drawer
    if (currentRoute == route) return;

    if (onTabSelected != null) {
      onTabSelected!(tabIndex);
    } else {
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
    if (currentRoute == route) return;

    if (onTabSelected != null) {
      // Already inside AppShell, just push
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } else {
      // Go back to AppShell first, then push the screen
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
