import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/materials_provider.dart';
import '../../core/models/material.dart' as mat;
import '../../core/widgets/material_card.dart';
import '../../core/widgets/common.dart';
import 'material_detail_screen.dart';
import 'barcode_scan_screen.dart';

class MaterialsScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const MaterialsScreen({super.key, this.onMenuPressed});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MaterialsProvider>();
      provider.loadCategories();
      provider.loadMaterials();
      provider.loadLowStockMaterials();
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
      context.read<MaterialsProvider>().loadMoreMaterials();
    }
  }

  void _onSearch(String query) {
    context.read<MaterialsProvider>().setSearchQuery(query);
  }

  void _openMaterial(mat.Material material) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialDetailScreen(materialId: material.id),
      ),
    );
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
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _openBarcodeScan,
            tooltip: 'Сканировать штрих-код',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Consumer<MaterialsProvider>(
              builder: (context, provider, _) {
                if (provider.state == MaterialsState.loading &&
                    provider.materials.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.state == MaterialsState.error) {
                  return _buildError(provider);
                }

                if (provider.materials.isEmpty) {
                  return _buildEmpty();
                }

                return RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: provider.materials.length +
                        (provider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.materials.length) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final material = provider.materials[index];
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Consumer<MaterialsProvider>(
      builder: (context, provider, _) {
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
                          value: provider.categoryId,
                          isExpanded: true,
                          hint: const Text('Все категории'),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Все категории'),
                            ),
                            ...provider.categories.map(
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
                            provider.setCategory(value);
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
                        if (provider.lowStockCount > 0) ...[
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
                              '${provider.lowStockCount}',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: provider.showLowStockOnly,
                    onSelected: provider.setLowStockFilter,
                    selectedColor: AppColors.error.withOpacity(0.2),
                    checkmarkColor: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(MaterialsProvider provider) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Ошибка загрузки',
      message: provider.error ?? 'Не удалось загрузить материалы',
      actionLabel: 'Повторить',
      onAction: () {
        provider.clearError();
        provider.loadMaterials();
      },
    );
  }

  Widget _buildEmpty() {
    final provider = context.read<MaterialsProvider>();
    final hasFilters = provider.searchQuery.isNotEmpty ||
        provider.categoryId != null ||
        provider.showLowStockOnly;

    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: hasFilters ? 'Ничего не найдено' : 'Нет материалов',
      message: hasFilters
          ? 'Попробуйте изменить параметры поиска'
          : 'Добавьте материалы для учёта на складе',
      actionLabel: hasFilters ? 'Сбросить фильтры' : null,
      onAction: hasFilters ? provider.clearFilters : null,
    );
  }
}
