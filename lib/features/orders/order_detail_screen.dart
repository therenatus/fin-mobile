import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/models/models.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/toast.dart';
import 'widgets/order_acceptance_sheet.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _order;
  List<ProcessStep> _processSteps = [];
  List<Employee> _employees = [];
  List<OrderAssignment> _assignments = [];
  List<WorkLog> _workLogs = [];
  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  bool _initialized = false;

  ApiService get _api => context.read<AppProvider>().api;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
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
    setState(() => _isLoading = true);
    try {
      final api = _api;

      // Load process steps for this model
      if (_order.model != null) {
        final steps = await api.getProcessSteps(_order.model!.id);
        _processSteps = steps..sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
      }

      // Load employees
      _employees = await api.getEmployees();

      // Load assignments for this order
      _assignments = await api.getOrderAssignments(_order.id);

      // Load work logs for this order
      final allLogs = await api.getWorkLogs();
      _workLogs = allLogs.where((log) => log.orderId == _order.id).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppToast.error(context, 'Ошибка загрузки: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(_order.model?.name ?? 'Заказ'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          _StatusChip(status: _order.status),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildClientSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildOrderDetailsSection(),
                        const SizedBox(height: AppSpacing.lg),
                        if (_order.status == OrderStatus.inProgress) ...[
                          _buildProgressSection(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildProductionSection(),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        _buildActionsSection(),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildClientSection() {
    return _SectionCard(
      title: 'Заказчик',
      icon: Icons.person_outline,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            radius: 24,
            child: Text(
              (_order.client?.name.isNotEmpty == true
                  ? _order.client!.name.substring(0, 1).toUpperCase()
                  : '?'),
              style: AppTypography.h4.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _order.client?.name ?? 'Неизвестный заказчик',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_order.client?.contacts.phone != null)
                  Text(
                    _order.client!.contacts.phone!,
                    style: AppTypography.bodyMedium.copyWith(
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

  Widget _buildOrderDetailsSection() {
    return _SectionCard(
      title: 'Детали заказа',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _DetailRow(
            label: 'Номер заказа',
            value: '#${_order.id.length >= 8 ? _order.id.substring(0, 8) : _order.id}',
          ),
          _DetailRow(
            label: 'Количество',
            value: '${_order.quantity} шт.',
          ),
          _DetailRow(
            label: 'Стоимость',
            value: '${_order.totalPrice.toStringAsFixed(0)} \u20BD',
          ),
          if (_order.dueDate != null)
            _DetailRow(
              label: 'Дата сдачи',
              value: DateFormat('d MMMM yyyy', 'ru').format(_order.dueDate!),
              valueColor: _order.isOverdue ? AppColors.error : null,
            ),
          _DetailRow(
            label: 'Создан',
            value: DateFormat('d MMMM yyyy', 'ru').format(_order.createdAt),
          ),
        ],
      ),
    );
  }

  // Progress calculation helpers
  double get _plannedTotalHours {
    if (_processSteps.isEmpty) return 0;
    final totalMinutes = _processSteps.fold<int>(
      0,
      (sum, step) => sum + step.estimatedTime,
    );
    return (totalMinutes * _order.quantity) / 60.0;
  }

  int get _completedQuantity {
    if (_processSteps.isEmpty || _workLogs.isEmpty) return 0;
    // Minimum quantity completed across all steps (bottleneck)
    return _processSteps.map((step) {
      return _workLogs
          .where((w) => w.step.toLowerCase() == step.name.toLowerCase())
          .fold<int>(0, (sum, w) => sum + w.quantity);
    }).reduce((a, b) => a < b ? a : b);
  }

  double get _progressPercentage {
    if (_order.quantity == 0) return 0;
    return (_completedQuantity / _order.quantity * 100).clamp(0, 100);
  }

  double get _expectedProgressPercentage {
    if (_order.dueDate == null) return 0;
    final totalDays = _order.dueDate!.difference(_order.createdAt).inDays;
    final elapsedDays = DateTime.now().difference(_order.createdAt).inDays;
    if (totalDays <= 0) return 100;
    return (elapsedDays / totalDays * 100).clamp(0, 100);
  }

  bool get _isBehindSchedule => _progressPercentage < _expectedProgressPercentage - 10;

  int get _daysRemaining {
    if (_order.dueDate == null) return 0;
    return _order.dueDate!.difference(DateTime.now()).inDays;
  }

  double get _neededPerDay {
    if (_daysRemaining <= 0) return double.infinity;
    final remaining = _order.quantity - _completedQuantity;
    return remaining / _daysRemaining;
  }

  Widget _buildProgressSection() {
    final isOnSchedule = !_isBehindSchedule;
    final statusColor = isOnSchedule ? AppColors.success : AppColors.warning;

    return _SectionCard(
      title: 'Прогресс производства',
      icon: Icons.trending_up,
      child: Column(
        children: [
          // Progress bar
          Stack(
            children: [
              // Expected progress (background)
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Expected progress marker
              if (_order.dueDate != null)
                FractionallySizedBox(
                  widthFactor: _expectedProgressPercentage / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.textSecondaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              // Actual progress
              FractionallySizedBox(
                widthFactor: _progressPercentage / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Metrics row
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  label: 'Выполнено',
                  value: '$_completedQuantity/${_order.quantity} шт',
                  subValue: '${_progressPercentage.toStringAsFixed(0)}%',
                  color: statusColor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: context.borderColor,
              ),
              Expanded(
                child: _MetricItem(
                  label: 'План. часов',
                  value: '${_plannedTotalHours.toStringAsFixed(1)} ч',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: context.borderColor,
              ),
              Expanded(
                child: _MetricItem(
                  label: 'Осталось дней',
                  value: _daysRemaining > 0 ? '$_daysRemaining' : 'Просрочен',
                  color: _daysRemaining <= 0 ? AppColors.error : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Status indicator
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  isOnSchedule ? Icons.check_circle_outline : Icons.warning_amber,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isOnSchedule
                        ? 'В графике'
                        : 'Отставание от плана',
                    style: AppTypography.bodyMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!isOnSchedule && _daysRemaining > 0)
                  Text(
                    'Нужно ${_neededPerDay.toStringAsFixed(1)} шт/день',
                    style: AppTypography.bodySmall.copyWith(
                      color: statusColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionSection() {
    if (_processSteps.isEmpty) {
      return _SectionCard(
        title: 'Производство',
        icon: Icons.construction_outlined,
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 32,
              color: context.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Нет этапов производства',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Добавьте этапы в настройках модели',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.construction_outlined, size: 20, color: context.textSecondaryColor),
            const SizedBox(width: 8),
            Text(
              'Производство',
              style: AppTypography.labelLarge.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const Spacer(),
            Text(
              '${_processSteps.length} ${_getStepsLabel(_processSteps.length)}',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ..._processSteps.map((step) {
          // Get assignments for this step
          final stepAssignments = _assignments
              .where((a) => a.stepName.toLowerCase() == step.name.toLowerCase())
              .toList();
          // Get work logs for this step
          final stepWorkLogs = _workLogs
              .where((w) => w.step.toLowerCase() == step.name.toLowerCase())
              .toList();

          return _WorkStepCard(
            step: step,
            employees: _employees,
            order: _order,
            assignments: stepAssignments,
            workLogs: stepWorkLogs,
            onDataChanged: _loadData,
          );
        }),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Column(
      children: [
        if (_order.status == OrderStatus.pending) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUpdatingStatus ? null : _showOrderAcceptanceSheet,
              icon: _isUpdatingStatus
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.assignment_turned_in_outlined),
              label: const Text('Принять заказ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUpdatingStatus ? null : _showStatusPicker,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Изменить статус'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_order.status == OrderStatus.inProgress) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUpdatingStatus
                      ? null
                      : () => _updateStatus(OrderStatus.completed),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Завершить'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Выберите статус', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            ...OrderStatus.values.map((status) {
              final isSelected = _order.status == status;
              return ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(_getStatusLabel(status)),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: isSelected
                    ? null
                    : () {
                        Navigator.pop(context);
                        _updateStatus(status);
                      },
              );
            }),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(OrderStatus newStatus) async {
    setState(() => _isUpdatingStatus = true);

    try {
      final api = _api;
      await api.updateOrderStatus(_order.id, newStatus.value);

      if (mounted) {
        final updatedOrder = await api.getOrder(_order.id);
        setState(() {
          _order = updatedOrder;
        });

        context.read<AppProvider>().refreshDashboard();

        AppToast.success(context, 'Статус изменён на "${_getStatusLabel(newStatus)}"');

        _loadData();
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Ошибка: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Ожидает';
      case OrderStatus.inProgress:
        return 'В работе';
      case OrderStatus.completed:
        return 'Готово';
      case OrderStatus.cancelled:
        return 'Отменён';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.inProgress:
        return AppColors.info;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStepsLabel(int count) {
    if (count == 1) return 'этап';
    if (count >= 2 && count <= 4) return 'этапа';
    return 'этапов';
  }

  void _showOrderAcceptanceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderAcceptanceSheet(
        order: _order,
        processSteps: _processSteps,
        employees: _employees,
        onAccepted: () {
          Navigator.pop(context);
          _loadData();
          context.read<AppProvider>().refreshDashboard();
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        label = 'Ожидает';
        break;
      case OrderStatus.inProgress:
        color = AppColors.info;
        label = 'В работе';
        break;
      case OrderStatus.completed:
        color = AppColors.success;
        label = 'Готово';
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        label = 'Отменён';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
                Icon(icon, size: 18, color: context.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final Color? color;

  const _MetricItem({
    required this.label,
    required this.value,
    this.subValue,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        if (subValue != null)
          Text(
            subValue!,
            style: AppTypography.bodySmall.copyWith(
              color: color ?? context.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _WorkStepCard extends StatefulWidget {
  final ProcessStep step;
  final List<Employee> employees;
  final Order order;
  final List<OrderAssignment> assignments;
  final List<WorkLog> workLogs;
  final VoidCallback onDataChanged;

  const _WorkStepCard({
    required this.step,
    required this.employees,
    required this.order,
    required this.assignments,
    required this.workLogs,
    required this.onDataChanged,
  });

  @override
  State<_WorkStepCard> createState() => _WorkStepCardState();
}

class _WorkStepCardState extends State<_WorkStepCard> {
  bool _isAdding = false;

  List<Employee> get _filteredEmployees {
    final executorRole = widget.step.executorRole.toLowerCase();
    final assignedIds = widget.assignments.map((a) => a.employeeId).toSet();
    return widget.employees
        .where((emp) => emp.role.toLowerCase() == executorRole)
        .where((emp) => !assignedIds.contains(emp.id))
        .toList();
  }

  /// Calculate total logged quantity for this step
  int get _totalLoggedQuantity {
    return widget.workLogs.fold(0, (sum, log) => sum + log.quantity);
  }

  /// Remaining quantity that can still be logged
  int get _remainingQuantity {
    return widget.order.quantity - _totalLoggedQuantity;
  }

  /// Check if step is fully completed
  bool get _isStepComplete {
    return _totalLoggedQuantity >= widget.order.quantity;
  }

  @override
  Widget build(BuildContext context) {
    final hasAssignments = widget.assignments.isNotEmpty;

    // Determine card color based on progress
    Color cardColor;
    Color borderColor;
    if (_isStepComplete) {
      cardColor = AppColors.success.withOpacity(0.08);
      borderColor = AppColors.success.withOpacity(0.4);
    } else if (hasAssignments) {
      cardColor = AppColors.info.withOpacity(0.05);
      borderColor = AppColors.info.withOpacity(0.3);
    } else {
      cardColor = context.surfaceColor;
      borderColor = context.borderColor;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _isStepComplete ? AppColors.success : AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Center(
                    child: _isStepComplete
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : Text(
                            '${widget.step.stepOrder}',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
                        widget.step.name,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _getRoleLabel(widget.step.executorRole),
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                          if (widget.step.rate != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ${widget.step.rate!.toStringAsFixed(0)} ₽/${widget.step.rateType == 'per_hour' ? 'ч' : 'ед'}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Progress indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isStepComplete
                        ? AppColors.success.withOpacity(0.15)
                        : context.textSecondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '$_totalLoggedQuantity/${widget.order.quantity}',
                    style: AppTypography.labelSmall.copyWith(
                      color: _isStepComplete ? AppColors.success : context.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Assigned employees list
            if (widget.assignments.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              ...widget.assignments.map((assignment) {
                // Find work log for this employee on this step
                final workLog = widget.workLogs
                    .where((w) => w.employeeId == assignment.employeeId)
                    .firstOrNull;
                return _AssignedEmployeeRow(
                  assignment: assignment,
                  workLog: workLog,
                  orderId: widget.order.id,
                  stepName: widget.step.name,
                  rateType: widget.step.rateType,
                  orderQuantity: widget.order.quantity,
                  remainingQuantity: _remainingQuantity,
                  onDataChanged: widget.onDataChanged,
                );
              }),
            ],

            // Add employee button
            const SizedBox(height: AppSpacing.sm),
            if (_isAdding)
              _AddEmployeeForm(
                employees: _filteredEmployees,
                orderId: widget.order.id,
                stepName: widget.step.name,
                executorRole: widget.step.executorRole,
                onSaved: () {
                  setState(() => _isAdding = false);
                  widget.onDataChanged();
                },
                onCancel: () => setState(() => _isAdding = false),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _isAdding = true),
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: const Text('Добавить сотрудника'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getRoleLabel(String role) {
    return context.read<AppProvider>().getRoleLabel(role);
  }
}

class _AssignedEmployeeRow extends StatefulWidget {
  final OrderAssignment assignment;
  final WorkLog? workLog;
  final String orderId;
  final String stepName;
  final String? rateType;
  final int orderQuantity;
  final int remainingQuantity;
  final VoidCallback onDataChanged;

  const _AssignedEmployeeRow({
    required this.assignment,
    this.workLog,
    required this.orderId,
    required this.stepName,
    this.rateType,
    required this.orderQuantity,
    required this.remainingQuantity,
    required this.onDataChanged,
  });

  @override
  State<_AssignedEmployeeRow> createState() => _AssignedEmployeeRowState();
}

class _AssignedEmployeeRowState extends State<_AssignedEmployeeRow> {
  bool _isDeleting = false;
  bool _isEditing = false;
  final _quantityController = TextEditingController();
  bool _isSaving = false;

  ApiService get _api => context.read<AppProvider>().api;

  /// Max quantity this employee can log (remaining + their current log)
  int get _maxQuantity {
    final currentEmployeeLog = widget.workLog?.quantity ?? 0;
    return widget.remainingQuantity + currentEmployeeLog;
  }

  @override
  void initState() {
    super.initState();
    if (widget.workLog != null) {
      _quantityController.text = widget.workLog!.quantity.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeName = widget.assignment.employee?.name ?? 'Неизвестный';
    final hasWorkLog = widget.workLog != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: hasWorkLog ? AppColors.success.withOpacity(0.05) : null,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: hasWorkLog ? Border.all(color: AppColors.success.withOpacity(0.2)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee info row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    employeeName.isNotEmpty ? employeeName[0].toUpperCase() : '?',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasWorkLog)
                      Text(
                        '${widget.workLog!.quantity} шт.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // Work log button
              IconButton(
                onPressed: () => setState(() => _isEditing = !_isEditing),
                icon: Icon(
                  hasWorkLog ? Icons.edit_outlined : Icons.add_task,
                  size: 18,
                  color: hasWorkLog ? AppColors.success : AppColors.primary,
                ),
                tooltip: hasWorkLog ? 'Изменить' : 'Записать работу',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              // Delete button
              _isDeleting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      onPressed: _deleteAssignment,
                      icon: Icon(Icons.close, size: 18, color: AppColors.error),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
            ],
          ),

          // Work log form (expanded)
          if (_isEditing) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            // Show max available info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 14, color: AppColors.info),
                  const SizedBox(width: 6),
                  Text(
                    'Макс: $_maxQuantity из ${widget.orderQuantity} шт.',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: hasWorkLog ? 'Изменить кол-во' : 'Сколько сделано?',
                      hintText: hasWorkLog ? '${widget.workLog!.quantity}' : '0',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveWorkLog,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    minimumSize: Size.zero,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check, size: 18),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveWorkLog() async {
    final quantity = int.tryParse(_quantityController.text) ?? 0;

    if (quantity == 0) {
      AppToast.warning(context, 'Укажите количество');
      return;
    }

    // Client-side validation
    if (quantity > _maxQuantity) {
      AppToast.error(
        context,
        'Превышен лимит! Макс: $_maxQuantity шт. (всего в заказе: ${widget.orderQuantity})',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final api = _api;
      await api.createWorkLog(
        employeeId: widget.assignment.employeeId,
        orderId: widget.orderId,
        step: widget.stepName,
        quantity: quantity,
        hours: 0,
        date: DateTime.now(),
      );

      if (mounted) {
        final wasUpdate = widget.workLog != null;
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        AppToast.success(
          context,
          wasUpdate ? 'Количество обновлено: $quantity шт.' : 'Работа записана: $quantity шт.',
        );
        widget.onDataChanged();
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Ошибка: $e');
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteAssignment() async {
    setState(() => _isDeleting = true);

    try {
      final api = _api;
      await api.deleteOrderAssignment(widget.orderId, widget.assignment.id);
      widget.onDataChanged();
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Ошибка: $e');
        setState(() => _isDeleting = false);
      }
    }
  }
}

class _AddEmployeeForm extends StatefulWidget {
  final List<Employee> employees;
  final String orderId;
  final String stepName;
  final String executorRole;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const _AddEmployeeForm({
    required this.employees,
    required this.orderId,
    required this.stepName,
    required this.executorRole,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<_AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<_AddEmployeeForm> {
  Employee? _selectedEmployee;
  bool _isSaving = false;

  ApiService get _api => context.read<AppProvider>().api;

  @override
  Widget build(BuildContext context) {
    if (widget.employees.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Нет доступных сотрудников с ролью "${context.read<AppProvider>().getRoleLabel(widget.executorRole)}"',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom styled dropdown button
        InkWell(
          onTap: () => _showEmployeeSelector(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _selectedEmployee != null
                  ? AppColors.primary.withOpacity(0.05)
                  : context.surfaceColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _selectedEmployee != null
                    ? AppColors.primary.withOpacity(0.3)
                    : context.borderColor,
                width: _selectedEmployee != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                if (_selectedEmployee != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        _selectedEmployee!.name.isNotEmpty
                            ? _selectedEmployee!.name[0].toUpperCase()
                            : '?',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedEmployee!.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          context.read<AppProvider>().getRoleLabel(_selectedEmployee!.role),
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.person_search_outlined,
                    color: context.textSecondaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Выберите сотрудника',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
                Icon(
                  Icons.keyboard_arrow_down,
                  color: context.textSecondaryColor,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Отмена'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedEmployee == null || _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Добавить'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEmployeeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Выберите сотрудника',
                          style: AppTypography.h4,
                        ),
                        Text(
                          '${widget.employees.length} доступно',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.textSecondaryColor),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Employee list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: widget.employees.length,
                itemBuilder: (context, index) {
                  final employee = widget.employees[index];
                  final isSelected = _selectedEmployee?.id == employee.id;
                  return _EmployeeListTile(
                    employee: employee,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _selectedEmployee = employee);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_selectedEmployee == null) return;

    setState(() => _isSaving = true);

    try {
      final api = _api;
      await api.createOrderAssignment(
        orderId: widget.orderId,
        stepName: widget.stepName,
        employeeId: _selectedEmployee!.id,
      );
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Ошибка: $e');
        setState(() => _isSaving = false);
      }
    }
  }
}

class _EmployeeListTile extends StatelessWidget {
  final Employee employee;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmployeeListTile({
    required this.employee,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        color: isSelected ? AppColors.primary.withOpacity(0.08) : null,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [AppColors.primary, AppColors.primary.withOpacity(0.7)]
                      : [context.textSecondaryColor.withOpacity(0.2), context.textSecondaryColor.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                  style: AppTypography.h4.copyWith(
                    color: isSelected ? Colors.white : context.textSecondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.read<AppProvider>().getRoleLabel(employee.role),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
