import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/models.dart';
import 'assigned_employee_row.dart';
import 'add_employee_form.dart';

/// Card displaying a production step with assignments
class WorkStepCard extends ConsumerStatefulWidget {
  final ProcessStep step;
  final List<Employee> employees;
  final Order order;
  final List<OrderAssignment> assignments;
  final List<WorkLog> workLogs;
  final VoidCallback onDataChanged;

  const WorkStepCard({
    super.key,
    required this.step,
    required this.employees,
    required this.order,
    required this.assignments,
    required this.workLogs,
    required this.onDataChanged,
  });

  @override
  ConsumerState<WorkStepCard> createState() => _WorkStepCardState();
}

class _WorkStepCardState extends ConsumerState<WorkStepCard> {
  bool _isAdding = false;

  List<Employee> get _filteredEmployees {
    final executorRole = widget.step.executorRole.toLowerCase();
    final assignedIds = widget.assignments.map((a) => a.employeeId).toSet();
    return widget.employees
        .where((emp) => emp.role.toLowerCase() == executorRole)
        .where((emp) => !assignedIds.contains(emp.id))
        .toList();
  }

  int get _totalLoggedQuantity {
    return widget.workLogs.fold(0, (sum, log) => sum + log.quantity);
  }

  int get _remainingQuantity {
    return widget.order.quantity - _totalLoggedQuantity;
  }

  bool get _isStepComplete {
    return _totalLoggedQuantity >= widget.order.quantity;
  }

  @override
  Widget build(BuildContext context) {
    final hasAssignments = widget.assignments.isNotEmpty;

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
            _buildHeader(context),
            if (widget.assignments.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              ...widget.assignments.map((assignment) {
                final workLog = widget.workLogs
                    .where((w) => w.employeeId == assignment.employeeId)
                    .firstOrNull;
                return AssignedEmployeeRow(
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
            const SizedBox(height: AppSpacing.sm),
            if (_isAdding)
              AddEmployeeForm(
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

  Widget _buildHeader(BuildContext context) {
    return Row(
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
                    ref.read(dashboardNotifierProvider).getRoleLabel(widget.step.executorRole),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  if (widget.step.rate != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• ${widget.step.rate!.toStringAsFixed(0)} сом/${widget.step.rateType == 'per_hour' ? 'ч' : 'ед'}',
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
    );
  }
}
