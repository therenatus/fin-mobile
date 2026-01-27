import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/bom.dart';
import '../../core/models/order.dart';
import '../../core/riverpod/providers.dart';
import '../../core/utils/toast.dart';
import 'widgets/widgets.dart';
import 'bom_item_form_screen.dart';

/// Экран просмотра и редактирования BOM модели (только материалы)
class BomDetailScreen extends ConsumerStatefulWidget {
  final OrderModel model;
  final Bom? initialBom;

  const BomDetailScreen({
    super.key,
    required this.model,
    this.initialBom,
  });

  @override
  ConsumerState<BomDetailScreen> createState() => _BomDetailScreenState();
}

class _BomDetailScreenState extends ConsumerState<BomDetailScreen> {
  Bom? _bom;
  bool _isLoading = true;
  bool _isRecalculating = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _bom = widget.initialBom;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadBom());
    }
  }

  Future<void> _loadBom() async {
    setState(() => _isLoading = true);
    try {
      final bom = await ref.read(bomNotifierProvider.notifier).loadModelBom(widget.model.id);
      setState(() {
        _bom = bom;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppToast.error(context, 'Ошибка загрузки BOM: $e');
      }
    }
  }

  Future<void> _recalculateBom() async {
    if (_bom == null) return;

    setState(() => _isRecalculating = true);
    try {
      final bom = await ref.read(bomNotifierProvider.notifier).recalculateBom(_bom!.id);
      setState(() {
        _bom = bom;
        _isRecalculating = false;
      });
      if (mounted) {
        AppToast.success(context, 'Себестоимость пересчитана');
      }
    } catch (e) {
      setState(() => _isRecalculating = false);
      if (mounted) {
        AppToast.error(context, 'Ошибка пересчёта: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Материалы'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bom == null
              ? _buildEmptyState()
              : _buildContent(),
      floatingActionButton: _bom != null
          ? FloatingActionButton(
              heroTag: 'bom_detail_fab',
              onPressed: _addItem,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : FloatingActionButton.extended(
              heroTag: 'bom_detail_fab',
              onPressed: _createBom,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Создать BOM',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.surfaceVariantColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                Icons.description_outlined,
                size: 40,
                color: context.textSecondaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Нет материалов',
              style: AppTypography.h3.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Добавьте материалы для модели "${widget.model.name}"\nчтобы рассчитать себестоимость',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Summary card
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: BomSummaryCard(
            bom: _bom!,
            onRecalculate: _recalculateBom,
            isRecalculating: _isRecalculating,
          ),
        ),

        // Materials list
        Expanded(
          child: _buildMaterialsList(),
        ),
      ],
    );
  }

  Widget _buildMaterialsList() {
    final items = _bom?.items ?? [];

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: context.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Нет материалов',
              style: AppTypography.bodyLarge.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Нажмите + чтобы добавить',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBom,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          100,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return BomItemCard(
            item: item,
            onEdit: () => _editItem(item),
            onDelete: () => _confirmDeleteItem(item),
          );
        },
      ),
    );
  }

  Future<void> _createBom() async {
    try {
      final bom = await ref.read(bomNotifierProvider.notifier).createBom(
        modelId: widget.model.id,
        items: [],
      );
      setState(() => _bom = bom);
      if (mounted) {
        AppToast.success(context, 'Спецификация создана');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Ошибка создания: $e');
      }
    }
  }

  Future<void> _addItem() async {
    if (_bom == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BomItemFormScreen(bom: _bom!),
      ),
    );

    if (result == true) {
      _loadBom();
    }
  }

  Future<void> _editItem(BomItem item) async {
    if (_bom == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BomItemFormScreen(bom: _bom!, item: item),
      ),
    );

    if (result == true) {
      _loadBom();
    }
  }

  void _confirmDeleteItem(BomItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить материал?'),
        content: Text('Удалить "${item.material?.name ?? 'материал'}" из списка?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(item);
            },
            child: Text('Удалить', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(BomItem item) async {
    if (_bom == null) return;

    try {
      // Remove item and update BOM
      final updatedItems = _bom!.items
          .where((i) => i.id != item.id)
          .map((i) => i.toJson())
          .toList();

      await ref.read(bomNotifierProvider.notifier).updateBom(
        _bom!.id,
        items: updatedItems,
      );
      _loadBom();
      if (mounted) {
        AppToast.success(context, 'Материал удалён');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Ошибка удаления: $e');
      }
    }
  }
}
