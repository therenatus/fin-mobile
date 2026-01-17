import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/models/models.dart';
import '../../core/widgets/date_range_picker_button.dart';
import '../../core/services/api_service.dart';

class WorklogsScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const WorklogsScreen({super.key, this.onMenuPressed});

  @override
  State<WorklogsScreen> createState() => _WorklogsScreenState();
}

class _WorklogsScreenState extends State<WorklogsScreen> {
  DateTimeRange? _dateRange;
  String? _selectedEmployeeId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _workLogs = [];
  List<Employee> _employees = [];
  int _totalQuantity = 0;
  double _totalHours = 0;
  bool _initialized = false;

  ApiService get _api => context.read<AppProvider>().api;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadEmployees(),
      _loadWorkLogs(),
    ]);
  }

  Future<void> _loadEmployees() async {
    try {
      final api = _api;
      final employees = await api.getEmployees();
      if (mounted) {
        setState(() => _employees = employees);
      }
    } catch (e) {
      // Ignore employee loading errors
    }
  }

  Future<void> _loadWorkLogs() async {
    setState(() => _isLoading = true);
    try {
      final api = _api;
      final workLogs = await api.getAllWorklogs(
        employeeId: _selectedEmployeeId,
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
            content: Text(context.l10n.loadingError(e.toString())),
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
        title: Text(context.l10n.workRecords),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuPressed,
        ),
      ),
      body: Column(
        children: [
          // Filters and summary
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: context.surfaceColor,
            child: Column(
              children: [
                // Employee filter
                _EmployeeDropdown(
                  employees: _employees,
                  selectedEmployeeId: _selectedEmployeeId,
                  onChanged: (id) {
                    setState(() => _selectedEmployeeId = id);
                    _loadWorkLogs();
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                // Date filter
                DateRangePickerButton(
                  dateRange: _dateRange,
                  onChanged: (range) {
                    setState(() => _dateRange = range);
                    _loadWorkLogs();
                  },
                  placeholder: context.l10n.allDates,
                ),
                const SizedBox(height: AppSpacing.md),
                // Summary
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.check_circle_outline,
                        label: context.l10n.totalPieces,
                        value: _totalQuantity.toString(),
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.timer_outlined,
                        label: context.l10n.totalHours,
                        value: _totalHours.toStringAsFixed(1),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.list_alt,
                        label: context.l10n.recordsCount,
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
            context.l10n.noRecords,
            style: AppTypography.h4.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _dateRange != null || _selectedEmployeeId != null
                ? context.l10n.tryChangeFilters
                : context.l10n.employeesNotRecordedWork,
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

          // Calculate day totals
          int dayQuantity = 0;
          double dayHours = 0;
          for (final log in logs) {
            dayQuantity += (log['quantity'] as num?)?.toInt() ?? 0;
            dayHours += (log['hours'] as num?)?.toDouble() ?? 0;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: AppSpacing.md),
              // Date header with day totals
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(date),
                      style: AppTypography.labelMedium.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    Text(
                      '$dayQuantity шт • ${dayHours.toStringAsFixed(1)} ч',
                      style: AppTypography.labelSmall.copyWith(
                        color: context.textTertiaryColor,
                      ),
                    ),
                  ],
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

class _EmployeeDropdown extends StatelessWidget {
  final List<Employee> employees;
  final String? selectedEmployeeId;
  final ValueChanged<String?> onChanged;

  const _EmployeeDropdown({
    required this.employees,
    required this.selectedEmployeeId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: selectedEmployeeId,
          hint: Text(
            context.l10n.allEmployees,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                context.l10n.allEmployees,
                style: AppTypography.bodyMedium,
              ),
            ),
            ...employees.map((emp) => DropdownMenuItem<String?>(
              value: emp.id,
              child: Text(
                emp.name,
                style: AppTypography.bodyMedium,
              ),
            )),
          ],
          onChanged: onChanged,
        ),
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
    final employee = log['employee'] as Map<String, dynamic>?;
    final order = log['order'] as Map<String, dynamic>?;
    final employeeName = employee?['name'] ?? context.l10n.unknown;
    final modelName = order?['modelName'] ?? context.l10n.unknown;
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
          // Employee avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              employeeName.isNotEmpty ? employeeName[0].toUpperCase() : '?',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employeeName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  modelName,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
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
                      Expanded(
                        child: Text(
                          clientName,
                          style: AppTypography.caption.copyWith(
                            color: context.textTertiaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
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
