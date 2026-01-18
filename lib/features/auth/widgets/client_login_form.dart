import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/widgets/forms/forms.dart';
import '../../client_mode/shell/client_app_shell.dart';

class ClientLoginForm extends ConsumerStatefulWidget {
  final VoidCallback onError;

  const ClientLoginForm({super.key, required this.onError});

  @override
  ConsumerState<ClientLoginForm> createState() => _ClientLoginFormState();
}

class _ClientLoginFormState extends ConsumerState<ClientLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final clientAuthNotifier = ref.read(clientAuthNotifierProvider.notifier);
    final storage = ref.read(storageServiceProvider);

    bool success;
    if (_isRegister) {
      success = await clientAuthNotifier.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
    } else {
      success = await clientAuthNotifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (success && mounted) {
      await storage.saveAppMode('client');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClientAppShell()),
      );
    } else if (mounted) {
      widget.onError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientAuthState = ref.watch(clientAuthNotifierProvider);
    final isLoading = clientAuthState.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormHeader(
              title: _isRegister
                  ? context.l10n.registration
                  : context.l10n.loginClient,
              subtitle: context.l10n.trackYourOrders,
              icon: Icons.shopping_bag,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.lg),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _isRegister
                  ? Column(
                      children: [
                        LoginTextField(
                          controller: _nameController,
                          label: context.l10n.yourName,
                          hint: context.l10n.exampleNameHint,
                          icon: Icons.person_outlined,
                          validator: (v) =>
                              v?.isEmpty == true ? context.l10n.enterYourName : null,
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
              color: AppColors.secondary,
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
