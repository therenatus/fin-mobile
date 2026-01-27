import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/models/material.dart' as mat;
import '../../core/widgets/material_card.dart';
import '../../core/widgets/common.dart';
import 'material_detail_screen.dart';
import 'material_form_screen.dart';
import 'stock_adjustment_screen.dart';
import 'barcode_scan_screen.dart';

class MaterialsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onMenuPressed;

  const MaterialsScreen({super.key, this.onMenuPressed});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(materialsNotifierProvider.notifier);
      notifier.loadCategories();
      notifier.loadMaterials();
      notifier.loadLowStockMaterials();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(materialsNotifierProvider.notifier).loadMoreMaterials();
    }
  }

  void _onSearch(String query) {
    ref.read(materialsNotifierProvider.notifier).setSearchQuery(query);
  }

  void _openMaterial(mat.Material material) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialDetailScreen(materialId: material.id),
      ),
    );
  }

  void _openCreateMaterial() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const MaterialFormScreen()),
    );

    if (result == true) {
      ref.read(materialsNotifierProvider.notifier).refresh();
    }
  }

  void _openQuickAdjustment() async {
    final materials = ref.read(materialsNotifierProvider).materials;
    final selected = await showModalBottomSheet<mat.Material>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MaterialPickerSheet(materials: materials),
    );

    if (selected != null && mounted) {
      await Navigator.push<mat.Material>(
        context,
        MaterialPageRoute(
          builder: (context) => StockAdjustmentScreen(material: selected),
        ),
      );
      ref.read(materialsNotifierProvider.notifier).refresh();
    }
  }

  void _openBarcodeScan() async {
    final result = await Navigator.push<mat.Material>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScanScreen()),
    );

    if (result != null && mounted) {
      _openMaterial(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Склад материалов'),
        leading: widget.onMenuPressed != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onMenuPressed,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert),
            onPressed: _openQuickAdjustment,
            tooltip: 'Приход / Списание',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _openBarcodeScan,
            tooltip: 'Сканировать штрих-код',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateMaterial,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _buildMaterialsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList() {
    final materialsState = ref.watch(materialsNotifierProvider);
    final materials = materialsState.materials;
    final isLoading = materialsState.loadingState == MaterialsLoadingState.loading;
    final isError = materialsState.loadingState == MaterialsLoadingState.error;
    final isLoadingMore = materialsState.isLoadingMore;

    if (isLoading && materials.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isError) {
      return _buildError();
    }

    if (materials.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: ref.read(materialsNotifierProvider.notifier).refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: materials.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == materials.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final material = materials[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: MaterialCard(
              material: material,
              onTap: () => _openMaterial(material),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final materialsState = ref.watch(materialsNotifierProvider);
    final categories = materialsState.categories;
    final categoryId = materialsState.categoryId;
    final lowStockCount = materialsState.lowStockCount;
    final showLowStockOnly = materialsState.showLowStockOnly;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          bottom: BorderSide(color: context.borderColor),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск по названию или SKU...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: context.surfaceVariantColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            onChanged: _onSearch,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Filters row
          Row(
            children: [
              // Category dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.surfaceVariantColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: categoryId,
                      isExpanded: true,
                      hint: const Text('Все категории'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Все категории'),
                        ),
                        ...categories.map(
                          (cat) => DropdownMenuItem<String?>(
                            value: cat.id,
                            child: Text(
                              cat.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(materialsNotifierProvider.notifier).setCategory(value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Low stock filter
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Мало'),
                    if (lowStockCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$lowStockCount',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                selected: showLowStockOnly,
                onSelected: ref.read(materialsNotifierProvider.notifier).setLowStockFilter,
                selectedColor: AppColors.error.withOpacity(0.2),
                checkmarkColor: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final error = ref.read(materialsNotifierProvider).error;
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Ошибка загрузки',
      subtitle: error ?? 'Не удалось загрузить материалы',
      actionLabel: 'Повторить',
      onAction: () {
        final notifier = ref.read(materialsNotifierProvider.notifier);
        notifier.clearError();
        notifier.loadMaterials();
      },
    );
  }

  Widget _buildEmpty() {
    final materialsState = ref.read(materialsNotifierProvider);
    final hasFilters = materialsState.searchQuery.isNotEmpty ||
        materialsState.categoryId != null ||
        materialsState.showLowStockOnly;

    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: hasFilters ? 'Ничего не найдено' : 'Нет материалов',
      subtitle: hasFilters
          ? 'Попробуйте изменить параметры поиска'
          : 'Добавьте материалы для учёта на складе',
      actionLabel: hasFilters ? 'Сбросить фильтры' : null,
      onAction: hasFilters ? ref.read(materialsNotifierProvider.notifier).clearFilters : null,
    );
  }
}

class _MaterialPickerSheet extends StatefulWidget {
  final List<mat.Material> materials;

  const _MaterialPickerSheet({required this.materials});

  @override
  State<_MaterialPickerSheet> createState() => _MaterialPickerSheetState();
}

class _MaterialPickerSheetState extends State<_MaterialPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<mat.Material> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.materials;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    final q = query.toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.materials;
      } else {
        _filtered = widget.materials
            .where((m) =>
                m.name.toLowerCase().contains(q) ||
                m.sku.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Выберите материал',
                  style: AppTypography.h4,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию или SKU...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onChanged: _filter,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(child: Text('Ничего не найдено'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final m = _filtered[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.inventory_2_outlined,
                                  size: 20, color: AppColors.primary),
                            ),
                            title: Text(m.name),
                            subtitle: Text(
                              'SKU: ${m.sku}  •  ${m.formattedQuantity}',
                              style: AppTypography.bodySmall,
                            ),
                            onTap: () => Navigator.pop(context, m),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
