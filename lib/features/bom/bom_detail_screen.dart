import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/bom.dart';
import '../../core/models/order.dart';
import '../../core/riverpod/providers.dart';
import '../../core/utils/toast.dart';
import 'widgets/widgets.dart';
import 'bom_item_form_screen.dart';
import 'bom_operation_form_screen.dart';

/// Экран просмотра и редактирования BOM модели
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

class _BomDetailScreenState extends ConsumerState<BomDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Bom? _bom;
  bool _isLoading = true;
  bool _isRecalculating = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bom = widget.initialBom;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadBom();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: Text('Спецификация (BOM)'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.textSecondaryColor,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Материалы', icon: Icon(Icons.inventory_2_outlined, size: 18)),
            Tab(text: 'Операции', icon: Icon(Icons.build_outlined, size: 18)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bom == null
              ? _buildEmptyState()
              : _buildContent(),
      floatingActionButton: _bom != null
          ? FloatingActionButton(
              heroTag: 'bom_detail_fab',
              onPressed: _showAddMenu,
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
              'Нет спецификации',
              style: AppTypography.h3.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Создайте спецификацию (BOM) для модели "${widget.model.name}",\nчтобы рассчитать себестоимость',
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

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMaterialsTab(),
              _buildOperationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialsTab() {
    final items = _bom?.items ?? [];

    if (items.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.inventory_2_outlined,
        title: 'Нет материалов',
        subtitle: 'Добавьте материалы в спецификацию',
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

  Widget _buildOperationsTab() {
    final operations = _bom?.operations ?? [];

    if (operations.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.build_outlined,
        title: 'Нет операций',
        subtitle: 'Добавьте операции в спецификацию',
      );
    }

    // Sort by sequence
    final sorted = List<BomOperation>.from(operations)
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    return RefreshIndicator(
      onRefresh: _loadBom,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          100,
        ),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final operation = sorted[index];
          return BomOperationCard(
            operation: operation,
            onEdit: () => _editOperation(operation),
            onDelete: () => _confirmDeleteOperation(operation),
          );
        },
      ),
    );
  }

  Widget _buildEmptyTab({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: context.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTypography.bodyLarge.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Добавить', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: AppColors.info),
                ),
                title: const Text('Материал'),
                subtitle: const Text('Добавить материал в спецификацию'),
                onTap: () {
                  Navigator.pop(context);
                  _addItem();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.build_outlined, color: AppColors.success),
                ),
                title: const Text('Операция'),
                subtitle: const Text('Добавить производственную операцию'),
                onTap: () {
                  Navigator.pop(context);
                  _addOperation();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createBom() async {
    // Create empty BOM first, then add items/operations
    try {
      final bom = await ref.read(bomNotifierProvider.notifier).createBom(
        modelId: widget.model.id,
        items: [],
        operations: [],
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
        content: Text('Удалить "${item.material?.name ?? 'материал'}" из спецификации?'),
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

  Future<void> _addOperation() async {
    if (_bom == null) return;

    final nextSequence = (_bom!.operations.isEmpty
            ? 0
            : _bom!.operations.map((o) => o.sequence).reduce((a, b) => a > b ? a : b)) +
        1;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BomOperationFormScreen(
          bom: _bom!,
          nextSequence: nextSequence,
        ),
      ),
    );

    if (result == true) {
      _loadBom();
    }
  }

  Future<void> _editOperation(BomOperation operation) async {
    if (_bom == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BomOperationFormScreen(
          bom: _bom!,
          operation: operation,
        ),
      ),
    );

    if (result == true) {
      _loadBom();
    }
  }

  void _confirmDeleteOperation(BomOperation operation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить операцию?'),
        content: Text('Удалить "${operation.name}" из спецификации?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOperation(operation);
            },
            child: Text('Удалить', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOperation(BomOperation operation) async {
    if (_bom == null) return;

    try {
      // Remove operation and update BOM
      final updatedOperations = _bom!.operations
          .where((o) => o.id != operation.id)
          .map((o) => o.toJson())
          .toList();

      await ref.read(bomNotifierProvider.notifier).updateBom(
        _bom!.id,
        operations: updatedOperations,
      );
      _loadBom();
      if (mounted) {
        AppToast.success(context, 'Операция удалена');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Ошибка удаления: $e');
      }
    }
  }
}
