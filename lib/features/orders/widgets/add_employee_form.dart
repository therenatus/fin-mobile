import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/toast.dart';

/// Form for adding an employee to a production step
class AddEmployeeForm extends ConsumerStatefulWidget {
  final List<Employee> employees;
  final String orderId;
  final String stepName;
  final String executorRole;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const AddEmployeeForm({
    super.key,
    required this.employees,
    required this.orderId,
    required this.stepName,
    required this.executorRole,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  ConsumerState<AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends ConsumerState<AddEmployeeForm> {
  Employee? _selectedEmployee;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    if (widget.employees.isEmpty) {
      return _buildNoEmployeesMessage(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEmployeeSelectorButton(context),
        const SizedBox(height: AppSpacing.sm),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildNoEmployeesMessage(BuildContext context) {
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
              'Нет доступных сотрудников с ролью "${ref.read(dashboardNotifierProvider).getRoleLabel(widget.executorRole)}"',
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

  Widget _buildEmployeeSelectorButton(BuildContext context) {
    return InkWell(
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
              _buildSelectedEmployeeAvatar(),
              const SizedBox(width: 12),
              _buildSelectedEmployeeInfo(),
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
    );
  }

  Widget _buildSelectedEmployeeAvatar() {
    return Container(
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
    );
  }

  Widget _buildSelectedEmployeeInfo() {
    return Expanded(
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
            ref.read(dashboardNotifierProvider).getRoleLabel(_selectedEmployee!.role),
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
    );
  }

  void _showEmployeeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EmployeeSelectorSheet(
        employees: widget.employees,
        selectedEmployee: _selectedEmployee,
        onSelected: (employee) {
          setState(() => _selectedEmployee = employee);
        },
      ),
    );
  }

  Future<void> _save() async {
    if (_selectedEmployee == null) return;

    setState(() => _isSaving = true);

    try {
      final api = ref.read(apiServiceProvider);
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

class _EmployeeSelectorSheet extends ConsumerWidget {
  final List<Employee> employees;
  final Employee? selectedEmployee;
  final ValueChanged<Employee> onSelected;

  const _EmployeeSelectorSheet({
    required this.employees,
    this.selectedEmployee,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
          _buildHandle(context),
          _buildHeader(context),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                final isSelected = selectedEmployee?.id == employee.id;
                return _EmployeeListTile(
                  employee: employee,
                  isSelected: isSelected,
                  onTap: () {
                    onSelected(employee);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.borderColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.people_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Выберите сотрудника', style: AppTypography.h4),
                Text(
                  '${employees.length} доступно',
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
    );
  }
}

class _EmployeeListTile extends ConsumerWidget {
  final Employee employee;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmployeeListTile({
    required this.employee,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    ref.read(dashboardNotifierProvider).getRoleLabel(employee.role),
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
