import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/bom.dart';

/// Карточка материала в BOM
class BomItemCard extends StatelessWidget {
  final BomItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const BomItemCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: context.borderColor),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Material icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.info,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Material info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.material?.name ?? 'Материал',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: 4,
                      children: [
                        _InfoChip(
                          icon: Icons.straighten,
                          text: '${_formatQuantity(item.quantity)} ${item.material?.materialUnit.label ?? ''}',
                        ),
                        _InfoChip(
                          icon: Icons.delete_outline,
                          text: '${item.wastePct.toStringAsFixed(0)}%',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cost and actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.calculatedUnitCost.toStringAsFixed(0)} сом',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  if (item.material?.costPrice != null)
                    Text(
                      '${item.material!.costPrice!.toStringAsFixed(0)} сом/ед',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                ],
              ),

              if (showActions && onDelete != null) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  tooltip: 'Удалить',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatQuantity(double qty) {
    if (qty == qty.truncateToDouble()) {
      return qty.toStringAsFixed(0);
    }
    return qty.toStringAsFixed(2);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? context.textSecondaryColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: chipColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: chipColor,
          ),
        ),
      ],
    );
  }
}
