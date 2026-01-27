import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/material.dart' as mat;
import '../../core/models/supplier.dart';
import '../../core/riverpod/providers.dart';

class MaterialFormScreen extends ConsumerStatefulWidget {
  final mat.Material? material;

  const MaterialFormScreen({super.key, this.material});

  @override
  ConsumerState<MaterialFormScreen> createState() => _MaterialFormScreenState();
}

class _MaterialFormScreenState extends ConsumerState<MaterialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Supplier> _suppliers = [];
  bool _loadingSuppliers = true;

  // Controllers
  late final TextEditingController _skuController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minStockController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellPriceController;
  late final TextEditingController _colorController;
  late final TextEditingController _widthController;
  late final TextEditingController _compositionController;
  late final TextEditingController _barcodeController;

  // Dropdown values
  mat.MaterialUnit _unit = mat.MaterialUnit.meter;
  String? _categoryId;
  String? _supplierId;

  bool get _isEditing => widget.material != null;

  @override
  void initState() {
    super.initState();
    final m = widget.material;

    _skuController = TextEditingController(text: m?.sku ?? '');
    _nameController = TextEditingController(text: m?.name ?? '');
    _descriptionController = TextEditingController(text: m?.description ?? '');
    _quantityController = TextEditingController(
      text: _isEditing ? '' : '0',
    );
    _minStockController = TextEditingController(
      text: m?.minStockLevel?.toStringAsFixed(0) ?? '',
    );
    _costPriceController = TextEditingController(
      text: m?.costPrice?.toStringAsFixed(2) ?? '',
    );
    _sellPriceController = TextEditingController(
      text: m?.sellPrice?.toStringAsFixed(2) ?? '',
    );
    _colorController = TextEditingController(text: m?.color ?? '');
    _widthController = TextEditingController(
      text: m?.width?.toString() ?? '',
    );
    _compositionController = TextEditingController(text: m?.composition ?? '');
    _barcodeController = TextEditingController(text: m?.barcode ?? '');

    if (m != null) {
      _unit = m.unit;
      _categoryId = m.category?.id;
      _supplierId = m.supplier?.id;
    }

    _loadSuppliers();

    // Ensure categories are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categories = ref.read(materialsNotifierProvider).categories;
      if (categories.isEmpty) {
        ref.read(materialsNotifierProvider.notifier).loadCategories();
      }
    });
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _costPriceController.dispose();
    _sellPriceController.dispose();
    _colorController.dispose();
    _widthController.dispose();
    _compositionController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.getSuppliers(limit: 100, isActive: true);
      if (mounted) {
        setState(() {
          _suppliers = response.suppliers;
          _loadingSuppliers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSuppliers = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final api = ref.read(apiServiceProvider);

      if (_isEditing) {
        await api.updateMaterial(
          widget.material!.id,
          sku: _skuController.text.trim(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          categoryId: _categoryId,
          supplierId: _supplierId,
          unit: _unit.toJson(),
          minStockLevel: double.tryParse(_minStockController.text),
          costPrice: double.tryParse(_costPriceController.text),
          sellPrice: double.tryParse(_sellPriceController.text),
          color: _colorController.text.trim().isNotEmpty
              ? _colorController.text.trim()
              : null,
          width: double.tryParse(_widthController.text),
          composition: _compositionController.text.trim().isNotEmpty
              ? _compositionController.text.trim()
              : null,
          barcode: _barcodeController.text.trim().isNotEmpty
              ? _barcodeController.text.trim()
              : null,
        );
      } else {
        await api.createMaterial(
          sku: _skuController.text.trim(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          categoryId: _categoryId,
          supplierId: _supplierId,
          unit: _unit.toJson(),
          quantity: double.tryParse(_quantityController.text) ?? 0,
          minStockLevel: double.tryParse(_minStockController.text),
          costPrice: double.tryParse(_costPriceController.text),
          sellPrice: double.tryParse(_sellPriceController.text),
          color: _colorController.text.trim().isNotEmpty
              ? _colorController.text.trim()
              : null,
          width: double.tryParse(_widthController.text),
          composition: _compositionController.text.trim().isNotEmpty
              ? _compositionController.text.trim()
              : null,
          barcode: _barcodeController.text.trim().isNotEmpty
              ? _barcodeController.text.trim()
              : null,
        );
      }

      if (mounted) {
        ref.read(materialsNotifierProvider.notifier).refresh();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
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
        title: Text(_isEditing ? 'Редактировать материал' : 'Новый материал'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Сохранить'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _buildSectionCard(
              title: 'Основное',
              children: [
                TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU *',
                    hintText: 'Артикул материала',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Введите SKU' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название *',
                    hintText: 'Название материала',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Введите название' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    hintText: 'Описание материала',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSectionCard(
              title: 'Классификация',
              children: [
                _buildCategoryDropdown(),
                const SizedBox(height: AppSpacing.md),
                _buildSupplierDropdown(),
                const SizedBox(height: AppSpacing.md),
                _buildUnitDropdown(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSectionCard(
              title: 'Склад',
              children: [
                if (!_isEditing) ...[
                  TextFormField(
                    controller: _quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Начальное количество',
                      hintText: '0',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                TextFormField(
                  controller: _minStockController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Мин. уровень запаса',
                    hintText: 'Уведомление при низком остатке',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSectionCard(
              title: 'Цены',
              children: [
                TextFormField(
                  controller: _costPriceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Себестоимость',
                    suffixText: 'сом',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _sellPriceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Цена продажи',
                    suffixText: 'сом',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: context.borderColor),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  childrenPadding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg,
                  ),
                  title: Text('Дополнительно', style: AppTypography.h4),
                  subtitle: Text(
                    'Цвет, состав, ширина, штрих-код',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  children: [
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Цвет',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _widthController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Ширина',
                        suffixText: 'см',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _compositionController,
                      decoration: const InputDecoration(
                        labelText: 'Состав',
                        hintText: 'Например: 100% хлопок',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Штрих-код',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h4),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = ref.watch(materialsNotifierProvider).categories;

    return DropdownButtonFormField<String?>(
      initialValue: _categoryId,
      decoration: const InputDecoration(
        labelText: 'Категория',
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Без категории'),
        ),
        ...categories.map(
          (cat) => DropdownMenuItem<String?>(
            value: cat.id,
            child: Text(cat.name),
          ),
        ),
      ],
      onChanged: (value) => setState(() => _categoryId = value),
    );
  }

  Widget _buildSupplierDropdown() {
    if (_loadingSuppliers) {
      return const InputDecorator(
        decoration: InputDecoration(labelText: 'Поставщик'),
        child: Text('Загрузка...'),
      );
    }

    return DropdownButtonFormField<String?>(
      initialValue: _supplierId,
      decoration: const InputDecoration(
        labelText: 'Поставщик',
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Без поставщика'),
        ),
        ..._suppliers.map(
          (s) => DropdownMenuItem<String?>(
            value: s.id,
            child: Text(s.name),
          ),
        ),
      ],
      onChanged: (value) => setState(() => _supplierId = value),
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<mat.MaterialUnit>(
      initialValue: _unit,
      decoration: const InputDecoration(
        labelText: 'Единица измерения *',
      ),
      items: mat.MaterialUnit.values.map(
        (u) => DropdownMenuItem(
          value: u,
          child: Text(u.fullLabel),
        ),
      ).toList(),
      onChanged: _isEditing
          ? null
          : (value) {
              if (value != null) setState(() => _unit = value);
            },
    );
  }
}
