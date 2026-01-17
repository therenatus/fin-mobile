import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/bom.dart';
import '../../core/providers/bom_provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/utils/toast.dart';

/// Форма добавления/редактирования операции в BOM
class BomOperationFormScreen extends StatefulWidget {
  final Bom bom;
  final BomOperation? operation; // null for create, not null for edit
  final int? nextSequence; // For new operation

  const BomOperationFormScreen({
    super.key,
    required this.bom,
    this.operation,
    this.nextSequence,
  });

  @override
  State<BomOperationFormScreen> createState() => _BomOperationFormScreenState();
}

class _BomOperationFormScreenState extends State<BomOperationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sequenceController = TextEditingController();
  final _setupTimeController = TextEditingController();
  final _unitTimeController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  String? _selectedRole;
  bool _isSaving = false;

  bool get _isEditing => widget.operation != null;

  BomProvider get _bomProvider => context.read<BomProvider>();

  // Available roles
  static const _roles = [
    {'value': 'cutter', 'label': 'Раскройщик'},
    {'value': 'seamstress', 'label': 'Швея'},
    {'value': 'presser', 'label': 'Утюжильщик'},
    {'value': 'tailor', 'label': 'Портной'},
    {'value': 'fitter', 'label': 'Примерщик'},
    {'value': 'finisher', 'label': 'Отделочник'},
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.operation!.name;
      _sequenceController.text = widget.operation!.sequence.toString();
      _setupTimeController.text = widget.operation!.setupTime.toString();
      _unitTimeController.text = widget.operation!.unitTime.toString();
      if (widget.operation!.hourlyRate != null) {
        _hourlyRateController.text = widget.operation!.hourlyRate!.toStringAsFixed(0);
      }
      _selectedRole = widget.operation!.requiredRole;
    } else {
      _sequenceController.text = (widget.nextSequence ?? 1).toString();
      _setupTimeController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sequenceController.dispose();
    _setupTimeController.dispose();
    _unitTimeController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать операцию' : 'Добавить операцию'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Название операции *',
              hintText: 'Например: Раскрой',
              prefixIcon: const Icon(Icons.build_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Укажите название операции';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Sequence and Role row
          Row(
            children: [
              // Sequence
              Expanded(
                child: TextFormField(
                  controller: _sequenceController,
                  decoration: InputDecoration(
                    labelText: 'Порядок *',
                    hintText: '1',
                    prefixIcon: const Icon(Icons.format_list_numbered),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Укажите порядок';
                    }
                    final seq = int.tryParse(value);
                    if (seq == null || seq < 1) {
                      return 'Минимум 1';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Role selector
              Expanded(
                flex: 2,
                child: _buildRoleSelector(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Time section
          Text(
            'Время выполнения',
            style: AppTypography.labelLarge.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              // Setup time
              Expanded(
                child: TextFormField(
                  controller: _setupTimeController,
                  decoration: InputDecoration(
                    labelText: 'Наладка',
                    hintText: '0',
                    suffixText: 'мин',
                    prefixIcon: const Icon(Icons.settings_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    helperText: 'Подготовка',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Unit time
              Expanded(
                child: TextFormField(
                  controller: _unitTimeController,
                  decoration: InputDecoration(
                    labelText: 'Работа *',
                    hintText: '30',
                    suffixText: 'мин',
                    prefixIcon: const Icon(Icons.timer_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    helperText: 'На 1 единицу',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Укажите время';
                    }
                    final time = int.tryParse(value);
                    if (time == null || time < 1) {
                      return 'Минимум 1 мин';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Hourly rate (optional)
          TextFormField(
            controller: _hourlyRateController,
            decoration: InputDecoration(
              labelText: 'Ставка в час',
              hintText: 'Будет использована ставка из настроек',
              prefixIcon: const Icon(Icons.attach_money),
              suffixText: '₽/ч',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              helperText: 'Оставьте пустым для использования ставки по умолчанию',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Time preview
          _buildTimePreview(),
          const SizedBox(height: AppSpacing.xl),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Сохранить' : 'Добавить'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Роль исполнителя',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Не указана'),
        ),
        ..._roles.map((role) => DropdownMenuItem<String>(
              value: role['value'],
              child: Text(role['label']!),
            )),
      ],
      onChanged: (value) {
        setState(() => _selectedRole = value);
      },
    );
  }

  Widget _buildTimePreview() {
    final setupTime = int.tryParse(_setupTimeController.text) ?? 0;
    final unitTime = int.tryParse(_unitTimeController.text) ?? 0;
    final totalTime = setupTime + unitTime;

    return Card(
      elevation: 0,
      color: AppColors.success.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.schedule,
                color: AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Общее время операции',
                    style: AppTypography.labelMedium.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(totalTime),
                    style: AppTypography.h4.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes мин';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours ч';
    return '$hours ч $mins мин';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newOperation = {
        'name': _nameController.text.trim(),
        'sequence': int.parse(_sequenceController.text),
        'setupTime': int.tryParse(_setupTimeController.text) ?? 0,
        'unitTime': int.parse(_unitTimeController.text),
        if (_hourlyRateController.text.isNotEmpty)
          'hourlyRate': double.parse(_hourlyRateController.text),
        if (_selectedRole != null) 'requiredRole': _selectedRole,
      };

      // Get current operations
      List<Map<String, dynamic>> updatedOperations;
      if (_isEditing) {
        // Update existing operation
        updatedOperations = widget.bom.operations.map((o) {
          if (o.id == widget.operation!.id) {
            return newOperation;
          }
          return o.toJson();
        }).toList();
      } else {
        // Add new operation
        updatedOperations = [
          ...widget.bom.operations.map((o) => o.toJson()),
          newOperation,
        ];
      }

      await _bomProvider.updateBom(
        widget.bom.id,
        operations: updatedOperations,
      );

      if (mounted) {
        AppToast.success(context, _isEditing ? 'Операция обновлена' : 'Операция добавлена');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Ошибка: $e');
        setState(() => _isSaving = false);
      }
    }
  }
}
