import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/employee_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/login_screen.dart';

class EmployeeProfileScreen extends StatelessWidget {
  const EmployeeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          final user = provider.user;
          if (user == null) return const SizedBox.shrink();

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
                        provider.getRoleLabel(user.role),
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
                'Контактная информация',
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
                      label: 'Email',
                      value: user.email,
                    ),
                    if (user.phone != null) ...[
                      Divider(height: 1, color: context.dividerColor),
                      _ProfileInfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Телефон',
                        value: user.phone!,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Workplace section
              Text(
                'Место работы',
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
                    'Ателье',
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
                  'Активность',
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
                    label: 'Последний вход',
                    value: _formatLastLogin(user.lastLoginAt!),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Theme section
              Text(
                'Внешний вид',
                style: AppTypography.labelLarge.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Consumer<AppProvider>(
                builder: (context, appProvider, _) {
                  return Container(
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: _ThemeSelector(
                      currentTheme: appProvider.themeMode,
                      onChanged: (mode) => appProvider.setThemeMode(mode),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Logout button
              OutlinedButton.icon(
                onPressed: () => _logout(context, provider),
                icon: const Icon(Icons.logout),
                label: const Text('Выйти'),
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
                  'AteliePro Employee v1.0.0',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textTertiaryColor,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatLastLogin(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Только что';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} мин. назад';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} ч. назад';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} дн. назад';
    } else {
      return DateFormat('d MMMM', 'ru').format(dateTime);
    }
  }

  Future<void> _logout(BuildContext context, EmployeeProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.logout();
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
                'Тема',
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
                label: 'Светлая',
                isSelected: currentTheme == ThemeMode.light,
                onTap: () => onChanged(ThemeMode.light),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ThemeOption(
                icon: Icons.dark_mode_outlined,
                label: 'Тёмная',
                isSelected: currentTheme == ThemeMode.dark,
                onTap: () => onChanged(ThemeMode.dark),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ThemeOption(
                icon: Icons.settings_suggest_outlined,
                label: 'Авто',
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
