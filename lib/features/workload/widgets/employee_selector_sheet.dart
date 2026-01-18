import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Bottom sheet for selecting an employee filter
class EmployeeSelectorSheet extends StatefulWidget {
  final List employees;
  final String? selectedEmployeeId;
  final ValueChanged<String?> onEmployeeSelected;

  const EmployeeSelectorSheet({
    super.key,
    required this.employees,
    this.selectedEmployeeId,
    required this.onEmployeeSelected,
  });

  static void show(
    BuildContext context, {
    required List employees,
    String? selectedEmployeeId,
    required ValueChanged<String?> onEmployeeSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmployeeSelectorSheet(
        employees: employees,
        selectedEmployeeId: selectedEmployeeId,
        onEmployeeSelected: onEmployeeSelected,
      ),
    );
  }

  @override
  State<EmployeeSelectorSheet> createState() => _EmployeeSelectorSheetState();
}

class _EmployeeSelectorSheetState extends State<EmployeeSelectorSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredEmployees = query.isEmpty
        ? widget.employees
        : widget.employees.where((e) {
            final name = (e['name'] as String? ?? '').toLowerCase();
            return name.contains(query);
          }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          _buildHandle(context),
          _buildHeader(context),
          _buildSearchField(context),
          const SizedBox(height: AppSpacing.sm),
          _buildAllEmployeesOption(context),
          const Divider(),
          Expanded(
            child: filteredEmployees.isEmpty
                ? _buildEmptyState(context)
                : _buildEmployeeList(context, filteredEmployees),
          ),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Text(
            'Выберите сотрудника',
            style: AppTypography.h4.copyWith(color: context.textPrimaryColor),
          ),
          const Spacer(),
          Text(
            '${widget.employees.length} чел.',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Поиск по имени...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: context.surfaceVariantColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAllEmployeesOption(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.groups_outlined, color: AppColors.primary, size: 20),
      ),
      title: const Text('Все сотрудники'),
      trailing: widget.selectedEmployeeId == null
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        Navigator.pop(context);
        widget.onEmployeeSelected(null);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: context.textTertiaryColor),
          const SizedBox(height: 12),
          Text(
            'Сотрудники не найдены',
            style: AppTypography.bodyMedium.copyWith(color: context.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(BuildContext context, List filteredEmployees) {
    return ListView.builder(
      itemCount: filteredEmployees.length,
      itemBuilder: (context, index) {
        final emp = filteredEmployees[index];
        final id = emp['id'] as String;
        final name = emp['name'] as String? ?? '';
        final isSelected = widget.selectedEmployeeId == id;

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
            widget.onEmployeeSelected(id);
          },
        );
      },
    );
  }
}
