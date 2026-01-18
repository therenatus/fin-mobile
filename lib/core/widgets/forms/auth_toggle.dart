import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Toggle button for switching between login and register modes
class AuthToggle extends StatelessWidget {
  final bool isRegister;
  final bool isLoading;
  final VoidCallback onTap;
  final String loginText;
  final String registerText;
  final String switchToLoginText;
  final String switchToRegisterText;

  const AuthToggle({
    super.key,
    required this.isRegister,
    required this.isLoading,
    required this.onTap,
    required this.loginText,
    required this.registerText,
    required this.switchToLoginText,
    required this.switchToRegisterText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isRegister ? switchToLoginText : switchToRegisterText,
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
            isRegister ? loginText : registerText,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
