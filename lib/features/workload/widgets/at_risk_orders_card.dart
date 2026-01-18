import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'at_risk_order_item.dart';

/// Card showing orders that are at risk (overdue)
class AtRiskOrdersCard extends StatelessWidget {
  final List<Map<String, dynamic>> atRiskOrders;
  final void Function(String orderId) onOrderTap;

  const AtRiskOrdersCard({
    super.key,
    required this.atRiskOrders,
    required this.onOrderTap,
  });

  /// Extract at-risk orders from calendar data
  static List<Map<String, dynamic>> extractFromCalendar(List calendar) {
    final atRiskOrders = <Map<String, dynamic>>[];
    final seenIds = <String>{};

    for (final day in calendar) {
      final orders = (day['orders'] as List?) ?? [];
      for (final order in orders) {
        final orderId = order['id'] as String?;
        final isOverdue = order['isOverdue'] as bool? ?? false;
        if (orderId != null && isOverdue && !seenIds.contains(orderId)) {
          seenIds.add(orderId);
          atRiskOrders.add(Map<String, dynamic>.from(order));
        }
      }
    }

    return atRiskOrders;
  }

  @override
  Widget build(BuildContext context) {
    if (atRiskOrders.isEmpty) {
      return _buildAllOnScheduleCard(context);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Заказы под угрозой',
                style: AppTypography.h4.copyWith(color: AppColors.error),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${atRiskOrders.length}',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...atRiskOrders.take(5).map((order) => AtRiskOrderItem(
                order: order,
                onTap: () {
                  final orderId = order['id'] as String?;
                  if (orderId != null) onOrderTap(orderId);
                },
              )),
          if (atRiskOrders.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ещё ${atRiskOrders.length - 5} заказов',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAllOnScheduleCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Все заказы в графике',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  'Нет просроченных заказов',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
