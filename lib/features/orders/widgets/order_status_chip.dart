import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

/// Status chip displaying order status with color coding
class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _getStatusData(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getStatusData(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return (AppColors.warning, 'Ожидает');
      case OrderStatus.inProgress:
        return (AppColors.info, 'В работе');
      case OrderStatus.completed:
        return (AppColors.success, 'Готово');
      case OrderStatus.cancelled:
        return (AppColors.error, 'Отменён');
    }
  }

  static String getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Ожидает';
      case OrderStatus.inProgress:
        return 'В работе';
      case OrderStatus.completed:
        return 'Готово';
      case OrderStatus.cancelled:
        return 'Отменён';
    }
  }

  static Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.inProgress:
        return AppColors.info;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}
