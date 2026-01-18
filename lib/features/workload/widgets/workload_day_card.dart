import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/load_indicator.dart';
import '../../../core/widgets/load_badge.dart';
import 'order_item.dart';
import 'employees_load_section.dart';

/// Expandable card displaying workload for a single day
class WorkloadDayCard extends StatelessWidget {
  final Map<String, dynamic> day;
  final String? selectedEmployeeId;

  const WorkloadDayCard({
    super.key,
    required this.day,
    this.selectedEmployeeId,
  });

  @override
  Widget build(BuildContext context) {
    final date = day['date'] as String? ?? '';
    final loadPercentage = day['loadPercentage'] ?? 0;
    final status = day['status'] as String? ?? 'light';
    final plannedHours = (day['plannedHours'] ?? 0).toDouble();
    final totalHours = (day['totalHours'] ?? 8).toDouble();
    final orders = (day['orders'] as List?) ?? [];
    final employees = (day['employees'] as List?) ?? [];

    final dateObj = DateTime.tryParse(date);
    final formattedDate = dateObj != null
        ? DateFormat('E, d MMM', 'ru').format(dateObj)
        : date;
    final isToday = dateObj != null &&
        DateFormat('yyyy-MM-dd').format(dateObj) ==
            DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: context.borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          leading: LoadIndicator(
            loadPercentage: loadPercentage,
            color: LoadBadge.fromStatus(status).color,
          ),
          title: _buildTitle(context, formattedDate, isToday, plannedHours, totalHours, orders.length),
          trailing: LoadBadge.fromStatus(status),
          children: [
            if (orders.isNotEmpty) ...[
              const Divider(),
              ...orders.map((order) => OrderItem(order: order)),
            ],
            if (employees.isNotEmpty && selectedEmployeeId == null) ...[
              const Divider(),
              EmployeesLoadSection(employees: employees),
            ],
            if (orders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'Нет запланированных заказов',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textTertiaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context,
    String formattedDate,
    bool isToday,
    double plannedHours,
    double totalHours,
    int ordersCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    formattedDate,
                    style: AppTypography.bodyLarge.copyWith(
                      color: context.textPrimaryColor,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Сегодня',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${plannedHours.toStringAsFixed(1)} / ${totalHours.toStringAsFixed(0)} ч • $ordersCount заказов',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
