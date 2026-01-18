import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import 'order_status_chip.dart';

/// Bottom sheet for selecting order status
class StatusPickerSheet extends StatelessWidget {
  final OrderStatus currentStatus;
  final ValueChanged<OrderStatus> onStatusSelected;

  const StatusPickerSheet({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  static void show(
    BuildContext context, {
    required OrderStatus currentStatus,
    required ValueChanged<OrderStatus> onStatusSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => StatusPickerSheet(
        currentStatus: currentStatus,
        onStatusSelected: onStatusSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Выберите статус', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          ...OrderStatus.values.map((status) {
            final isSelected = currentStatus == status;
            return ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: OrderStatusChip.getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(OrderStatusChip.getStatusLabel(status)),
              trailing: isSelected
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: isSelected
                  ? null
                  : () {
                      Navigator.pop(context);
                      onStatusSelected(status);
                    },
            );
          }),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
