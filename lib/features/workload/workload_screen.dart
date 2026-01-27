import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/widgets/app_drawer.dart';
import '../orders/order_detail_screen.dart';
import 'widgets/widgets.dart';

class WorkloadScreen extends ConsumerStatefulWidget {
  const WorkloadScreen({super.key});

  @override
  ConsumerState<WorkloadScreen> createState() => _WorkloadScreenState();
}

class _WorkloadScreenState extends ConsumerState<WorkloadScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() {
        ref.read(workloadNotifierProvider.notifier).loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workloadNotifierProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      drawer: const AppDrawer(currentRoute: 'workload'),
      appBar: AppBar(
        title: const Text('Загрузка производства'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Период',
            onSelected: (value) {
              ref.read(workloadNotifierProvider.notifier).setDays(value);
            },
            itemBuilder: (context) => [
              _buildDaysOption(state.days, 7, '7 дней'),
              _buildDaysOption(state.days, 14, '14 дней'),
              _buildDaysOption(state.days, 30, '30 дней'),
            ],
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  PopupMenuItem<int> _buildDaysOption(int currentDays, int value, String label) {
    final isSelected = currentDays == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check : Icons.calendar_view_day,
            size: 18,
            color: isSelected ? AppColors.primary : context.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : context.textPrimaryColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(WorkloadStateData state) {
    if (state.isLoading && state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.textTertiaryColor),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: AppTypography.h4.copyWith(color: context.textPrimaryColor),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.read(workloadNotifierProvider.notifier).loadData(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (state.data == null) {
      return const Center(child: Text('Нет данных'));
    }

    final calendar = state.calendar;
    final summary = state.summary;
    final employees = state.employees;
    final atRiskOrders = AtRiskOrdersCard.extractFromCalendar(calendar);

    return RefreshIndicator(
      onRefresh: () => ref.read(workloadNotifierProvider.notifier).loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WorkloadSummaryCard(summary: summary, days: state.days),
            const SizedBox(height: AppSpacing.lg),
            AtRiskOrdersCard(
              atRiskOrders: atRiskOrders,
              onOrderTap: _openOrderDetail,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (employees.isNotEmpty) ...[
              EmployeeFilterButton(
                employees: employees,
                selectedEmployeeId: state.selectedEmployeeId,
                onEmployeeSelected: (id) {
                  ref.read(workloadNotifierProvider.notifier).setEmployeeId(id);
                },
                onShowSelector: () => _showEmployeeSelector(employees),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              'Календарь загрузки',
              style: AppTypography.h4.copyWith(color: context.textPrimaryColor),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...calendar.map((day) => WorkloadDayCard(
                  day: day,
                  selectedEmployeeId: state.selectedEmployeeId,
                )),
          ],
        ),
      ),
    );
  }

  void _showEmployeeSelector(List employees) {
    HapticFeedback.selectionClick();
    EmployeeSelectorSheet.show(
      context,
      employees: employees,
      selectedEmployeeId: ref.read(workloadNotifierProvider).selectedEmployeeId,
      onEmployeeSelected: (id) {
        ref.read(workloadNotifierProvider.notifier).setEmployeeId(id);
      },
    );
  }

  Future<void> _openOrderDetail(String orderId) async {
    HapticFeedback.selectionClick();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final api = ref.read(apiServiceProvider);
      final order = await api.getOrder(orderId);

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось загрузить заказ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
