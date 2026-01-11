import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = order.isOverdue;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isOverdue ? AppColors.error.withOpacity(0.5) : context.borderColor,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Model image/icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: order.model?.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Image.network(
                          order.model!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.checkroom,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.checkroom,
                        color: context.textSecondaryColor,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Order info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.model?.name ?? 'Заказ #${order.id.substring(0, 6)}',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.client?.name ?? 'Заказчик',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StatusBadge(status: order.status),
                        const SizedBox(width: AppSpacing.sm),
                        if (order.dueDate != null) ...[
                          Icon(
                            isOverdue ? Icons.warning_amber_rounded : Icons.schedule,
                            size: 14,
                            color: isOverdue ? AppColors.error : context.textTertiaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDueDate(order.dueDate!),
                            style: AppTypography.labelSmall.copyWith(
                              color: isOverdue ? AppColors.error : context.textTertiaryColor,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '${order.quantity} шт.',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff < 0) {
      return 'Просрочен';
    } else if (diff == 0) {
      return 'Сегодня';
    } else if (diff == 1) {
      return 'Завтра';
    } else if (diff < 7) {
      return 'Через $diff дн.';
    } else {
      return DateFormat('d MMM', 'ru').format(date);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        break;
      case OrderStatus.inProgress:
        color = AppColors.info;
        break;
      case OrderStatus.completed:
        color = AppColors.success;
        break;
      case OrderStatus.cancelled:
        color = context.textTertiaryColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status.label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            _shimmer(context, width: 60, height: 60),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmer(context, width: 150, height: 16),
                  const SizedBox(height: 6),
                  _shimmer(context, width: 100, height: 12),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _shimmer(context, width: 60, height: 20),
                      const Spacer(),
                      _shimmer(context, width: 50, height: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}
