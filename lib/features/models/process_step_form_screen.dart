import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/process_step.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/widgets/styled_dropdown.dart';

class ProcessStepFormScreen extends StatefulWidget {
  final String modelId;
  final ProcessStep? step;
  final int? nextOrder;

  const ProcessStepFormScreen({
    super.key,
    required this.modelId,
    this.step,
    this.nextOrder,
  });

  @override
  State<ProcessStepFormScreen> createState() => _ProcessStepFormScreenState();
}

class _ProcessStepFormScreenState extends State<ProcessStepFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _timeController = TextEditingController();
  final _rateController = TextEditingController();

  String _executorRole = 'tailor';
  bool _isLoading = false;

  bool get _isEditing => widget.step != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final step = widget.step!;
      _nameController.text = step.name;
      _timeController.text = step.estimatedTime.toString();
      _executorRole = step.executorRole;
      if (step.rate != null) {
        _rateController.text = step.rate!.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать этап' : 'Новый этап'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
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
            Text(
              'Основная информация',
              style: AppTypography.labelLarge.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название этапа *',
                hintText: 'Например: Раскрой ткани',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите название этапа';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            // Executor role
            ExecutorRoleDropdown(
              value: _executorRole,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _executorRole = value);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            // Time and Rate row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Время (мин) *',
                      hintText: '60',
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите время';
                      }
                      final time = int.tryParse(value);
                      if (time == null || time < 1) {
                        return 'Минимум 1';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
                    decoration: const InputDecoration(
                      labelText: 'Цена за шт. (₽)',
                      hintText: '500',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
            : Text(_isEditing ? 'Сохранить изменения' : 'Добавить этап'),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final api = ApiService(StorageService());
      final name = _nameController.text.trim();
      final estimatedTime = int.parse(_timeController.text);
      final rate = double.tryParse(_rateController.text);

      if (_isEditing) {
        await api.updateProcessStep(
          stepId: widget.step!.id,
          name: name,
          estimatedTime: estimatedTime,
          executorRole: _executorRole,
          rate: rate,
          rateType: rate != null ? 'per_unit' : null,
        );
      } else {
        await api.createProcessStep(
          modelId: widget.modelId,
          name: name,
          stepOrder: widget.nextOrder ?? 1,
          estimatedTime: estimatedTime,
          executorRole: _executorRole,
          rate: rate,
          rateType: rate != null ? 'per_unit' : null,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Этап обновлён' : 'Этап добавлен'),
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
