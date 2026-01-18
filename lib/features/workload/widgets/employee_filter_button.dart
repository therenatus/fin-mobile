import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// Button for filtering workload by employee
class EmployeeFilterButton extends StatelessWidget {
  final List employees;
  final String? selectedEmployeeId;
  final ValueChanged<String?> onEmployeeSelected;
  final VoidCallback onShowSelector;

  const EmployeeFilterButton({
    super.key,
    required this.employees,
    required this.selectedEmployeeId,
    required this.onEmployeeSelected,
    required this.onShowSelector,
  });

  @override
  Widget build(BuildContext context) {
    final selectedEmployee = selectedEmployeeId != null
        ? employees.firstWhere(
            (e) => e['id'] == selectedEmployeeId,
            orElse: () => null,
          )
        : null;
    final selectedName = selectedEmployee?['name'] as String? ?? 'Все сотрудники';

    return GestureDetector(
      onTap: onShowSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selectedEmployeeId != null
                ? AppColors.primary
                : context.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 20,
              color: selectedEmployeeId != null
                  ? AppColors.primary
                  : context.textSecondaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сотрудник',
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  Text(
                    selectedName,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimaryColor,
                      fontWeight: selectedEmployeeId != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedEmployeeId != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onEmployeeSelected(null);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: context.textSecondaryColor,
                  ),
                ),
              )
            else
              Icon(
                Icons.expand_more,
                color: context.textSecondaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
