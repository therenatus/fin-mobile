import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/riverpod/providers.dart';
import 'employee_form_screen.dart';
import 'employee_worklogs_screen.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  String? _roleFilter;
  bool? _activeFilter; // null = all, true = active, false = inactive
  bool _isLoading = true;
  List<Employee> _employees = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadEmployees());
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value.toLowerCase();
      });
    });
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final employees = await api.getEmployees();
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.loadingError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      drawer: const AppDrawer(currentRoute: 'employees'),
      appBar: AppBar(
        title: Text(context.l10n.employees),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          _buildRoleFilterButton(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: AppSearchBar(
                  controller: _searchController,
                  hint: context.l10n.searchEmployees,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _searchDebounce?.cancel();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool?>(
                    segments: [
                      ButtonSegment(value: null, label: Text(context.l10n.all)),
                      ButtonSegment(value: true, label: Text(context.l10n.activeEmployees)),
                      ButtonSegment(value: false, label: Text(context.l10n.inactiveEmployees)),
                    ],
                    selected: {_activeFilter},
                    onSelectionChanged: (selected) {
                      setState(() => _activeFilter = selected.first);
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildEmployeesList(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'employees_fab',
        onPressed: () => _openEmployeeForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: Text(context.l10n.add),
      ),
    );
  }

  Widget _buildRoleFilterButton() {
    final roles = ref.watch(employeeRolesProvider);
    return PopupMenuButton<String?>(
      icon: Badge(
        isLabelVisible: _roleFilter != null,
        child: const Icon(Icons.filter_list),
      ),
      tooltip: context.l10n.filterByRole,
      onSelected: (value) {
        setState(() => _roleFilter = value);
      },
      itemBuilder: (ctx) => [
        _buildFilterOption(ctx, null, context.l10n.allRoles),
        const PopupMenuDivider(),
        ...roles.map((role) => _buildFilterOption(ctx, role.code, role.label)),
      ],
    );
  }

  PopupMenuItem<String?> _buildFilterOption(BuildContext context, String? value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            _roleFilter == value ? Icons.check : Icons.circle_outlined,
            size: 18,
            color: _roleFilter == value ? AppColors.primary : context.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: _roleFilter == value ? AppColors.primary : context.textPrimaryColor,
              fontWeight: _roleFilter == value ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesList() {
    var filteredEmployees = _employees;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filteredEmployees = filteredEmployees.where((employee) {
        final name = employee.name.toLowerCase();
        final role = employee.role.toLowerCase();
        final phone = employee.phone?.toLowerCase() ?? '';
        return name.contains(_searchQuery) ||
            role.contains(_searchQuery) ||
            phone.contains(_searchQuery);
      }).toList();
    }

    // Role filter
    if (_roleFilter != null) {
      filteredEmployees = filteredEmployees.where((employee) {
        return employee.role == _roleFilter;
      }).toList();
    }

    // Active filter
    if (_activeFilter != null) {
      filteredEmployees = filteredEmployees.where((employee) {
        return employee.isActive == _activeFilter;
      }).toList();
    }

    final hasFilters = _searchQuery.isNotEmpty || _roleFilter != null || _activeFilter != null;

    if (filteredEmployees.isEmpty) {
      return EmptyState(
        icon: Icons.people_alt_outlined,
        title: hasFilters
            ? context.l10n.noResults
            : context.l10n.noEmployees,
        subtitle: hasFilters
            ? context.l10n.tryDifferentFilters
            : context.l10n.addFirstEmployee,
        actionLabel: !hasFilters
            ? context.l10n.addEmployee
            : null,
        onAction: !hasFilters
            ? () => _openEmployeeForm()
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: filteredEmployees.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final employee = filteredEmployees[index];
          return _EmployeeCard(
            employee: employee,
            onTap: () => _showEmployeeDetails(employee),
          );
        },
      ),
    );
  }

  void _showEmployeeDetails(Employee employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EmployeeDetailsSheet(
        employee: employee,
        onEdit: () => _openEmployeeForm(employee: employee),
        onToggleActive: () => _confirmToggleActive(employee),
        onViewHistory: () => _openEmployeeWorkLogs(employee),
      ),
    );
  }

  void _openEmployeeWorkLogs(Employee employee) {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeWorklogsScreen(employee: employee),
      ),
    );
  }

  Future<void> _openEmployeeForm({Employee? employee}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeFormScreen(employee: employee),
      ),
    );
    if (result == true) {
      _loadEmployees();
    }
  }

  void _confirmToggleActive(Employee employee) {
    final willDeactivate = employee.isActive;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(willDeactivate ? 'Деактивировать сотрудника?' : 'Активировать сотрудника?'),
        content: Text(willDeactivate
            ? '${employee.name} будет отключён от приложения и не сможет принимать задачи.'
            : '${employee.name} снова сможет входить в приложение и принимать задачи.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Close bottom sheet
              try {
                final api = ref.read(apiServiceProvider);
                await api.setEmployeeActiveStatus(employee.id, !willDeactivate);
                _loadEmployees();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(willDeactivate
                          ? 'Сотрудник деактивирован'
                          : 'Сотрудник активирован'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${context.l10n.error}: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              willDeactivate ? 'Деактивировать' : 'Активировать',
              style: TextStyle(color: willDeactivate ? AppColors.error : AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends ConsumerWidget {
  final Employee employee;
  final VoidCallback onTap;

  const _EmployeeCard({
    required this.employee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final roleLabel = dashboardState.getRoleLabel(employee.role);

    return Card(
      elevation: 0,
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              (employee.name.isNotEmpty ? employee.name.substring(0, 1).toUpperCase() : '?'),
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        title: Text(
          employee.name,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                roleLabel,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (employee.phone != null) ...[
              const SizedBox(height: 4),
              Text(
                employee.phone!,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: context.textTertiaryColor,
        ),
      ),
    );
  }
}

class _EmployeeDetailsSheet extends ConsumerWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onViewHistory;

  const _EmployeeDetailsSheet({
    required this.employee,
    required this.onEdit,
    required this.onToggleActive,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final roleLabel = dashboardState.getRoleLabel(employee.role);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      (employee.name.isNotEmpty ? employee.name.substring(0, 1).toUpperCase() : '?'),
                      style: AppTypography.h2.copyWith(
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
                        employee.name,
                        style: AppTypography.h3.copyWith(
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          roleLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (employee.phone != null || employee.email != null) ...[
                    _DetailSection(
                      title: context.l10n.contacts,
                      icon: Icons.contact_phone_outlined,
                      children: [
                        if (employee.phone != null)
                          _DetailRow(
                            label: context.l10n.phone,
                            value: employee.phone!,
                          ),
                        if (employee.email != null)
                          _DetailRow(
                            label: context.l10n.email,
                            value: employee.email!,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // View History button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onViewHistory,
                      icon: const Icon(Icons.history),
                      label: Text(context.l10n.workHistory),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onToggleActive();
                          },
                          icon: Icon(
                            employee.isActive ? Icons.person_off_outlined : Icons.person_add_outlined,
                            color: employee.isActive ? AppColors.error : AppColors.success,
                          ),
                          label: Text(
                            employee.isActive ? 'Деактивировать' : 'Активировать',
                            style: TextStyle(
                              color: employee.isActive ? AppColors.error : AppColors.success,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: (employee.isActive ? AppColors.error : AppColors.success).withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onEdit();
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(context.l10n.editAction),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surfaceVariantColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
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
            style: AppTypography.bodyMedium.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
