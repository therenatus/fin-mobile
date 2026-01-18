import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/bom.dart';
import '../../../core/riverpod/providers.dart';

/// Карточка операции в BOM
class BomOperationCard extends ConsumerWidget {
  final BomOperation operation;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const BomOperationCard({
    super.key,
    required this.operation,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              // Sequence number
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Center(
                  child: Text(
                    '${operation.sequence}',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Operation info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operation.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.schedule,
                          text: operation.formattedTime,
                        ),
                        if (operation.requiredRole != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          _InfoChip(
                            icon: Icons.person_outline,
                            text: _getRoleLabel(ref, operation.requiredRole!),
                            color: AppColors.info,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Labor cost
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${operation.calculatedLaborCost.toStringAsFixed(0)} ₽',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                  if (operation.hourlyRate != null)
                    Text(
                      '${operation.hourlyRate!.toStringAsFixed(0)} ₽/ч',
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

  String _getRoleLabel(WidgetRef ref, String role) {
    return ref.read(dashboardNotifierProvider).getRoleLabel(role);
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
