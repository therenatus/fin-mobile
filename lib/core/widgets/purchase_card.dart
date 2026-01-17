import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/purchase.dart';

class PurchaseCard extends StatelessWidget {
  final Purchase purchase;
  final VoidCallback? onTap;

  const PurchaseCard({
    super.key,
    required this.purchase,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(purchase.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: _getStatusColor(purchase.status),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchase.number,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          purchase.supplier?.name ?? 'Без поставщика',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: purchase.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: context.textTertiaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${purchase.itemsCount} позиций',
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (purchase.orderDate != null) ...[
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: context.textTertiaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('d MMM yyyy', 'ru').format(purchase.orderDate!),
                      style: AppTypography.labelSmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    purchase.formattedTotalAmount,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.draft:
        return AppColors.secondary;
      case PurchaseStatus.ordered:
        return AppColors.info;
      case PurchaseStatus.partial:
        return AppColors.warning;
      case PurchaseStatus.received:
        return AppColors.success;
      case PurchaseStatus.cancelled:
        return AppColors.error;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final PurchaseStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case PurchaseStatus.draft:
        color = AppColors.secondary;
        break;
      case PurchaseStatus.ordered:
        color = AppColors.info;
        break;
      case PurchaseStatus.partial:
        color = AppColors.warning;
        break;
      case PurchaseStatus.received:
        color = AppColors.success;
        break;
      case PurchaseStatus.cancelled:
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

class PurchaseCardSkeleton extends StatelessWidget {
  const PurchaseCardSkeleton({super.key});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _shimmer(context, width: 40, height: 40),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmer(context, width: 100, height: 16),
                      const SizedBox(height: 6),
                      _shimmer(context, width: 80, height: 12),
                    ],
                  ),
                ),
                _shimmer(context, width: 70, height: 24),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Divider(height: 1, color: context.borderColor),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _shimmer(context, width: 80, height: 12),
                const Spacer(),
                _shimmer(context, width: 60, height: 14),
              ],
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
