import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/employee_user.dart';

class RecordWorkScreen extends ConsumerStatefulWidget {
  final EmployeeAssignment assignment;

  const RecordWorkScreen({
    super.key,
    required this.assignment,
  });

  @override
  ConsumerState<RecordWorkScreen> createState() => _RecordWorkScreenState();
}

class _RecordWorkScreenState extends ConsumerState<RecordWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _hoursController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _isLoadingExisting = false;
  Map<String, dynamic>? _existingLog;

  EmployeeAssignment get assignment => widget.assignment;
  EmployeeAssignmentOrder get order => assignment.order;
  /// Max quantity this employee can still record (considering ALL employees' work)
  int get maxQuantityAvailable => order.totalRemaining;

  @override
  void initState() {
    super.initState();
    // Load existing record for today on init
    _loadExistingRecord(_selectedDate);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingRecord(DateTime date) async {
    setState(() => _isLoadingExisting = true);

    try {
      final notifier = ref.read(employeeAuthNotifierProvider.notifier);
      final existing = await notifier.getWorkLogByDate(assignment.id, date);

      if (mounted) {
        setState(() {
          _existingLog = existing;
          _isLoadingExisting = false;

          // Pre-fill form if existing record found
          if (existing != null) {
            _quantityController.text = existing['quantity'].toString();
            final hours = existing['hours'];
            _hoursController.text = hours != null && hours > 0
                ? hours.toString()
                : '';
          } else {
            _quantityController.clear();
            _hoursController.clear();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingExisting = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      locale: const Locale('ru'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      await _loadExistingRecord(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(employeeAuthNotifierProvider.notifier);
      final request = CreateWorkLogRequest(
        assignmentId: assignment.id,
        quantity: int.parse(_quantityController.text),
        hours: _hoursController.text.isNotEmpty
            ? double.parse(_hoursController.text.replaceAll(',', '.'))
            : null,
        date: _selectedDate.toIso8601String().split('T')[0],
      );

      await notifier.createWorkLog(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_existingLog != null ? 'Запись обновлена' : 'Работа записана'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ru');

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Записать работу'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order info card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.modelName,
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            assignment.stepName,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Сделано: ${order.totalCompletedQuantity}/${order.quantity}',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (maxQuantityAvailable > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          'Осталось записать: $maxQuantityAvailable шт',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              'Этап полностью выполнен',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Date picker (FIRST)
              Text(
                'Дата',
                style: AppTypography.labelMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _isLoadingExisting ? null : _selectDate,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: context.textTertiaryColor,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        dateFormat.format(_selectedDate),
                        style: AppTypography.bodyLarge,
                      ),
                      const Spacer(),
                      if (_isLoadingExisting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          Icons.chevron_right,
                          color: context.textTertiaryColor,
                        ),
                    ],
                  ),
                ),
              ),

              // Existing record indicator
              if (_existingLog != null && !_isLoadingExisting) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Редактирование записи за ${dateFormat.format(_selectedDate)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Quantity field
              Text(
                'Количество',
                style: AppTypography.labelMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !_isLoadingExisting,
                decoration: InputDecoration(
                  hintText: 'Введите количество',
                  prefixIcon: Icon(
                    Icons.numbers,
                    color: context.textTertiaryColor,
                  ),
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.error, width: 1),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите количество';
                  }
                  final qty = int.tryParse(value);
                  if (qty == null || qty <= 0) {
                    return 'Введите положительное число';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Hours field (optional)
              Text(
                'Затраченные часы (опционально)',
                style: AppTypography.labelMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _hoursController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                enabled: !_isLoadingExisting,
                decoration: InputDecoration(
                  hintText: 'Например: 2.5',
                  prefixIcon: Icon(
                    Icons.timer_outlined,
                    color: context.textTertiaryColor,
                  ),
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final hours = double.tryParse(value.replaceAll(',', '.'));
                    if (hours == null || hours <= 0) {
                      return 'Введите положительное число';
                    }
                    if (hours > 24) {
                      return 'Максимум 24 часа';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Submit button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _isLoadingExisting || (maxQuantityAvailable <= 0 && _existingLog == null))
                      ? null
                      : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_existingLog != null
                          ? 'Обновить'
                          : (maxQuantityAvailable <= 0 ? 'Этап завершён' : 'Сохранить')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
