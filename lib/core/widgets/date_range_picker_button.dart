import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class DateRangePickerButton extends StatelessWidget {
  final DateTimeRange? dateRange;
  final ValueChanged<DateTimeRange?> onChanged;
  final String placeholder;
  final bool showClearButton;

  const DateRangePickerButton({
    super.key,
    this.dateRange,
    required this.onChanged,
    this.placeholder = 'Выбрать даты',
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasRange = dateRange != null;
    final dateFormat = DateFormat('d MMM', 'ru');

    return Container(
      decoration: BoxDecoration(
        color: hasRange
            ? AppColors.primary.withOpacity(0.1)
            : context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: hasRange
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDateRangePicker(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: hasRange ? AppColors.primary : context.textSecondaryColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  hasRange
                      ? '${dateFormat.format(dateRange!.start)} - ${dateFormat.format(dateRange!.end)}'
                      : placeholder,
                  style: AppTypography.labelMedium.copyWith(
                    color: hasRange ? AppColors.primary : context.textSecondaryColor,
                  ),
                ),
                if (hasRange && showClearButton) ...[
                  const SizedBox(width: AppSpacing.xs),
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 1);

    final result = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: dateRange,
      locale: const Locale('ru', 'RU'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: context.surfaceColor,
              onSurface: context.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      onChanged(result);
    }
  }
}

/// A compact version that can be used in app bar or toolbar
class DateRangeChip extends StatelessWidget {
  final DateTimeRange? dateRange;
  final ValueChanged<DateTimeRange?> onChanged;

  const DateRangeChip({
    super.key,
    this.dateRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasRange = dateRange != null;
    final dateFormat = DateFormat('d MMM', 'ru');

    return FilterChip(
      selected: hasRange,
      label: Text(
        hasRange
            ? '${dateFormat.format(dateRange!.start)} - ${dateFormat.format(dateRange!.end)}'
            : 'Даты',
      ),
      avatar: hasRange
          ? null
          : const Icon(Icons.calendar_today, size: 16),
      deleteIcon: hasRange ? const Icon(Icons.close, size: 16) : null,
      onDeleted: hasRange ? () => onChanged(null) : null,
      onSelected: (_) => _showDateRangePicker(context),
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: hasRange ? AppColors.primary : context.textSecondaryColor,
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 1);

    final result = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: dateRange,
      locale: const Locale('ru', 'RU'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      onChanged(result);
    }
  }
}
