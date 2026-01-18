import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

/// Section with action buttons for order management
class OrderActionsSection extends StatelessWidget {
  final Order order;
  final bool isUpdatingStatus;
  final VoidCallback onAcceptOrder;
  final VoidCallback onChangeStatus;
  final VoidCallback onCompleteOrder;

  const OrderActionsSection({
    super.key,
    required this.order,
    required this.isUpdatingStatus,
    required this.onAcceptOrder,
    required this.onChangeStatus,
    required this.onCompleteOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (order.status == OrderStatus.pending) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isUpdatingStatus ? null : onAcceptOrder,
              icon: isUpdatingStatus
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.assignment_turned_in_outlined),
              label: const Text('Принять заказ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isUpdatingStatus ? null : onChangeStatus,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Изменить статус'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (order.status == OrderStatus.inProgress) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUpdatingStatus ? null : onCompleteOrder,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Завершить'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
