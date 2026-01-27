import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/models/material.dart' as mat;
import '../../core/models/stock_movement.dart';
import '../../core/widgets/stock_indicator.dart';
import 'material_form_screen.dart';
import 'stock_adjustment_screen.dart';

class MaterialDetailScreen extends ConsumerStatefulWidget {
  final String materialId;

  const MaterialDetailScreen({
    super.key,
    required this.materialId,
  });

  @override
  ConsumerState<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends ConsumerState<MaterialDetailScreen> {
  mat.Material? _material;
  List<StockMovement> _movements = [];
  bool _isLoading = true;
  bool _isLoadingMovements = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMaterial();
  }

  Future<void> _loadMaterial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifier = ref.read(materialsNotifierProvider.notifier);
      final material = await notifier.getMaterial(widget.materialId);

      if (material != null) {
        setState(() {
          _material = material;
          _isLoading = false;
        });
        _loadMovements();
      } else {
        setState(() {
          _error = 'Материал не найден';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMovements() async {
    setState(() => _isLoadingMovements = true);

    try {
      final notifier = ref.read(materialsNotifierProvider.notifier);
      final response = await notifier.getStockMovements(
        widget.materialId,
        limit: 10,
      );

      if (response != null) {
        setState(() {
          _movements = response.movements;
        });
      }
    } catch (e) {
      debugPrint('Error loading movements: $e');
    }

    setState(() => _isLoadingMovements = false);
  }

  void _openAdjustment() async {
    if (_material == null) return;

    final result = await Navigator.push<mat.Material>(
      context,
      MaterialPageRoute(
        builder: (context) => StockAdjustmentScreen(material: _material!),
      ),
    );

    if (result != null) {
      setState(() => _material = result);
      _loadMovements();
    }
  }

  void _openEdit() async {
    if (_material == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialFormScreen(material: _material),
      ),
    );

    if (result == true) {
      _loadMaterial();
    }
  }

  void _confirmDelete() {
    if (_material == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить материал?'),
        content: Text('Материал "${_material!.name}" будет удалён. Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final api = ref.read(apiServiceProvider);
                await api.deleteMaterial(_material!.id);
                if (mounted) {
                  ref.read(materialsNotifierProvider.notifier).refresh();
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка удаления: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showConsumeDialog() {
    if (_material == null) return;

    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Списать материал',
                      style: AppTypography.h3,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Current stock info
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.surfaceVariantColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Доступно:'),
                      Text(
                        _material!.formattedAvailableQty,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Quantity field
                TextFormField(
                  controller: quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Количество *',
                    hintText: 'Введите количество для списания',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите количество';
                    }
                    final qty = double.tryParse(value);
                    if (qty == null || qty <= 0) {
                      return 'Введите корректное число';
                    }
                    if (qty > _material!.computedAvailableQty) {
                      return 'Недостаточно на складе';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Reason field
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Причина',
                    hintText: 'Укажите причину списания',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final qty = double.parse(quantityController.text);
                      final reason = reasonController.text.isNotEmpty
                          ? reasonController.text
                          : 'Списание';

                      Navigator.pop(context);

                      try {
                        final notifier = ref.read(materialsNotifierProvider.notifier);
                        final updated = await notifier.adjustStock(
                          widget.materialId,
                          quantity: -qty,
                          reason: reason,
                        );

                        if (updated != null && mounted) {
                          setState(() => _material = updated);
                          _loadMovements();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Списано: ${qty.toStringAsFixed(1)} ${_material!.unit.label}'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ошибка: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    child: const Text('Списать'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(_material?.name ?? 'Материал'),
        actions: [
          if (_material != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _openEdit();
                    break;
                  case 'delete':
                    _confirmDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 12),
                      Text('Редактировать'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Удалить', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.bodyLarge.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadMaterial,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_material == null) {
      return const Center(child: Text('Материал не найден'));
    }

    return RefreshIndicator(
      onRefresh: _loadMaterial,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.lg),
            _buildStockSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildDetailsSection(),
            if (_material!.supplier != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildSupplierSection(),
            ],
            const SizedBox(height: AppSpacing.lg),
            _buildMovementsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          // Material image/color
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _material!.color != null
                  ? _parseColor(_material!.color!)
                  : context.surfaceVariantColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: _material!.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      _material!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.inventory_2_outlined,
                        size: 36,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.inventory_2_outlined,
                    size: 36,
                    color: context.textSecondaryColor,
                  ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _material!.name,
                  style: AppTypography.h3,
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${_material!.sku}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                if (_material!.category != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _material!.category!.name,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _material!.computedIsLowStock
              ? AppColors.error.withOpacity(0.5)
              : context.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Остаток на складе',
                style: AppTypography.h4,
              ),
              const Spacer(),
              StockIndicator(
                quantity: _material!.quantity,
                minStockLevel: _material!.minStockLevel,
                showLabel: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Stock values
          Row(
            children: [
              Expanded(
                child: _buildStockValue(
                  'Всего',
                  _material!.formattedQuantity,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStockValue(
                  'В резерве',
                  '${_material!.reservedQty.toStringAsFixed(_material!.reservedQty.truncateToDouble() == _material!.reservedQty ? 0 : 2)} ${_material!.unit.label}',
                  AppColors.warning,
                ),
              ),
              Expanded(
                child: _buildStockValue(
                  'Доступно',
                  _material!.formattedAvailableQty,
                  AppColors.success,
                ),
              ),
            ],
          ),

          // Stock level bar
          if (_material!.minStockLevel != null) ...[
            const SizedBox(height: AppSpacing.lg),
            StockLevelBar(
              quantity: _material!.quantity,
              minStockLevel: _material!.minStockLevel,
              maxLevel: (_material!.minStockLevel! * 3).clamp(
                _material!.quantity * 1.2,
                double.infinity,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Мин. уровень: ${_material!.minStockLevel!.toStringAsFixed(0)} ${_material!.unit.label}',
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],

          // Action buttons
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openAdjustment,
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.success),
                  label: Text(
                    'Приход',
                    style: TextStyle(color: AppColors.success),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.success.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showConsumeDialog,
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                  label: Text(
                    'Списание',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockValue(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h3.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
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
          Text(
            'Характеристики',
            style: AppTypography.h4,
          ),
          const SizedBox(height: AppSpacing.md),

          _buildDetailRow('Единица измерения', _material!.unit.fullLabel),
          if (_material!.costPrice != null)
            _buildDetailRow(
              'Себестоимость',
              '${_material!.costPrice!.toStringAsFixed(2)} сом',
            ),
          if (_material!.sellPrice != null)
            _buildDetailRow(
              'Цена продажи',
              '${_material!.sellPrice!.toStringAsFixed(2)} сом',
            ),
          if (_material!.barcode != null)
            _buildDetailRow('Штрих-код', _material!.barcode!),
          if (_material!.color != null)
            _buildDetailRow('Цвет', _material!.color!),
          if (_material!.width != null)
            _buildDetailRow('Ширина', '${_material!.width} см'),
          if (_material!.composition != null)
            _buildDetailRow('Состав', _material!.composition!),
          if (_material!.description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Описание',
              style: AppTypography.labelMedium.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _material!.description!,
              style: AppTypography.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.business,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Поставщик',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _material!.supplier!.name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'История движений',
                style: AppTypography.h4,
              ),
              if (_movements.length >= 10)
                TextButton(
                  onPressed: () {
                    // TODO: Open full movements history
                  },
                  child: const Text('Все'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (_isLoadingMovements)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_movements.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text(
                  'Нет записей',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _movements.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final movement = _movements[index];
                return _buildMovementItem(movement);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMovementItem(StockMovement movement) {
    final isIncoming = movement.quantity > 0;
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isIncoming ? AppColors.success : AppColors.error)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncoming ? Icons.add : Icons.remove,
              color: isIncoming ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.type.label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (movement.reason != null)
                  Text(
                    movement.reason!,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  dateFormat.format(movement.createdAt),
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                movement.formattedQuantity,
                style: AppTypography.bodyLarge.copyWith(
                  color: isIncoming ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Остаток: ${movement.balanceAfter.toStringAsFixed(0)}',
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorName) {
    final lowerName = colorName.toLowerCase();
    final colorMap = {
      'красный': Colors.red.shade100,
      'синий': Colors.blue.shade100,
      'зелёный': Colors.green.shade100,
      'зеленый': Colors.green.shade100,
      'жёлтый': Colors.yellow.shade100,
      'желтый': Colors.yellow.shade100,
      'чёрный': Colors.grey.shade400,
      'черный': Colors.grey.shade400,
      'белый': Colors.grey.shade100,
      'серый': Colors.grey.shade200,
      'коричневый': Colors.brown.shade100,
      'бежевый': Colors.amber.shade50,
      'розовый': Colors.pink.shade100,
      'фиолетовый': Colors.purple.shade100,
      'оранжевый': Colors.orange.shade100,
      'голубой': Colors.lightBlue.shade100,
    };
    return colorMap[lowerName] ?? Colors.grey.shade100;
  }
}
