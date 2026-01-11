import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/client_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/services/storage_service.dart';
import '../ateliers/my_ateliers_screen.dart';
import '../../auth/login_screen.dart';

class ClientAppShell extends StatefulWidget {
  const ClientAppShell({super.key});

  @override
  State<ClientAppShell> createState() => _ClientAppShellState();
}

class _ClientAppShellState extends State<ClientAppShell> {
  int _currentIndex = 0;
  ClientProvider? _clientProvider;

  final List<Widget> _screens = const [
    MyAteliersScreen(),
    _ClientProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to auth state changes
    final provider = context.read<ClientProvider>();
    if (_clientProvider != provider) {
      _clientProvider?.removeListener(_onAuthStateChanged);
      _clientProvider = provider;
      _clientProvider?.addListener(_onAuthStateChanged);
    }
  }

  @override
  void dispose() {
    _clientProvider?.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (_clientProvider?.isAuthenticated == false) {
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
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Ателье',
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

class _ClientProfileScreen extends StatelessWidget {
  const _ClientProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<ClientProvider>(
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
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name.substring(0, 1).toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user.name,
                      style: AppTypography.h3,
                    ),
                    if (user.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.email!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                    if (user.phone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.phone!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

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
                onPressed: () async {
                  await provider.logout();
                  await StorageService().clearAppMode();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Выйти'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          );
        },
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
