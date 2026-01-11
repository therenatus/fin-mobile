import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/client_provider.dart';
import '../../core/providers/employee_provider.dart';
import '../../core/services/storage_service.dart';
import '../shell/app_shell.dart';
import '../client_mode/shell/client_app_shell.dart';
import '../employee_mode/shell/employee_app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  // Manager form
  final _managerFormKey = GlobalKey<FormState>();
  final _managerEmailController = TextEditingController();
  final _managerPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  bool _isManagerRegister = false;
  bool _obscureManagerPassword = true;

  // Client form
  final _clientFormKey = GlobalKey<FormState>();
  final _clientEmailController = TextEditingController();
  final _clientPasswordController = TextEditingController();
  final _clientNameController = TextEditingController();
  bool _isClientRegister = false;
  bool _obscureClientPassword = true;

  // Employee form (login only, no registration)
  final _employeeFormKey = GlobalKey<FormState>();
  final _employeeEmailController = TextEditingController();
  final _employeePasswordController = TextEditingController();
  bool _obscureEmployeePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _currentTabIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _managerEmailController.dispose();
    _managerPasswordController.dispose();
    _businessNameController.dispose();
    _clientEmailController.dispose();
    _clientPasswordController.dispose();
    _clientNameController.dispose();
    _employeeEmailController.dispose();
    _employeePasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitManager() async {
    if (!_managerFormKey.currentState!.validate()) return;

    final appProvider = context.read<AppProvider>();
    final storage = StorageService();

    bool success;
    if (_isManagerRegister) {
      success = await appProvider.register(
        _managerEmailController.text.trim(),
        _managerPasswordController.text,
        _businessNameController.text.trim(),
      );
    } else {
      success = await appProvider.login(
        _managerEmailController.text.trim(),
        _managerPasswordController.text,
      );
    }

    if (success && mounted) {
      await storage.saveAppMode('manager');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppShell()),
      );
    } else if (mounted) {
      _showError(appProvider.error ?? 'Произошла ошибка');
    }
  }

  Future<void> _submitClient() async {
    if (!_clientFormKey.currentState!.validate()) return;

    final clientProvider = context.read<ClientProvider>();
    final storage = StorageService();

    bool success;
    if (_isClientRegister) {
      success = await clientProvider.register(
        email: _clientEmailController.text.trim(),
        password: _clientPasswordController.text,
        name: _clientNameController.text.trim(),
      );
    } else {
      success = await clientProvider.login(
        email: _clientEmailController.text.trim(),
        password: _clientPasswordController.text,
      );
    }

    if (success && mounted) {
      await storage.saveAppMode('client');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClientAppShell()),
      );
    } else if (mounted) {
      _showError(clientProvider.error ?? 'Произошла ошибка');
    }
  }

  Future<void> _submitEmployee() async {
    if (!_employeeFormKey.currentState!.validate()) return;

    final employeeProvider = context.read<EmployeeProvider>();
    final storage = StorageService();

    final success = await employeeProvider.login(
      email: _employeeEmailController.text.trim(),
      password: _employeePasswordController.text,
    );

    if (success && mounted) {
      await storage.saveAppMode('employee');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EmployeeAppShell()),
      );
    } else if (mounted) {
      _showError(employeeProvider.error ?? 'Произошла ошибка');
    }
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Tab data with icons and colors
  static const _tabData = [
    (icon: Icons.business_center_outlined, label: 'Менеджер', color: AppColors.primary),
    (icon: Icons.shopping_bag_outlined, label: 'Заказчик', color: AppColors.secondary),
    (icon: Icons.badge_outlined, label: 'Сотрудник', color: AppColors.accent),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    // Adaptive gradient for dark/light theme
    final gradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          )
        : AppColors.primaryGradient;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Logo with animation
                _buildAnimatedLogo(),
                const SizedBox(height: 20),
                // Main card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xl),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 80 : 40),
                          blurRadius: 30,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        // Custom tab bar
                        _buildCustomTabBar(),
                        // Tab content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildManagerForm(),
                              _buildClientForm(),
                              _buildEmployeeForm(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Column(
        children: [
          // Logo container with glow effect
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withAlpha(60),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.content_cut,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'AteliePro',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Управление ателье',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withAlpha(180),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: List.generate(3, (index) {
            final isSelected = _currentTabIndex == index;
            final data = _tabData[index];

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _tabController.animateTo(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? data.color : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: data.color.withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        data.icon,
                        size: 20,
                        color: isSelected
                            ? Colors.white
                            : context.textSecondaryColor,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildManagerForm() {
    final appProvider = context.watch<AppProvider>();
    final isLoading = appProvider.state == AppState.loading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _managerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFormHeader(
              title: _isManagerRegister ? 'Регистрация ателье' : 'Вход для менеджера',
              subtitle: 'Полный контроль над бизнесом',
              icon: Icons.business_center,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.lg),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _isManagerRegister
                  ? Column(
                      children: [
                        _buildTextField(
                          controller: _businessNameController,
                          label: 'Название ателье',
                          hint: 'Моё ателье',
                          icon: Icons.store_outlined,
                          validator: (v) =>
                              v?.isEmpty == true ? 'Введите название' : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            _buildTextField(
              controller: _managerEmailController,
              label: 'Email',
              hint: 'example@mail.ru',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty == true) return 'Введите email';
                if (!v!.contains('@')) return 'Некорректный email';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _buildTextField(
              controller: _managerPasswordController,
              label: 'Пароль',
              hint: '••••••••',
              icon: Icons.lock_outlined,
              obscureText: _obscureManagerPassword,
              suffixIcon: _buildPasswordToggle(
                isObscure: _obscureManagerPassword,
                onTap: () => setState(
                    () => _obscureManagerPassword = !_obscureManagerPassword),
              ),
              validator: (v) {
                if (v?.isEmpty == true) return 'Введите пароль';
                if (v!.length < 6) return 'Минимум 6 символов';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            _buildSubmitButton(
              onPressed: isLoading ? null : _submitManager,
              isLoading: isLoading,
              label: _isManagerRegister ? 'Создать аккаунт' : 'Войти',
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),

            _buildAuthToggle(
              isRegister: _isManagerRegister,
              isLoading: isLoading,
              onTap: () => setState(() => _isManagerRegister = !_isManagerRegister),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientForm() {
    final clientProvider = context.watch<ClientProvider>();
    final isLoading = clientProvider.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _clientFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFormHeader(
              title: _isClientRegister ? 'Регистрация' : 'Вход для заказчика',
              subtitle: 'Отслеживание ваших заказов',
              icon: Icons.shopping_bag,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.lg),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _isClientRegister
                  ? Column(
                      children: [
                        _buildTextField(
                          controller: _clientNameController,
                          label: 'Ваше имя',
                          hint: 'Иван Иванов',
                          icon: Icons.person_outlined,
                          validator: (v) =>
                              v?.isEmpty == true ? 'Введите имя' : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            _buildTextField(
              controller: _clientEmailController,
              label: 'Email',
              hint: 'example@mail.ru',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty == true) return 'Введите email';
                if (!v!.contains('@')) return 'Некорректный email';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _buildTextField(
              controller: _clientPasswordController,
              label: 'Пароль',
              hint: '••••••••',
              icon: Icons.lock_outlined,
              obscureText: _obscureClientPassword,
              suffixIcon: _buildPasswordToggle(
                isObscure: _obscureClientPassword,
                onTap: () => setState(
                    () => _obscureClientPassword = !_obscureClientPassword),
              ),
              validator: (v) {
                if (v?.isEmpty == true) return 'Введите пароль';
                if (v!.length < 6) return 'Минимум 6 символов';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            _buildSubmitButton(
              onPressed: isLoading ? null : _submitClient,
              isLoading: isLoading,
              label: _isClientRegister ? 'Создать аккаунт' : 'Войти',
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.md),

            _buildAuthToggle(
              isRegister: _isClientRegister,
              isLoading: isLoading,
              onTap: () => setState(() => _isClientRegister = !_isClientRegister),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeForm() {
    final employeeProvider = context.watch<EmployeeProvider>();
    final isLoading = employeeProvider.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _employeeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFormHeader(
              title: 'Вход для сотрудника',
              subtitle: 'Учёт работы и заработка',
              icon: Icons.badge,
              color: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildTextField(
              controller: _employeeEmailController,
              label: 'Email',
              hint: 'example@mail.ru',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty == true) return 'Введите email';
                if (!v!.contains('@')) return 'Некорректный email';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _buildTextField(
              controller: _employeePasswordController,
              label: 'Пароль',
              hint: '••••••••',
              icon: Icons.lock_outlined,
              obscureText: _obscureEmployeePassword,
              suffixIcon: _buildPasswordToggle(
                isObscure: _obscureEmployeePassword,
                onTap: () => setState(
                    () => _obscureEmployeePassword = !_obscureEmployeePassword),
              ),
              validator: (v) {
                if (v?.isEmpty == true) return 'Введите пароль';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            _buildSubmitButton(
              onPressed: isLoading ? null : _submitEmployee,
              isLoading: isLoading,
              label: 'Войти',
              color: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Info card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha(context.isDark ? 30 : 20),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.accent.withAlpha(40),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Учётные данные выдаёт менеджер ателье',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.isDark
                            ? AppColors.accent
                            : AppColors.accent.withAlpha(200),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withAlpha(context.isDark ? 40 : 25),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: AppTypography.h3.copyWith(
            color: context.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: context.textSecondaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: AppTypography.bodyLarge.copyWith(
            color: context.textPrimaryColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: context.textTertiaryColor,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(icon, color: context.textTertiaryColor, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: context.surfaceVariantColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: context.borderColor.withAlpha(50),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordToggle({
    required bool isObscure,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          key: ValueKey(isObscure),
          color: context.textTertiaryColor,
          size: 22,
        ),
      ),
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }

  Widget _buildSubmitButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withAlpha(150),
          elevation: 0,
          shadowColor: color.withAlpha(100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: ValueKey(label),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAuthToggle({
    required bool isRegister,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isRegister ? 'Уже есть аккаунт?' : 'Нет аккаунта?',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            isRegister ? 'Войти' : 'Регистрация',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
