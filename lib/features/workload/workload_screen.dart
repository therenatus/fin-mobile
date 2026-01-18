import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/widgets/app_drawer.dart';
import '../orders/order_detail_screen.dart';

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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            _buildSummaryCard(summary),
            const SizedBox(height: AppSpacing.lg),

            // At-risk orders
            _buildAtRiskOrdersSection(calendar),
            const SizedBox(height: AppSpacing.lg),

            // Employee filter
            if (employees.isNotEmpty) ...[
              _buildEmployeeFilter(employees),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Calendar
            Text(
              'Календарь загрузки',
              style: AppTypography.h4.copyWith(color: context.textPrimaryColor),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...calendar.map((day) => _buildDayCard(day)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    final totalPlanned = (summary['totalPlannedHours'] ?? 0).toDouble();
    final totalCapacity = (summary['totalCapacity'] ?? 1).toDouble();
    final averageLoad = summary['averageLoad'] ?? 0;
    final overloadedDays = summary['overloadedDays'] ?? 0;
    final employeesCount = summary['employeesCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Сводка на $_days дней',
                style: AppTypography.h4.copyWith(color: context.textPrimaryColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Запланировано',
                  '${totalPlanned.toStringAsFixed(1)} ч',
                  Icons.schedule,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Ёмкость',
                  '${totalCapacity.toStringAsFixed(0)} ч',
                  Icons.inventory_2_outlined,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Ср. загрузка',
                  '$averageLoad%',
                  Icons.speed,
                  _getLoadColor(averageLoad),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Перегруз дней',
                  '$overloadedDays',
                  Icons.warning_amber,
                  overloadedDays > 0 ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
          if (employeesCount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Сотрудников: $employeesCount',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAtRiskOrdersSection(List calendar) {
    // Collect all overdue orders from calendar
    final atRiskOrders = <Map<String, dynamic>>[];
    final seenIds = <String>{};

    for (final day in calendar) {
      final orders = (day['orders'] as List?) ?? [];
      for (final order in orders) {
        final orderId = order['id'] as String?;
        final isOverdue = order['isOverdue'] as bool? ?? false;
        if (orderId != null && isOverdue && !seenIds.contains(orderId)) {
          seenIds.add(orderId);
          atRiskOrders.add(Map<String, dynamic>.from(order));
        }
      }
    }

    if (atRiskOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Все заказы в графике',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    'Нет просроченных заказов',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Заказы под угрозой',
                style: AppTypography.h4.copyWith(
                  color: AppColors.error,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${atRiskOrders.length}',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...atRiskOrders.take(5).map((order) => _buildAtRiskOrderItem(order)),
          if (atRiskOrders.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ещё ${atRiskOrders.length - 5} заказов',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAtRiskOrderItem(Map<String, dynamic> order) {
    final orderId = order['id'] as String?;
    final clientName = order['clientName'] as String? ?? 'Неизвестный заказчик';
    final modelName = order['modelName'] as String? ?? 'Неизвестная модель';
    final dueDate = order['dueDate'] as String? ?? '';
    final quantity = order['quantity'] ?? 0;

    return GestureDetector(
      onTap: orderId != null ? () => _openOrderDetail(orderId) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_long, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modelName,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$clientName • $quantity шт.',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                dueDate.isNotEmpty ? dueDate : 'Просрочен',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: context.textTertiaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOrderDetail(String orderId) async {
    HapticFeedback.selectionClick();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final api = ref.read(apiServiceProvider);
      final order = await api.getOrder(orderId);

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось загрузить заказ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.h4.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeFilter(List employees) {
    final selectedEmployee = _selectedEmployeeId != null
        ? employees.firstWhere(
            (e) => e['id'] == _selectedEmployeeId,
            orElse: () => null,
          )
        : null;
    final selectedName = selectedEmployee?['name'] as String? ?? 'Все сотрудники';

    return GestureDetector(
      onTap: () => _showEmployeeSelector(employees),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _selectedEmployeeId != null
                ? AppColors.primary
                : context.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 20,
              color: _selectedEmployeeId != null
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
                      fontWeight: _selectedEmployeeId != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedEmployeeId != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedEmployeeId = null);
                  _loadData();
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

  void _showEmployeeSelector(List employees) {
    HapticFeedback.selectionClick();
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final query = searchController.text.toLowerCase();
          final filteredEmployees = query.isEmpty
              ? employees
              : employees.where((e) {
                  final name = (e['name'] as String? ?? '').toLowerCase();
                  return name.contains(query);
                }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Text(
                        'Выберите сотрудника',
                        style: AppTypography.h4.copyWith(
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${employees.length} чел.',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Поиск по имени...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                searchController.clear();
                                setModalState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: context.surfaceVariantColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // "All employees" option
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.groups_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text('Все сотрудники'),
                  trailing: _selectedEmployeeId == null
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedEmployeeId = null);
                    _loadData();
                  },
                ),
                const Divider(),
                // Employee list
                Expanded(
                  child: filteredEmployees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: context.textTertiaryColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Сотрудники не найдены',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final emp = filteredEmployees[index];
                            final id = emp['id'] as String;
                            final name = emp['name'] as String? ?? '';
                            final isSelected = _selectedEmployeeId == id;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.secondary.withAlpha(20),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              title: Text(name),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: AppColors.primary)
                                  : null,
                              onTap: () {
                                Navigator.pop(context);
                                setState(() => _selectedEmployeeId = id);
                                _loadData();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
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
          leading: _buildLoadIndicator(loadPercentage, status),
          title: Row(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
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
                      '${plannedHours.toStringAsFixed(1)} / ${totalHours.toStringAsFixed(0)} ч • ${orders.length} заказов',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLoadBadge(loadPercentage, status),
            ],
          ),
          children: [
            if (orders.isNotEmpty) ...[
              const Divider(),
              ...orders.map((order) => _buildOrderItem(order)).toList(),
            ],
            if (employees.isNotEmpty && _selectedEmployeeId == null) ...[
              const Divider(),
              _buildEmployeesSection(employees),
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

  Widget _buildLoadIndicator(int loadPercentage, String status) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: loadPercentage / 100,
            backgroundColor: context.surfaceVariantColor,
            valueColor: AlwaysStoppedAnimation(_getStatusColor(status)),
            strokeWidth: 4,
          ),
          Text(
            '$loadPercentage',
            style: AppTypography.labelSmall.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadBadge(int loadPercentage, String status) {
    final color = _getStatusColor(status);
    final label = _getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final clientName = order['clientName'] as String? ?? '';
    final modelName = order['modelName'] as String? ?? '';
    final quantity = order['quantity'] ?? 0;
    final estimatedHours = (order['estimatedHours'] ?? 0).toDouble();
    final isOverdue = order['isOverdue'] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isOverdue ? AppColors.error : AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$modelName • $quantity шт',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${estimatedHours.toStringAsFixed(1)} ч',
                style: AppTypography.labelMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isOverdue)
                Text(
                  'Просрочен',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesSection(List employees) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'light':
        return AppColors.success;
      case 'normal':
        return AppColors.info;
      case 'heavy':
        return AppColors.warning;
      case 'overload':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'light':
        return 'Свободно';
      case 'normal':
        return 'Норма';
      case 'heavy':
        return 'Загружен';
      case 'overload':
        return 'Перегруз';
      default:
        return '';
    }
  }

  Color _getLoadColor(int load) {
    if (load < 50) return AppColors.success;
    if (load < 80) return AppColors.info;
    if (load < 100) return AppColors.warning;
    return AppColors.error;
  }
}
