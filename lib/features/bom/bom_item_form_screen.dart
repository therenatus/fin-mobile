import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/bom.dart';
import '../../core/models/material.dart' as mat;
import '../../core/riverpod/providers.dart';
import '../../core/utils/toast.dart';

/// Форма добавления/редактирования материала в BOM
class BomItemFormScreen extends ConsumerStatefulWidget {
  final Bom bom;
  final BomItem? item; // null for create, not null for edit

  const BomItemFormScreen({
    super.key,
    required this.bom,
    this.item,
  });

  @override
  ConsumerState<BomItemFormScreen> createState() => _BomItemFormScreenState();
}

class _BomItemFormScreenState extends ConsumerState<BomItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _wasteController = TextEditingController();
  final _notesController = TextEditingController();

  mat.Material? _selectedMaterial;
  List<mat.Material> _materials = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _initialized = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _quantityController.text = widget.item!.quantity.toString();
      _wasteController.text = widget.item!.wastePct.toString();
      _notesController.text = widget.item!.notes ?? '';
    } else {
      _wasteController.text = '5'; // Default waste %
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadMaterials());
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _wasteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(materialsNotifierProvider.notifier).loadMaterials();
      final materials = ref.read(materialsListProvider);
      setState(() {
        _materials = materials;
        _isLoading = false;

        // Pre-select material if editing
        if (_isEditing && widget.item!.materialId.isNotEmpty) {
          _selectedMaterial = materials.firstWhere(
            (m) => m.id == widget.item!.materialId,
            orElse: () => materials.first,
          );
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppToast.error(context, 'Ошибка загрузки материалов: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать материал' : 'Добавить материал'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Material selector
          _buildMaterialSelector(),
          const SizedBox(height: AppSpacing.lg),

          // Quantity
          TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: 'Количество *',
              hintText: 'Например: 1.5',
              prefixIcon: const Icon(Icons.straighten),
              suffixText: _selectedMaterial?.unit.label ?? '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Укажите количество';
              }
              final qty = double.tryParse(value);
              if (qty == null || qty <= 0) {
                return 'Количество должно быть больше 0';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Waste percentage
          TextFormField(
            controller: _wasteController,
            decoration: InputDecoration(
              labelText: 'Процент отходов',
              hintText: 'Например: 5',
              prefixIcon: const Icon(Icons.delete_outline),
              suffixText: '%',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              helperText: 'Учитывается при расчёте себестоимости',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final pct = double.tryParse(value);
                if (pct == null || pct < 0 || pct > 100) {
                  return 'Процент должен быть от 0 до 100';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Примечание',
              hintText: 'Дополнительные заметки',
              prefixIcon: const Icon(Icons.notes),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Cost preview
          if (_selectedMaterial != null)
            _buildCostPreview(),
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

  Widget _buildMaterialSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Материал *',
          style: AppTypography.labelLarge.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: _showMaterialPicker,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _selectedMaterial != null
                    ? AppColors.primary.withOpacity(0.5)
                    : context.borderColor,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _selectedMaterial != null
                        ? AppColors.info.withOpacity(0.1)
                        : context.surfaceVariantColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: _selectedMaterial != null
                        ? AppColors.info
                        : context.textSecondaryColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _selectedMaterial != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedMaterial!.name,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${_selectedMaterial!.sku} • ${_formatCost(_selectedMaterial!.costPrice)} сом/${_selectedMaterial!.unit.label}',
                              style: AppTypography.bodySmall.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Выберите материал',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: context.textSecondaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCostPreview() {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final wastePct = double.tryParse(_wasteController.text) ?? 0;
    final costPrice = _selectedMaterial?.costPrice ?? 0;

    final effectiveQty = qty * (1 + wastePct / 100);
    final totalCost = effectiveQty * costPrice;

    return Card(
      elevation: 0,
      color: AppColors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Расчёт стоимости',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _CostRow(
              label: 'Количество с отходами',
              value: '${_formatQuantity(effectiveQty)} ${_selectedMaterial?.unit.label ?? ''}',
            ),
            _CostRow(
              label: 'Цена за единицу',
              value: '${_formatCost(costPrice)} сом',
            ),
            const Divider(height: AppSpacing.md),
            _CostRow(
              label: 'Итого',
              value: '${_formatCost(totalCost)} сом',
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showMaterialPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
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
                    const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Выберите материал', style: AppTypography.h4),
                          Text(
                            '${_materials.length} доступно',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: _materials.length,
                  itemBuilder: (context, index) {
                    final material = _materials[index];
                    final isSelected = _selectedMaterial?.id == material.id;
                    return _MaterialListTile(
                      material: material,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedMaterial = material);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMaterial == null) {
      AppToast.warning(context, 'Выберите материал');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newItem = {
        'materialId': _selectedMaterial!.id,
        'quantity': double.parse(_quantityController.text),
        'wastePct': double.tryParse(_wasteController.text) ?? 5,
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
      };

      // Get current items
      List<Map<String, dynamic>> updatedItems;
      if (_isEditing) {
        // Update existing item
        updatedItems = widget.bom.items.map((i) {
          if (i.id == widget.item!.id) {
            return newItem;
          }
          return i.toJson();
        }).toList();
      } else {
        // Add new item
        updatedItems = [
          ...widget.bom.items.map((i) => i.toJson()),
          newItem,
        ];
      }

      await ref.read(bomNotifierProvider.notifier).updateBom(
        widget.bom.id,
        items: updatedItems,
      );

      if (mounted) {
        AppToast.success(context, _isEditing ? 'Материал обновлён' : 'Материал добавлен');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Ошибка: $e');
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatQuantity(double qty) {
    if (qty == qty.truncateToDouble()) {
      return qty.toStringAsFixed(0);
    }
    return qty.toStringAsFixed(2);
  }

  String _formatCost(double? cost) {
    if (cost == null) return '0';
    return cost.toStringAsFixed(0);
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const _CostRow({
    required this.label,
    required this.value,
    this.isPrimary = false,
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
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
              color: isPrimary ? AppColors.primary : context.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialListTile extends StatelessWidget {
  final mat.Material material;
  final bool isSelected;
  final VoidCallback onTap;

  const _MaterialListTile({
    required this.material,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                color: isSelected
                    ? AppColors.primary.withOpacity(0.15)
                    : context.surfaceVariantColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: isSelected ? AppColors.primary : context.textSecondaryColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.name,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  Text(
                    '${material.sku} • ${material.costPrice?.toStringAsFixed(0) ?? '0'} сом/${material.unit.label}',
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
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
