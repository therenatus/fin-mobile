import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/employee_user.dart';

class WorkHistoryScreen extends ConsumerStatefulWidget {
  const WorkHistoryScreen({super.key});

  @override
  ConsumerState<WorkHistoryScreen> createState() => _WorkHistoryScreenState();
}

class _WorkHistoryScreenState extends ConsumerState<WorkHistoryScreen> {
  int _selectedSegment = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(employeeAuthNotifierProvider.notifier);
      notifier.refreshWorkLogs();
      notifier.refreshPayrolls();
    });
  }

  Future<void> _onRefresh() async {
    final notifier = ref.read(employeeAuthNotifierProvider.notifier);
    if (_selectedSegment == 0) {
      await notifier.refreshWorkLogs();
    } else {
      await notifier.refreshPayrolls();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.history),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Segment control
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: context.surfaceColor,
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(context.l10n.works), icon: const Icon(Icons.work_outline)),
                ButtonSegment(value: 1, label: Text(context.l10n.salary), icon: const Icon(Icons.payments_outlined)),
              ],
              selected: {_selectedSegment},
              onSelectionChanged: (selection) {
                setState(() => _selectedSegment = selection.first);
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.primary,
                selectedForegroundColor: Colors.white,
              ),
            ),
          ),

          // Content
          Expanded(
            child: Builder(
              builder: (context) {
                final authState = ref.watch(employeeAuthNotifierProvider);
                if (_selectedSegment == 0) {
                  return _buildWorkLogsTab(context, authState);
                } else {
                  return _buildPayrollsTab(context, authState);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkLogsTab(BuildContext context, EmployeeAuthStateData authState) {
    if (authState.isLoading && authState.workLogs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (authState.workLogs.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.work_outline,
        title: context.l10n.noWorkRecords,
        subtitle: context.l10n.workRecordsHint,
      );
    }

    // Group by date
    final grouped = <String, List<EmployeeWorkLog>>{};
    for (final log in authState.workLogs) {
      final key = DateFormat('d MMMM yyyy', 'ru').format(log.date);
      grouped.putIfAbsent(key, () => []).add(log);
    }

    final sortedDates = grouped.keys.toList();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final logs = grouped[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  date,
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
              ...logs.map((log) => _WorkLogCard(log: log)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPayrollsTab(BuildContext context, EmployeeAuthStateData authState) {
    if (authState.isLoading && authState.payrolls.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (authState.payrolls.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.payments_outlined,
        title: context.l10n.noPayrollRecords,
        subtitle: context.l10n.payrollRecordsHint,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: authState.payrolls.length,
        itemBuilder: (context, index) {
          return _PayrollCard(payroll: authState.payrolls[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.surfaceVariantColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 64,
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  style: AppTypography.h3.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textTertiaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkLogCard extends StatelessWidget {
  final EmployeeWorkLog log;

  const _WorkLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text(
                '${log.quantity}',
                style: AppTypography.h4.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.order.modelName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${log.step} • ${log.order.clientName}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (log.hours > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: context.surfaceVariantColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: context.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${log.hours.toStringAsFixed(1)}${context.l10n.hoursAbbr}',
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PayrollCard extends StatefulWidget {
  final EmployeePayroll payroll;

  const _PayrollCard({required this.payroll});

  @override
  State<_PayrollCard> createState() => _PayrollCardState();
}

class _PayrollCardState extends State<_PayrollCard> {
  bool _isExpanded = false;

  EmployeePayroll get payroll => widget.payroll;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'ru_RU',
      symbol: '',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM', 'ru');
    final periodText = '${dateFormat.format(payroll.periodStart)} - ${dateFormat.format(payroll.periodEnd)}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(AppRadius.lg),
              bottom: _isExpanded ? Radius.zero : const Radius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.payments,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          periodText,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.entriesCount(payroll.workLogs.length),
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_formatCurrency(payroll.totalPayout)} ${context.l10n.rub}',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: context.textSecondaryColor,
                  ),
                ],
              ),
            ),
          ),

          // Details
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.details,
                    style: AppTypography.labelMedium.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...payroll.workLogs.map((log) => _PayrollWorkLogItem(log: log)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PayrollWorkLogItem extends StatelessWidget {
  final EmployeePayrollWorkLog log;

  const _PayrollWorkLogItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM', 'ru');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: context.surfaceVariantColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '${log.quantity}',
                style: AppTypography.labelMedium,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.modelName ?? log.step,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${log.step} • ${dateFormat.format(log.date)}',
                  style: AppTypography.caption.copyWith(
                    color: context.textTertiaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (log.hours > 0)
            Text(
              '${log.hours.toStringAsFixed(1)}${context.l10n.hoursAbbr}',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
