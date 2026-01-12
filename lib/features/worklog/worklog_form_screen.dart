import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/models/models.dart';
import '../../core/services/api_service.dart';

class WorkLogFormScreen extends StatefulWidget {
  const WorkLogFormScreen({super.key});

  @override
  State<WorkLogFormScreen> createState() => _WorkLogFormScreenState();
}

class _WorkLogFormScreenState extends State<WorkLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _hoursController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _initialized = false;

  List<Order> _orders = [];
  List<Employee> _employees = [];
  List<ProcessStep> _processSteps = [];

  Order? _selectedOrder;
  Employee? _selectedEmployee;
  ProcessStep? _selectedStep;
  DateTime _selectedDate = DateTime.now();

  ApiService get _api => context.read<AppProvider>().api;

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

  @override
  void dispose() {
    _quantityController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    try {
      final api = _api;
      final ordersResponse = await api.getOrders(limit: 100);
      final employees = await api.getEmployees();

      print('DEBUG WorkLogForm: Orders loaded: ${ordersResponse.orders.length}');
      print('DEBUG WorkLogForm: Employees loaded: ${employees.length}');

      setState(() {
        // Filter only in_progress orders
        _orders = ordersResponse.orders
            .where((o) => o.status == OrderStatus.inProgress)
            .toList();
        _employees = employees;
        _isLoadingData = false;
      });

      print('DEBUG WorkLogForm: In-progress orders: ${_orders.length}');
    } catch (e) {
      print('DEBUG WorkLogForm: Error loading data: $e');
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки данных: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadProcessSteps(String modelId) async {
    try {
      final api = _api;
      final steps = await api.getProcessSteps(modelId);
      setState(() {
        _processSteps = steps..sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
        _selectedStep = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки этапов: $e'),
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
      appBar: AppBar(
        title: const Text('Добавить запись'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSection(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildEmployeeSection(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildStepSection(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildQuantitySection(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDateSection(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSubmitButton(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderSection() {
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
                Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Заказ',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_orders.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: context.textSecondaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Нет заказов в работе',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<Order>(
                value: _selectedOrder,
                decoration: const InputDecoration(
                  labelText: 'Выберите заказ *',
                  prefixIcon: Icon(Icons.assignment_outlined),
                ),
                items: _orders.map((order) {
                  return DropdownMenuItem(
                    value: order,
                    child: Text(
                      '${order.model?.name ?? 'Заказ'} - ${order.client?.name ?? 'Заказчик'}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (order) {
                  setState(() {
                    _selectedOrder = order;
                    _processSteps = [];
                    _selectedStep = null;
                  });
                  if (order?.model != null) {
                    _loadProcessSteps(order!.model!.id);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Выберите заказ';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeSection() {
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
                Icon(Icons.person_outline, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Сотрудник',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_employees.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: context.textSecondaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Нет сотрудников. Сначала добавьте сотрудников.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<Employee>(
              value: _selectedEmployee,
              decoration: const InputDecoration(
                labelText: 'Выберите сотрудника *',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              items: _employees.map((emp) {
                return DropdownMenuItem(
                  value: emp,
                  child: Text('${emp.name} (${emp.role})'),
                );
              }).toList(),
              onChanged: (emp) {
                setState(() => _selectedEmployee = emp);
              },
              validator: (value) {
                if (value == null) {
                  return 'Выберите сотрудника';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepSection() {
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
                Icon(Icons.construction_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Этап работы',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_selectedOrder == null)
              Text(
                'Сначала выберите заказ',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
              )
            else if (_processSteps.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: context.textSecondaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Для этой модели нет этапов. Добавьте этапы в настройках модели.',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _processSteps.map((step) {
                  final isSelected = _selectedStep?.id == step.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: InkWell(
                      onTap: () => setState(() => _selectedStep = step),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : context.surfaceVariantColor,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : context.textSecondaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  '${step.stepOrder}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : context.textSecondaryColor,
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
                                    step.name,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (step.rate != null)
                                    Text(
                                      step.formattedRate,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    final rateType = _selectedStep?.rateType ?? 'per_unit';

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
                Icon(Icons.numbers, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Объём работы',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Количество (шт)',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (rateType == 'per_unit' &&
                          (value == null || value.isEmpty)) {
                        return 'Введите количество';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _hoursController,
                    decoration: const InputDecoration(
                      labelText: 'Часы',
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    validator: (value) {
                      if (rateType == 'per_hour' &&
                          (value == null || value.isEmpty)) {
                        return 'Введите часы';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (_selectedStep?.rate != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                rateType == 'per_hour'
                    ? 'Оплата за час: ${_selectedStep!.rate!.toStringAsFixed(0)} руб.'
                    : 'Оплата за единицу: ${_selectedStep!.rate!.toStringAsFixed(0)} руб.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
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
                Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Дата',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event, color: context.textSecondaryColor),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      DateFormat('d MMMM yyyy', 'ru').format(_selectedDate),
                      style: AppTypography.bodyLarge,
                    ),
                    const Spacer(),
                    Icon(Icons.edit, size: 18, color: context.textSecondaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: const Locale('ru'),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Сохранить запись'),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedOrder == null ||
        _selectedEmployee == null ||
        _selectedStep == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните все обязательные поля'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = _api;
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final hours = double.tryParse(_hoursController.text) ?? 0;

      await api.createWorkLog(
        employeeId: _selectedEmployee!.id,
        orderId: _selectedOrder!.id,
        step: _selectedStep!.name,
        quantity: quantity,
        hours: hours,
        date: _selectedDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Запись добавлена'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
