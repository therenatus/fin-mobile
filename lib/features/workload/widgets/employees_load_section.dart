import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Section showing employee load within a day card
class EmployeesLoadSection extends StatelessWidget {
  final List employees;

  const EmployeesLoadSection({super.key, required this.employees});

  @override
  Widget build(BuildContext context) {
    final activeEmployees = employees
        .where((e) => (e['plannedHours'] ?? 0) > 0)
        .toList();

    if (activeEmployees.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Загрузка сотрудников',
          style: AppTypography.labelMedium.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 8),
        ...activeEmployees.map((emp) {
          final name = emp['name'] as String? ?? '';
          final load = emp['load'] ?? 0;
          final plannedHours = (emp['plannedHours'] ?? 0).toDouble();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    name,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textPrimaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: load / 100,
                      backgroundColor: context.surfaceVariantColor,
                      valueColor: AlwaysStoppedAnimation(_getLoadColor(load)),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${plannedHours.toStringAsFixed(1)} ч',
                    textAlign: TextAlign.right,
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getLoadColor(int load) {
    if (load < 50) return AppColors.success;
    if (load < 80) return AppColors.info;
    if (load < 100) return AppColors.warning;
    return AppColors.error;
  }
}
