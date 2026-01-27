import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/bom.dart';

/// Карточка с итогами себестоимости BOM
class BomSummaryCard extends StatelessWidget {
  final Bom bom;
  final VoidCallback? onRecalculate;
  final bool isRecalculating;

  const BomSummaryCard({
    super.key,
    required this.bom,
    this.onRecalculate,
    this.isRecalculating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.calculate_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Себестоимость',
                        style: AppTypography.labelLarge.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                      Text(
                        'Версия ${bom.version}',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRecalculate != null)
                  isRecalculating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          onPressed: onRecalculate,
                          icon: const Icon(Icons.refresh, size: 20),
                          tooltip: 'Пересчитать',
                          color: AppColors.primary,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),

            // Cost breakdown
            Row(
              children: [
                Expanded(
                  child: _CostColumn(
                    label: 'Материалы',
                    value: bom.formattedMaterialCost,
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: context.borderColor,
                ),
                Expanded(
                  child: _CostColumn(
                    label: 'Работа',
                    value: bom.formattedLaborCost,
                    icon: Icons.engineering_outlined,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: context.borderColor,
                ),
                Expanded(
                  child: _CostColumn(
                    label: 'Итого',
                    value: bom.formattedTotalCost,
                    icon: Icons.summarize_outlined,
                    isPrimary: true,
                  ),
                ),
              ],
            ),

            // Items and operations count
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: context.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${bom.items.length} материалов',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPrimary;

  const _CostColumn({
    required this.label,
    required this.value,
    required this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: isPrimary ? AppColors.primary : context.textSecondaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: isPrimary ? AppColors.primary : context.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}
