import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'stat_item.dart';

/// Card showing workload summary statistics
class WorkloadSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final int days;

  const WorkloadSummaryCard({
    super.key,
    required this.summary,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final totalPlanned = (summary['totalPlannedHours'] ?? 0).toDouble();
    final totalCapacity = (summary['totalCapacity'] ?? 1).toDouble();
    final averageLoad = summary['averageLoad'] ?? 0;
    final overloadedDays = summary['overloadedDays'] ?? 0;
    final employeesCount = summary['employeesCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Сводка на $days дней',
                style: AppTypography.h4.copyWith(color: context.textPrimaryColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: StatItem(
                  label: 'Запланировано',
                  value: '${totalPlanned.toStringAsFixed(1)} ч',
                  icon: Icons.schedule,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: StatItem(
                  label: 'Ёмкость',
                  value: '${totalCapacity.toStringAsFixed(0)} ч',
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: StatItem(
                  label: 'Ср. загрузка',
                  value: '$averageLoad%',
                  icon: Icons.speed,
                  color: _getLoadColor(averageLoad),
                ),
              ),
              Expanded(
                child: StatItem(
                  label: 'Перегруз дней',
                  value: '$overloadedDays',
                  icon: Icons.warning_amber,
                  color: overloadedDays > 0 ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
          if (employeesCount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Сотрудников: $employeesCount',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getLoadColor(int load) {
    if (load < 50) return AppColors.success;
    if (load < 80) return AppColors.info;
    if (load < 100) return AppColors.warning;
    return AppColors.error;
  }
}
