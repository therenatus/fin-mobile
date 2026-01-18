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
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _data;
  int _days = 14;
  String? _selectedEmployeeId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      debugPrint('[WorkloadScreen] Loading data: days=$_days, employeeId=$_selectedEmployeeId');
      final data = await api.getWorkloadCalendar(
        days: _days,
        employeeId: _selectedEmployeeId,
      );
      final calendar = (data['calendar'] as List?) ?? [];
      final ordersCount = calendar.isNotEmpty ? (calendar[0]['orders'] as List?)?.length ?? 0 : 0;
      debugPrint('[WorkloadScreen] Loaded: ${calendar.length} days, $ordersCount orders on day 1');
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[WorkloadScreen] Error: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              setState(() => _days = value);
              _loadData();
            },
            itemBuilder: (context) => [
              _buildDaysOption(7, '7 дней'),
              _buildDaysOption(14, '14 дней'),
              _buildDaysOption(30, '30 дней'),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  PopupMenuItem<int> _buildDaysOption(int value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            _days == value ? Icons.check : Icons.calendar_view_day,
            size: 18,
            color: _days == value ? AppColors.primary : context.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: _days == value ? AppColors.primary : context.textPrimaryColor,
              fontWeight: _days == value ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
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
              onPressed: _loadData,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_data == null) {
      return const Center(child: Text('Нет данных'));
    }

    final calendar = (_data!['calendar'] as List?) ?? [];
    final summary = _data!['summary'] as Map<String, dynamic>? ?? {};
    final employees = (_data!['employees'] as List?) ?? [];
    final atRiskOrders = AtRiskOrdersCard.extractFromCalendar(calendar);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WorkloadSummaryCard(summary: summary, days: _days),
            const SizedBox(height: AppSpacing.lg),
            AtRiskOrdersCard(
              atRiskOrders: atRiskOrders,
              onOrderTap: _openOrderDetail,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (employees.isNotEmpty) ...[
              EmployeeFilterButton(
                employees: employees,
                selectedEmployeeId: _selectedEmployeeId,
                onEmployeeSelected: (id) {
                  setState(() => _selectedEmployeeId = id);
                  _loadData();
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
                  selectedEmployeeId: _selectedEmployeeId,
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
      selectedEmployeeId: _selectedEmployeeId,
      onEmployeeSelected: (id) {
        setState(() => _selectedEmployeeId = id);
        _loadData();
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
