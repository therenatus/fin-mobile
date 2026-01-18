import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/login_screen.dart';

class EmployeeProfileScreen extends ConsumerWidget {
  const EmployeeProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.profile),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(employeeAuthNotifierProvider);
    final notifier = ref.read(employeeAuthNotifierProvider.notifier);
    final user = authState.user;
    if (user == null) return const SizedBox.shrink();

    // Get theme from Riverpod
    final currentTheme = ref.watch(themeNotifierProvider);

    return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // User info card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        _getInitials(user.name),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Name
                    Text(
                      user.name,
                      style: AppTypography.h2,
                      textAlign: TextAlign.center,
                    ),

                    // Role badge
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        notifier.getRoleLabel(user.role),
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Contact info section
              Text(
                context.l10n.contactInfo,
                style: AppTypography.labelLarge.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    _ProfileInfoTile(
                      icon: Icons.email_outlined,
                      label: context.l10n.email,
                      value: user.email,
                    ),
                    if (user.phone != null) ...[
                      Divider(height: 1, color: context.dividerColor),
                      _ProfileInfoTile(
                        icon: Icons.phone_outlined,
                        label: context.l10n.phoneLabel,
                        value: user.phone!,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Workplace section
              Text(
                context.l10n.workplace,
                style: AppTypography.labelLarge.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.store,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    user.tenantName,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    context.l10n.atelierLabel,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
              ),

              // Activity info
              if (user.lastLoginAt != null) ...[
                const SizedBox(height: AppSpacing.lg),

                Text(
                  context.l10n.activity,
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                Container(
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: _ProfileInfoTile(
                    icon: Icons.access_time,
                    label: context.l10n.lastLogin,
                    value: _formatLastLogin(context, user.lastLoginAt!),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Theme section
              Text(
                context.l10n.appearance,
                style: AppTypography.labelLarge.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: _ThemeSelector(
                  currentTheme: currentTheme,
                  onChanged: (mode) => ref.read(themeNotifierProvider.notifier).setThemeMode(mode),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Logout button
              OutlinedButton.icon(
                onPressed: () => _logout(context, notifier),
                icon: const Icon(Icons.logout),
                label: Text(context.l10n.logout),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // App version
              Center(
                child: Text(
                  context.l10n.appVersionEmployee,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textTertiaryColor,
                  ),
                ),
              ),
            ],
          );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatLastLogin(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return context.l10n.justNow;
    } else if (diff.inHours < 1) {
      return context.l10n.minutesAgo(diff.inMinutes);
    } else if (diff.inDays < 1) {
      return context.l10n.hoursAgo(diff.inHours);
    } else if (diff.inDays < 7) {
      return context.l10n.daysAgo(diff.inDays);
    } else {
      return DateFormat('d MMMM', 'ru').format(dateTime);
    }
  }

  Future<void> _logout(BuildContext context, EmployeeAuthNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.logoutTitle),
        content: Text(context.l10n.logoutQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(context.l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await notifier.logout();
      await StorageService().clearAppMode();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          color: context.textSecondaryColor,
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: context.textSecondaryColor,
        ),
      ),
      subtitle: Text(
        value,
        style: AppTypography.bodyLarge,
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({
    required this.currentTheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: context.textSecondaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.theme,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _ThemeOption(
                icon: Icons.light_mode_outlined,
                label: context.l10n.themeLight,
                isSelected: currentTheme == ThemeMode.light,
                onTap: () => onChanged(ThemeMode.light),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ThemeOption(
                icon: Icons.dark_mode_outlined,
                label: context.l10n.themeDark,
                isSelected: currentTheme == ThemeMode.dark,
                onTap: () => onChanged(ThemeMode.dark),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ThemeOption(
                icon: Icons.settings_suggest_outlined,
                label: context.l10n.themeAuto,
                isSelected: currentTheme == ThemeMode.system,
                onTap: () => onChanged(ThemeMode.system),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : context.surfaceVariantColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : context.textSecondaryColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.primary : context.textSecondaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
