import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/widgets/forms/forms.dart';
import '../../shell/app_shell.dart';

class ManagerLoginForm extends ConsumerStatefulWidget {
  final VoidCallback onError;

  const ManagerLoginForm({super.key, required this.onError});

  @override
  ConsumerState<ManagerLoginForm> createState() => _ManagerLoginFormState();
}

class _ManagerLoginFormState extends ConsumerState<ManagerLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final storage = ref.read(storageServiceProvider);

    bool success;
    if (_isRegister) {
      success = await authNotifier.register(
        _emailController.text.trim(),
        _passwordController.text,
        _businessNameController.text.trim(),
      );
    } else {
      success = await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success && mounted) {
      await storage.saveAppMode('manager');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppShell()),
      );
    } else if (mounted) {
      widget.onError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormHeader(
              title: _isRegister
                  ? context.l10n.registerAtelier
                  : context.l10n.loginManager,
              subtitle: context.l10n.fullBusinessControl,
              icon: Icons.business_center,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.lg),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _isRegister
                  ? Column(
                      children: [
                        LoginTextField(
                          controller: _businessNameController,
                          label: context.l10n.atelierName,
                          hint: context.l10n.myAtelierHint,
                          icon: Icons.store_outlined,
                          validator: (v) =>
                              v?.isEmpty == true ? context.l10n.enterName : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

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
                if (v!.length < 6) return context.l10n.passwordTooShort;
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            SubmitButton(
              onPressed: isLoading ? null : _submit,
              isLoading: isLoading,
              label: _isRegister
                  ? context.l10n.createAccount
                  : context.l10n.login,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),

            AuthToggle(
              isRegister: _isRegister,
              isLoading: isLoading,
              onTap: () => setState(() => _isRegister = !_isRegister),
              loginText: context.l10n.login,
              registerText: context.l10n.registration,
              switchToLoginText: context.l10n.alreadyHaveAccount,
              switchToRegisterText: context.l10n.noAccount,
            ),
          ],
        ),
      ),
    );
  }
}
