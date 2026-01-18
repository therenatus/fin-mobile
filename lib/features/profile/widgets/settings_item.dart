import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Settings list item widget with icon, title, and subtitle
class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsItem({
    super.key,
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
