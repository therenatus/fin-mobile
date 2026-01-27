import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/riverpod/providers.dart';
import '../../core/services/api_service.dart';

class PayrollScreen extends ConsumerStatefulWidget {
  const PayrollScreen({super.key});

  @override
  ConsumerState<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends ConsumerState<PayrollScreen> {
  DateTime _periodStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _periodEnd = DateTime.now();

  bool _isLoading = false;
  bool _isLoadingHistory = true;
  bool _initialized = false;

  Payroll? _currentPayroll;
  List<Payroll> _payrollHistory = [];
  List<Employee> _employees = [];
  final Map<String, bool> _expandedCards = {};

  @override
  void initState() {
    super.initState();
    // Set period to current month
    final now = DateTime.now();
    _periodStart = DateTime(now.year, now.month, 1);
    _periodEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadData());
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadPayrollHistory(),
      _loadEmployees(),
    ]);
  }

  Future<void> _loadPayrollHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final api = ref.read(apiServiceProvider);
      final payrolls = await api.getPayrolls();
      setState(() {
        _payrollHistory = payrolls..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() => _isLoadingHistory = false);
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

  Future<void> _loadEmployees() async {
    try {
      final api = ref.read(apiServiceProvider);
      final employees = await api.getEmployees();
      setState(() {
        _employees = employees;
      });
    } catch (e) {
      // Silently fail - employees are optional for display
    }
  }

  Future<void> _generatePayroll() async {
    setState(() => _isLoading = true);

    try {
      final api = ref.read(apiServiceProvider);
      final payroll = await api.generatePayroll(
        periodStart: _periodStart,
        periodEnd: _periodEnd,
      );

      setState(() {
        _currentPayroll = payroll;
        _isLoading = false;
      });

      // Reload history
      _loadPayrollHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.salaryCalculated),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.error}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart ? _periodStart : _periodEnd;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ru'),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _periodStart = date;
          if (_periodEnd.isBefore(_periodStart)) {
            _periodEnd = _periodStart;
          }
        } else {
          _periodEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
          if (_periodStart.isAfter(_periodEnd)) {
            _periodStart = _periodEnd;
          }
        }
        _currentPayroll = null;
      });
    }
  }

  Employee? _findEmployee(String employeeId) {
    try {
      return _employees.firstWhere((e) => e.id == employeeId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      drawer: const AppDrawer(currentRoute: 'payroll'),
      appBar: AppBar(
        title: Text(context.l10n.payroll),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: AppSpacing.lg),
            if (_currentPayroll != null) ...[
              _buildPayrollResult(),
              const SizedBox(height: AppSpacing.lg),
            ],
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      elevation: 0,
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  context.l10n.calculationPeriod,
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _DatePickerButton(
                    label: context.l10n.fromLabel,
                    date: _periodStart,
                    onTap: () => _selectDate(true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Icon(Icons.arrow_forward, color: context.textTertiaryColor),
                ),
                Expanded(
                  child: _DatePickerButton(
                    label: context.l10n.toLabel,
                    date: _periodEnd,
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generatePayroll,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate),
                label: Text(_isLoading ? context.l10n.calculating : context.l10n.calculate),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordToFinance() async {
    if (_currentPayroll == null) return;

    final payroll = _currentPayroll!;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('d.MM.yy', locale);
    final period = '${dateFormat.format(payroll.periodStart)} - ${dateFormat.format(payroll.periodEnd)}';
    final description = context.l10n.salaryDescriptionFormat(period);

    try {
      final api = ref.read(apiServiceProvider);
      await api.createTransaction(
        date: DateTime.now(),
        type: 'expense',
        category: 'salary',
        amount: payroll.totalPayout,
        description: description,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.recordedToFinance),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.error}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildPayrollResult() {
    final payroll = _currentPayroll!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total card
        Card(
          elevation: 0,
          color: AppColors.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.totalToPay,
                            style: AppTypography.labelLarge.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${NumberFormat('#,###', 'ru').format(payroll.totalPayout)} сом',
                            style: AppTypography.h2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _recordToFinance,
                    icon: const Icon(Icons.add_chart),
                    label: Text(context.l10n.recordToFinance),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            context.l10n.employeePayments,
            style: AppTypography.labelLarge.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ),

        // Employee cards
        ...payroll.details.entries.map((entry) {
          final employeeId = entry.key;
          final detail = entry.value;
          final employee = _findEmployee(employeeId);
          final isExpanded = _expandedCards[employeeId] ?? false;

          return _EmployeeSalaryCard(
            employee: employee,
            detail: detail,
            isExpanded: isExpanded,
            onToggle: () {
              setState(() {
                _expandedCards[employeeId] = !isExpanded;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.history, size: 18, color: context.textSecondaryColor),
              const SizedBox(width: 8),
              Text(
                context.l10n.calculationHistory,
                style: AppTypography.labelLarge.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        if (_isLoadingHistory)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_payrollHistory.isEmpty)
          Card(
            elevation: 0,
            color: context.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: context.borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: context.textTertiaryColor,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.noCalculationHistory,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...(_payrollHistory.take(5).map((payroll) {
            return Card(
              elevation: 0,
              color: context.surfaceColor,
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: BorderSide(color: context.borderColor),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.surfaceVariantColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  payroll.formattedPeriod,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  DateFormat('d MMM yyyy, HH:mm', 'ru').format(payroll.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                trailing: Text(
                  '${NumberFormat('#,###', 'ru').format(payroll.totalPayout)} сом',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _currentPayroll = payroll;
                    _periodStart = payroll.periodStart;
                    _periodEnd = payroll.periodEnd;
                  });
                },
              ),
            );
          })),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('d MMM yyyy', 'ru').format(date),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeSalaryCard extends ConsumerWidget {
  final Employee? employee;
  final EmployeePayrollDetail detail;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _EmployeeSalaryCard({
    required this.employee,
    required this.detail,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: context.surfaceColor,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.borderColor),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: detail.workLogs.isNotEmpty ? onToggle : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  employee?.name.isNotEmpty == true
                      ? employee!.name.substring(0, 1).toUpperCase()
                      : '?',
                  style: AppTypography.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            title: Text(
              employee?.name ?? context.l10n.employee,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              employee != null
                  ? ref.read(dashboardNotifierProvider).getRoleLabel(employee!.role)
                  : context.l10n.unknownRole,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${NumberFormat('#,###', 'ru').format(detail.totalPayout)} сом',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (detail.workLogs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: context.textTertiaryColor,
                    ),
                  ),
              ],
            ),
          ),
          if (isExpanded && detail.workLogs.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.workDone,
                      style: AppTypography.labelSmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...detail.workLogs.map((log) {
                      final rateText = log.rate != null && log.rate! > 0
                          ? '${log.rate!.toStringAsFixed(0)} сом/${log.rateType == 'per_hour' ? context.l10n.perHour : context.l10n.perPiece}'
                          : '';
                      final payoutText = log.payout != null && log.payout! > 0
                          ? '${NumberFormat('#,###', 'ru').format(log.payout)} сом'
                          : '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Model name
                            if (log.modelName != null)
                              Text(
                                log.modelName!,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(height: 4),
                            // Step and rate
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    log.step,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                if (rateText.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    rateText,
                                    style: AppTypography.caption.copyWith(
                                      color: context.textTertiaryColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Quantity, hours and payout
                            Row(
                              children: [
                                if (log.quantity > 0)
                                  Text(
                                    context.l10n.piecesShort(log.quantity),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                if (log.hours > 0) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    context.l10n.hoursShort(log.hours.toStringAsFixed(1)),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                if (payoutText.isNotEmpty)
                                  Text(
                                    payoutText,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
