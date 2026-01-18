import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'login_text_field.dart';

/// Password field with visibility toggle
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  void _toggleVisibility() {
    HapticFeedback.selectionClick();
    setState(() => _obscurePassword = !_obscurePassword);
  }

  @override
  Widget build(BuildContext context) {
    return LoginTextField(
      controller: widget.controller,
      label: widget.label,
      hint: '••••••••',
      icon: Icons.lock_outlined,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            key: ValueKey(_obscurePassword),
            color: context.textTertiaryColor,
            size: 22,
          ),
        ),
        onPressed: _toggleVisibility,
      ),
      validator: widget.validator,
    );
  }
}
