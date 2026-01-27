import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/services/api_service.dart';
import '../subscription/subscription_screen.dart';
import 'widgets/widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onMenuPressed;

  const ProfileScreen({super.key, this.onMenuPressed});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingAvatar = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(subscriptionNotifierProvider);
      if (!state.isInitialized) {
        ref.read(subscriptionNotifierProvider.notifier).init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final usage = subscriptionState.usage;
    final planName = usage?.planName ?? 'Free';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.profile),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: widget.onMenuPressed != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onMenuPressed,
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Profile header
            ProfileHeader(
              user: user,
              planName: planName,
              isUploadingAvatar: _isUploadingAvatar,
              onAvatarTap: _showAvatarOptions,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Account section
            SettingsSection(
              title: context.l10n.account,
              children: [
                SettingsItem(
                  icon: Icons.person_outline,
                  title: context.l10n.personalData,
                  subtitle: context.l10n.nameEmailPhone,
                  onTap: () => _showComingSoon(context),
                ),
                SettingsItem(
                  icon: Icons.store_outlined,
                  title: context.l10n.atelierData,
                  subtitle: user?.tenant?.name ?? context.l10n.myAtelierHint,
                  onTap: () => _showComingSoon(context),
                ),
                SettingsItem(
                  icon: Icons.lock_outline,
                  title: context.l10n.changePassword,
                  subtitle: context.l10n.changeCurrentPassword,
                  onTap: () => _showChangePasswordDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Appearance section
            SettingsSection(
              title: context.l10n.appearance,
              children: [
                ThemeSelector(
                  currentTheme: themeMode,
                  onChanged: (mode) => ref.read(themeNotifierProvider.notifier).setThemeMode(mode),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Subscription section
            SettingsSection(
              title: context.l10n.subscription,
              children: [
                SubscriptionCard(
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
            ),
            const SizedBox(height: AppSpacing.lg),

            // Other section
            SettingsSection(
              title: context.l10n.other,
              children: [
                SettingsItem(
                  icon: Icons.notifications_outlined,
                  title: context.l10n.notifications,
                  subtitle: context.l10n.pushEmailSms,
                  onTap: () => _showComingSoon(context),
                ),
                SettingsItem(
                  icon: Icons.help_outline,
                  title: context.l10n.helpSupport,
                  subtitle: context.l10n.faqContactUs,
                  onTap: () => _showComingSoon(context),
                ),
                SettingsItem(
                  icon: Icons.info_outline,
                  title: context.l10n.aboutApp,
                  subtitle: context.l10n.version('1.0.0'),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Logout button
            _buildLogoutButton(context),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: Text(
          context.l10n.logoutAccount,
          style: const TextStyle(color: AppColors.error),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: AppColors.error.withOpacity(0.5)),
        ),
      ),
    );
  }

  void _showAvatarOptions() {
    final user = ref.read(currentUserProvider);
    final hasAvatar = user?.avatarUrl != null;

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
              _buildAvatarOption(
                icon: Icons.camera_alt,
                color: AppColors.primary,
                title: context.l10n.camera,
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(ImageSource.camera);
                },
              ),
              _buildAvatarOption(
                icon: Icons.photo_library,
                color: AppColors.secondary,
                title: context.l10n.gallery,
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(ImageSource.gallery);
                },
              ),
              if (hasAvatar)
                _buildAvatarOption(
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  title: context.l10n.delete,
                  onTap: () {
                    Navigator.pop(context);
                    _deleteAvatar();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOption({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingAvatar = true);

      final api = ref.read(apiServiceProvider);
      final updatedUser = await api.uploadAvatar(File(pickedFile.path));
      ref.read(authNotifierProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.avatarUpdated),
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

  Future<void> _deleteAvatar() async {
    try {
      setState(() => _isUploadingAvatar = true);

      final api = ref.read(apiServiceProvider);
      final updatedUser = await api.deleteAvatar();
      ref.read(authNotifierProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.avatarDeleted),
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

  void _showComingSoon(BuildContext context) {
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

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            Text(context.l10n.appTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.version('1.0.0'),
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.aboutAppDescription,
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.logoutTitle),
        content: Text(context.l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(authNotifierProvider.notifier).logout();
            },
            child: Text(
              context.l10n.logoutButton,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
