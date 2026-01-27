import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

class ForecastCard extends StatelessWidget {
  final String title;
  final Forecast? forecast;
  final IconData icon;
  final Color color;
  final String Function(double) formatValue;

  const ForecastCard({
    super.key,
    required this.title,
    required this.forecast,
    required this.icon,
    required this.color,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [AppShadows.sm],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final trendIcon = forecast!.isUpTrend
        ? Icons.trending_up
        : forecast!.isDownTrend
            ? Icons.trending_down
            : Icons.trending_flat;

    final trendColor = forecast!.isUpTrend
        ? AppColors.success
        : forecast!.isDownTrend
            ? AppColors.error
            : context.textSecondaryColor;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [AppShadows.sm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trendColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, size: 14, color: trendColor),
                    const SizedBox(width: 2),
                    Text(
                      '${forecast!.trendPercentage > 0 ? '+' : ''}${forecast!.trendPercentage.toStringAsFixed(0)}%',
                      style: AppTypography.labelSmall.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            formatValue(forecast!.predictedValue),
            style: AppTypography.h4.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${forecast!.confidenceInterval.low.toStringAsFixed(0)} - ${forecast!.confidenceInterval.high.toStringAsFixed(0)}',
            style: AppTypography.labelSmall.copyWith(
              color: context.textTertiaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
