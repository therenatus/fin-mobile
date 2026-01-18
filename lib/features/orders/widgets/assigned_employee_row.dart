import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/toast.dart';

/// Row displaying an assigned employee with work log editing
class AssignedEmployeeRow extends ConsumerStatefulWidget {
  final OrderAssignment assignment;
  final WorkLog? workLog;
  final String orderId;
  final String stepName;
  final String? rateType;
  final int orderQuantity;
  final int remainingQuantity;
  final VoidCallback onDataChanged;

  const AssignedEmployeeRow({
    super.key,
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
  ConsumerState<AssignedEmployeeRow> createState() => _AssignedEmployeeRowState();
}

class _AssignedEmployeeRowState extends ConsumerState<AssignedEmployeeRow> {
  bool _isDeleting = false;
  bool _isEditing = false;
  final _quantityController = TextEditingController();
  bool _isSaving = false;

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
          _buildEmployeeInfoRow(context, employeeName, hasWorkLog),
          if (_isEditing) _buildWorkLogForm(context, hasWorkLog),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfoRow(BuildContext context, String employeeName, bool hasWorkLog) {
    return Row(
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
    );
  }

  Widget _buildWorkLogForm(BuildContext context, bool hasWorkLog) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.sm),
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
    );
  }

  Future<void> _saveWorkLog() async {
    final quantity = int.tryParse(_quantityController.text) ?? 0;

    if (quantity == 0) {
      AppToast.warning(context, 'Укажите количество');
      return;
    }

    if (quantity > _maxQuantity) {
      AppToast.error(
        context,
        'Превышен лимит! Макс: $_maxQuantity шт. (всего в заказе: ${widget.orderQuantity})',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final api = ref.read(apiServiceProvider);
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
      final api = ref.read(apiServiceProvider);
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
