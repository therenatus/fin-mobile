import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/material.dart' as mat;
import 'stock_indicator.dart';

class MaterialCard extends StatelessWidget {
  final mat.Material material;
  final VoidCallback? onTap;

  const MaterialCard({
    super.key,
    required this.material,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: material.computedIsLowStock
              ? AppColors.error.withOpacity(0.5)
              : context.borderColor,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Material image/icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: material.color != null
                      ? _parseColor(material.color!)
                      : context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: material.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Image.network(
                          material.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.inventory_2_outlined,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.inventory_2_outlined,
                        color: context.textSecondaryColor,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Material info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            material.name,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StockIndicator(
                          quantity: material.quantity,
                          minStockLevel: material.minStockLevel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          material.sku,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                        if (material.category != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              material.category!.name,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          material.formattedQuantity,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (material.reservedQty > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${material.reservedQty.toStringAsFixed(0)} резерв)',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (material.costPrice != null)
                          Text(
                            '${material.costPrice!.toStringAsFixed(0)} ₽',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
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

  Color _parseColor(String colorName) {
    final lowerName = colorName.toLowerCase();
    final colorMap = {
      'красный': Colors.red.shade100,
      'синий': Colors.blue.shade100,
      'зелёный': Colors.green.shade100,
      'зеленый': Colors.green.shade100,
      'жёлтый': Colors.yellow.shade100,
      'желтый': Colors.yellow.shade100,
      'чёрный': Colors.grey.shade400,
      'черный': Colors.grey.shade400,
      'белый': Colors.grey.shade100,
      'серый': Colors.grey.shade200,
      'коричневый': Colors.brown.shade100,
      'бежевый': Colors.amber.shade50,
      'розовый': Colors.pink.shade100,
      'фиолетовый': Colors.purple.shade100,
      'оранжевый': Colors.orange.shade100,
      'голубой': Colors.lightBlue.shade100,
    };
    return colorMap[lowerName] ?? Colors.grey.shade100;
  }
}

class MaterialCardSkeleton extends StatelessWidget {
  const MaterialCardSkeleton({super.key});

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
            _shimmer(context, width: 56, height: 56),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmer(context, width: 140, height: 16),
                  const SizedBox(height: 6),
                  _shimmer(context, width: 80, height: 12),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _shimmer(context, width: 60, height: 14),
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
