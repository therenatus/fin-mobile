import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/widgets/date_range_picker_button.dart';
import '../../core/riverpod/providers.dart';

class EmployeeWorklogsScreen extends ConsumerStatefulWidget {
  final Employee employee;

  const EmployeeWorklogsScreen({super.key, required this.employee});

  @override
  ConsumerState<EmployeeWorklogsScreen> createState() => _EmployeeWorklogsScreenState();
}

class _EmployeeWorklogsScreenState extends ConsumerState<EmployeeWorklogsScreen> {
  DateTimeRange? _dateRange;
  bool _isLoading = true;
  List<Map<String, dynamic>> _workLogs = [];
  int _totalQuantity = 0;
  double _totalHours = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadWorkLogs());
    }
  }

  Future<void> _loadWorkLogs() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final workLogs = await api.getEmployeeWorkLogs(
        widget.employee.id,
        dateFrom: _dateRange?.start.toIso8601String().split('T')[0],
        dateTo: _dateRange?.end.toIso8601String().split('T')[0],
      );

      int totalQuantity = 0;
      double totalHours = 0;
      for (final log in workLogs) {
        totalQuantity += (log['quantity'] as num?)?.toInt() ?? 0;
        totalHours += (log['hours'] as num?)?.toDouble() ?? 0;
      }

      setState(() {
        _workLogs = workLogs;
        _totalQuantity = totalQuantity;
        _totalHours = totalHours;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text('История: ${widget.employee.name}'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Filters and summary
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: context.surfaceColor,
            child: Column(
              children: [
                // Date filter
                Row(
                  children: [
                    Expanded(
                      child: DateRangePickerButton(
                        dateRange: _dateRange,
                        onChanged: (range) {
                          setState(() => _dateRange = range);
                          _loadWorkLogs();
                        },
                        placeholder: 'Все даты',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Summary
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.check_circle_outline,
                        label: 'Всего шт',
                        value: _totalQuantity.toString(),
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.timer_outlined,
                        label: 'Всего часов',
                        value: _totalHours.toStringAsFixed(1),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.list_alt,
                        label: 'Записей',
                        value: _workLogs.length.toString(),
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Work logs list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _workLogs.isEmpty
                    ? _buildEmptyState()
                    : _buildWorkLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: context.textTertiaryColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Нет записей',
            style: AppTypography.h4.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _dateRange != null
                ? 'Попробуйте изменить период'
                : 'Сотрудник ещё не записывал работу',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textTertiaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkLogsList() {
    // Group by date
    final groupedLogs = <String, List<Map<String, dynamic>>>{};
    for (final log in _workLogs) {
      final dateStr = log['date'] != null
          ? DateTime.parse(log['date'].toString()).toIso8601String().split('T')[0]
          : 'unknown';
      groupedLogs.putIfAbsent(dateStr, () => []).add(log);
    }

    final sortedDates = groupedLogs.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _loadWorkLogs,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final dateStr = sortedDates[index];
          final logs = groupedLogs[dateStr]!;
          final date = DateTime.parse(dateStr);
          final dateFormat = DateFormat('d MMMM yyyy', 'ru');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: AppSpacing.md),
              // Date header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  dateFormat.format(date),
                  style: AppTypography.labelMedium.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Logs for this date
              ...logs.map((log) => _WorkLogCard(log: log)),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.h4.copyWith(color: color),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkLogCard extends StatelessWidget {
  final Map<String, dynamic> log;

  const _WorkLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final order = log['order'] as Map<String, dynamic>?;
    final modelName = order?['modelName'] ?? 'Неизвестно';
    final clientName = order?['clientName'] ?? '';
    final step = log['step'] ?? '';
    final quantity = log['quantity'] ?? 0;
    final hours = (log['hours'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modelName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        step,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (clientName.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        clientName,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$quantity шт',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              if (hours > 0)
                Text(
                  '${hours.toStringAsFixed(1)} ч',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
