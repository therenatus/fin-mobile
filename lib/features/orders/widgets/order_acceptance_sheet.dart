import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/models/models.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/toast.dart';

class OrderAcceptanceSheet extends StatefulWidget {
  final Order order;
  final List<ProcessStep> processSteps;
  final List<Employee> employees;
  final VoidCallback onAccepted;

  const OrderAcceptanceSheet({
    super.key,
    required this.order,
    required this.processSteps,
    required this.employees,
    required this.onAccepted,
  });

  @override
  State<OrderAcceptanceSheet> createState() => _OrderAcceptanceSheetState();
}

class _OrderAcceptanceSheetState extends State<OrderAcceptanceSheet> {
  bool _isSubmitting = false;

  ApiService get _api => context.read<AppProvider>().api;

  /// Calculate total estimated hours for the order
  double get _totalEstimatedHours {
    if (widget.processSteps.isEmpty) return 0;
    final totalMinutes = widget.processSteps.fold<int>(
      0,
      (sum, step) => sum + step.estimatedTime,
    );
    return (totalMinutes * widget.order.quantity) / 60.0;
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final api = _api;

      // Update order status to in_progress
      await api.updateOrderStatus(widget.order.id, 'in_progress');

      if (mounted) {
        AppToast.success(context, 'Заказ принят в работу');
        widget.onAccepted();
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Ошибка: $e');
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Icon(Icons.assignment_turned_in_outlined,
                    color: AppColors.primary, size: 28),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Принять заказ',
                    style: AppTypography.h3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _buildOrderSummary(),
                const SizedBox(height: AppSpacing.lg),
                _buildDueDateInfo(),
              ],
            ),
          ),
          // Bottom action
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
              top: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              border: Border(top: BorderSide(color: context.borderColor)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: !_isSubmitting ? _submit : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isSubmitting ? 'Сохранение...' : 'Принять в работу'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Сводка заказа',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SummaryRow(
              label: 'Модель',
              value: widget.order.model?.name ?? 'Неизвестно',
            ),
            _SummaryRow(
              label: 'Количество',
              value: '${widget.order.quantity} шт.',
            ),
            _SummaryRow(
              label: 'Заказчик',
              value: widget.order.client?.name ?? 'Неизвестно',
            ),
            _SummaryRow(
              label: 'Стоимость',
              value: '${widget.order.totalPrice.toStringAsFixed(0)} \u20BD',
            ),
            if (widget.processSteps.isNotEmpty) ...[
              const Divider(height: 20),
              _SummaryRow(
                label: 'Трудозатраты',
                value: '${_totalEstimatedHours.toStringAsFixed(1)} ч',
                valueStyle: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              _SummaryRow(
                label: 'Этапов',
                value: '${widget.processSteps.length}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDueDateInfo() {
    final dueDate = widget.order.dueDate;

    return Card(
      elevation: 0,
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.borderColor),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.calendar_today, color: AppColors.warning, size: 20),
        ),
        title: const Text('Дата сдачи'),
        subtitle: Text(
          dueDate != null
              ? DateFormat('d MMMM yyyy', 'ru').format(dueDate)
              : 'Не указана',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
            style: valueStyle ??
                AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
