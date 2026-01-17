import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/supplier.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback? onTap;

  const SupplierCard({
    super.key,
    required this.supplier,
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
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text(
                    supplier.initials,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            supplier.name,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!supplier.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.surfaceVariantColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Неактивен',
                              style: AppTypography.labelSmall.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (supplier.contactName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        supplier.contactName!,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (supplier.phone != null) ...[
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: context.textTertiaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            supplier.phone!,
                            style: AppTypography.labelSmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ] else if (supplier.email != null) ...[
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: context.textTertiaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            supplier.email!,
                            style: AppTypography.labelSmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '${supplier.materialsCount} материалов',
                          style: AppTypography.labelSmall.copyWith(
                            color: context.textTertiaryColor,
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
}

class SupplierCardSkeleton extends StatelessWidget {
  const SupplierCardSkeleton({super.key});

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
            _shimmer(context, width: 48, height: 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmer(context, width: 140, height: 16),
                  const SizedBox(height: 6),
                  _shimmer(context, width: 100, height: 12),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _shimmer(context, width: 100, height: 12),
                      const Spacer(),
                      _shimmer(context, width: 70, height: 12),
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
