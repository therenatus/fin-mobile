import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Order item displayed within a workload day card
class OrderItem extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final clientName = order['clientName'] as String? ?? '';
    final modelName = order['modelName'] as String? ?? '';
    final quantity = order['quantity'] ?? 0;
    final estimatedHours = (order['estimatedHours'] ?? 0).toDouble();
    final isOverdue = order['isOverdue'] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isOverdue ? AppColors.error : AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$modelName • $quantity шт',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${estimatedHours.toStringAsFixed(1)} ч',
                style: AppTypography.labelMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isOverdue)
                Text(
                  'Просрочен',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
