import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/subscription_provider.dart';
import '../../core/services/api_service.dart';
import '../subscription/subscription_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const ProfileScreen({super.key, this.onMenuPressed});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingAvatar = false;
  final _picker = ImagePicker();

  ApiService get _api => context.read<AppProvider>().api;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SubscriptionProvider>();
      if (!provider.isInitialized) {
        provider.init();
      }
    });
  }

  void _showAvatarOptions(AppProvider provider) {
    final hasAvatar = provider.user?.avatarUrl != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Камера'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(provider, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.secondary),
                ),
                title: const Text('Галерея'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(provider, ImageSource.gallery);
                },
              ),
              if (hasAvatar)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                  title: const Text('Удалить'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteAvatar(provider);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(AppProvider provider, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingAvatar = true);

      final api = _api;
      final updatedUser = await api.uploadAvatar(File(pickedFile.path));
      provider.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Аватар обновлён'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _deleteAvatar(AppProvider provider) async {
    try {
      setState(() => _isUploadingAvatar = true);

      final api = _api;
      final updatedUser = await api.deleteAvatar();
      provider.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Аватар удалён'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuPressed,
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final user = provider.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Profile header
                _buildProfileHeader(user, provider),
                const SizedBox(height: AppSpacing.xl),

                // Account section
                _buildSection(
                  context,
                  title: 'Аккаунт',
                  children: [
                    _SettingsItem(
                      icon: Icons.person_outline,
                      title: 'Личные данные',
                      subtitle: 'Имя, email, телефон',
                      onTap: () => _showComingSoon(context),
                    ),
                    _SettingsItem(
                      icon: Icons.store_outlined,
                      title: 'Данные ателье',
                      subtitle: user?.tenant?.name ?? 'Название, адрес, реквизиты',
                      onTap: () => _showComingSoon(context),
                    ),
                    _SettingsItem(
                      icon: Icons.lock_outline,
                      title: 'Сменить пароль',
                      subtitle: 'Изменить текущий пароль',
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Appearance section
                _buildSection(
                  context,
                  title: 'Внешний вид',
                  children: [
                    _ThemeSelector(
                      currentTheme: provider.themeMode,
                      onChanged: (mode) => provider.setThemeMode(mode),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Subscription section
                Consumer<SubscriptionProvider>(
                  builder: (context, subProvider, _) {
                    final usage = subProvider.usage;
                    return _buildSection(
                      context,
                      title: 'Подписка',
                      children: [
                        _SubscriptionCardNew(
                          planName: usage?.planName ?? 'Free',
                          status: usage?.status ?? 'free',
                          expiresAt: usage?.expiresAt,
                          currentClients: usage?.currentClients ?? 0,
                          clientLimit: usage?.limits.clientLimit ?? 1,
                          currentEmployees: usage?.currentEmployees ?? 0,
                          employeeLimit: usage?.limits.employeeLimit ?? 10,
                          onUpgrade: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SubscriptionScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Other section
                _buildSection(
                  context,
                  title: 'Другое',
                  children: [
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      title: 'Уведомления',
                      subtitle: 'Push, email, SMS',
                      onTap: () => _showComingSoon(context),
                    ),
                    _SettingsItem(
                      icon: Icons.help_outline,
                      title: 'Помощь и поддержка',
                      subtitle: 'FAQ, связаться с нами',
                      onTap: () => _showComingSoon(context),
                    ),
                    _SettingsItem(
                      icon: Icons.info_outline,
                      title: 'О приложении',
                      subtitle: 'Версия 1.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, provider),
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: Text(
                      'Выйти из аккаунта',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user, AppProvider provider) {
    final subProvider = context.watch<SubscriptionProvider>();
    final planName = subProvider.usage?.planName ?? 'Free';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [AppShadows.lg],
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: _isUploadingAvatar ? null : () => _showAvatarOptions(provider),
            child: Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isUploadingAvatar
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : user?.avatarUrl != null
                          ? CachedNetworkImage(
                              imageUrl: user!.avatarUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Text(
                                  ((user.email?.isNotEmpty == true) ? user.email!.substring(0, 1).toUpperCase() : 'A'),
                                  style: AppTypography.h2.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                ((user?.email?.isNotEmpty == true) ? user!.email!.substring(0, 1).toUpperCase() : 'A'),
                                style: AppTypography.h2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.tenant?.name ?? 'Моё ателье',
                  style: AppTypography.h4.copyWith(
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
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    planName,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: context.cardShadow,
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      indent: AppSpacing.lg + 40,
                      color: context.borderColor,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Скоро будет доступно'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.content_cut, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text('AteliePro'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Версия 1.0.0',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Приложение для управления ателье. Управляйте заказами, заказчиками и аналитикой в одном месте.',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.logout();
            },
            child: Text(
              'Выйти',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: context.textSecondaryColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: context.textSecondaryColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: context.textTertiaryColor,
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

class _SubscriptionCardNew extends StatelessWidget {
  final String planName;
  final String status;
  final DateTime? expiresAt;
  final int currentClients;
  final int clientLimit;
  final int currentEmployees;
  final int employeeLimit;
  final VoidCallback onUpgrade;

  const _SubscriptionCardNew({
    required this.planName,
    required this.status,
    this.expiresAt,
    required this.currentClients,
    required this.clientLimit,
    required this.currentEmployees,
    required this.employeeLimit,
    required this.onUpgrade,
  });

  String get _statusText {
    switch (status) {
      case 'active':
        return 'Активна';
      case 'trial':
        return 'Пробный период';
      case 'expired':
        return 'Истекла';
      default:
        return 'Бесплатный план';
    }
  }

  Color get _statusColor {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'trial':
        return AppColors.warning;
      case 'expired':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _planIcon {
    switch (planName.toLowerCase()) {
      case 'max':
        return Icons.rocket_launch;
      case 'ultra':
        return Icons.bolt;
      case 'pro':
        return Icons.workspace_premium;
      default:
        return Icons.star_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlimitedClients = clientLimit == 0;
    final isUnlimitedEmployees = employeeLimit == 0;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _planIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName,
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _statusText,
                        style: AppTypography.labelSmall.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (expiresAt != null)
                Text(
                  'до ${expiresAt!.day.toString().padLeft(2, '0')}.${expiresAt!.month.toString().padLeft(2, '0')}.${expiresAt!.year}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Usage stats
          Row(
            children: [
              Expanded(
                child: _UsageStat(
                  label: 'Заказчики',
                  current: currentClients,
                  limit: clientLimit,
                  isUnlimited: isUnlimitedClients,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UsageStat(
                  label: 'Сотрудники',
                  current: currentEmployees,
                  limit: employeeLimit,
                  isUnlimited: isUnlimitedEmployees,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Upgrade button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Управление подпиской'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageStat extends StatelessWidget {
  final String label;
  final int current;
  final int limit;
  final bool isUnlimited;

  const _UsageStat({
    required this.label,
    required this.current,
    required this.limit,
    required this.isUnlimited,
  });

  @override
  Widget build(BuildContext context) {
    final progress = isUnlimited ? 0.3 : (current / limit).clamp(0.0, 1.0);
    final isNearLimit = !isUnlimited && current >= limit * 0.8;
    final color = isNearLimit ? AppColors.warning : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUnlimited ? '$current / ∞' : '$current / $limit',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isNearLimit ? AppColors.warning : context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.borderColor,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  ApiService get _api => context.read<AppProvider>().api;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final api = _api;
      await api.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Пароль успешно изменён'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Сменить пароль'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Текущий пароль',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите текущий пароль';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'Новый пароль',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите новый пароль';
                }
                if (value.length < 8) {
                  return 'Минимум 8 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (value) {
                if (value != _newPasswordController.text) {
                  return 'Пароли не совпадают';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}
