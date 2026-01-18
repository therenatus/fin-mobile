import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/widgets/forms/forms.dart';
import '../../employee_mode/shell/employee_app_shell.dart';

class EmployeeLoginForm extends ConsumerStatefulWidget {
  final VoidCallback onError;

  const EmployeeLoginForm({super.key, required this.onError});

  @override
  ConsumerState<EmployeeLoginForm> createState() => _EmployeeLoginFormState();
}

class _EmployeeLoginFormState extends ConsumerState<EmployeeLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final employeeAuthNotifier = ref.read(employeeAuthNotifierProvider.notifier);
    final storage = ref.read(storageServiceProvider);

    final success = await employeeAuthNotifier.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      await storage.saveAppMode('employee');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EmployeeAppShell()),
      );
    } else if (mounted) {
      widget.onError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeAuthState = ref.watch(employeeAuthNotifierProvider);
    final isLoading = employeeAuthState.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormHeader(
              title: context.l10n.loginEmployee,
              subtitle: context.l10n.workAndEarningsTracking,
              icon: Icons.badge,
              color: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.lg),

            LoginTextField(
              controller: _emailController,
              label: context.l10n.email,
              hint: context.l10n.exampleEmailHint,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty == true) return context.l10n.emailRequired;
                if (!v!.contains('@')) return context.l10n.emailInvalid;
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            PasswordField(
              controller: _passwordController,
              label: context.l10n.password,
              validator: (v) {
                if (v?.isEmpty == true) return context.l10n.passwordRequired;
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            SubmitButton(
              onPressed: isLoading ? null : _submit,
              isLoading: isLoading,
              label: context.l10n.login,
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
                      context.l10n.credentialsFromManager,
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
}
