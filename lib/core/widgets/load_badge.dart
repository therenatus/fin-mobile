import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A badge showing load status with color coding
class LoadBadge extends StatelessWidget {
  final String label;
  final Color color;

  const LoadBadge({
    super.key,
    required this.label,
    required this.color,
  });

  /// Factory constructor for workload status
  factory LoadBadge.fromStatus(String status) {
    return LoadBadge(
      label: _getStatusLabel(status),
      color: _getStatusColor(status),
    );
  }

  static String _getStatusLabel(String status) {
    switch (status) {
      case 'light':
        return 'Свободно';
      case 'normal':
        return 'Норма';
      case 'heavy':
        return 'Загружен';
      case 'overload':
        return 'Перегруз';
      default:
        return '';
    }
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'light':
        return AppColors.success;
      case 'normal':
        return AppColors.info;
      case 'heavy':
        return AppColors.warning;
      case 'overload':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
