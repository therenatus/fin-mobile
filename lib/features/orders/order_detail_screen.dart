import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/models/models.dart';
import '../../core/utils/toast.dart';
import 'widgets/widgets.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  late Order _order;
  List<ProcessStep> _processSteps = [];
  List<Employee> _employees = [];
  List<OrderAssignment> _assignments = [];
  List<WorkLog> _workLogs = [];
  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  bool _initialized = false;

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
      final api = ref.read(apiServiceProvider);

      if (_order.model != null) {
        final steps = await api.getProcessSteps(_order.model!.id);
        _processSteps = steps..sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
      }

      _employees = await api.getEmployees();
      _assignments = await api.getOrderAssignments(_order.id);

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
          OrderStatusChip(status: _order.status),
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
                        ClientSectionCard(client: _order.client),
                        const SizedBox(height: AppSpacing.lg),
                        OrderDetailsCard(order: _order),
                        const SizedBox(height: AppSpacing.lg),
                        if (_order.status == OrderStatus.inProgress ||
                            _order.status == OrderStatus.completed) ...[
                          _buildCostSection(),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        if (_order.status == OrderStatus.inProgress) ...[
                          ProductionProgressCard(
                            order: _order,
                            processSteps: _processSteps,
                            workLogs: _workLogs,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildProductionSection(),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        OrderActionsSection(
                          order: _order,
                          isUpdatingStatus: _isUpdatingStatus,
                          onAcceptOrder: _showOrderAcceptanceSheet,
                          onChangeStatus: _showStatusPicker,
                          onCompleteOrder: () => _updateStatus(OrderStatus.completed),
                        ),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCostSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calculate_outlined, size: 18, color: context.textSecondaryColor),
            const SizedBox(width: 8),
            Text(
              'Себестоимость',
              style: AppTypography.labelLarge.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        OrderCostCard(orderId: _order.id),
      ],
    );
  }

  Widget _buildProductionSection() {
    if (_processSteps.isEmpty) {
      return _buildEmptyProductionSection();
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
          final stepAssignments = _assignments
              .where((a) => a.stepName.toLowerCase() == step.name.toLowerCase())
              .toList();
          final stepWorkLogs = _workLogs
              .where((w) => w.step.toLowerCase() == step.name.toLowerCase())
              .toList();

          return WorkStepCard(
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

  Widget _buildEmptyProductionSection() {
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
          children: [
            Row(
              children: [
                Icon(Icons.construction_outlined, size: 18, color: context.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Производство',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
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
      ),
    );
  }

  void _showStatusPicker() {
    StatusPickerSheet.show(
      context,
      currentStatus: _order.status,
      onStatusSelected: _updateStatus,
    );
  }

  Future<void> _updateStatus(OrderStatus newStatus) async {
    setState(() => _isUpdatingStatus = true);

    try {
      final api = ref.read(apiServiceProvider);
      await api.updateOrderStatus(_order.id, newStatus.value);

      if (mounted) {
        final updatedOrder = await api.getOrder(_order.id);
        setState(() {
          _order = updatedOrder;
        });

        ref.read(dashboardNotifierProvider.notifier).refreshDashboard();

        AppToast.success(
          context,
          'Статус изменён на "${OrderStatusChip.getStatusLabel(newStatus)}"',
        );

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
      builder: (ctx) => OrderAcceptanceSheet(
        order: _order,
        processSteps: _processSteps,
        employees: _employees,
        onAccepted: () {
          Navigator.pop(ctx);
          _loadData();
          ref.read(dashboardNotifierProvider.notifier).refreshDashboard();
        },
      ),
    );
  }
}
