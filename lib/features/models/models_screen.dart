import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/models/order.dart';
import 'model_form_screen.dart';
import 'model_detail_screen.dart';

class ModelsScreen extends ConsumerStatefulWidget {
  const ModelsScreen({super.key});

  @override
  ConsumerState<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends ConsumerState<ModelsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  String? _categoryFilter;
  bool _isLoading = true;
  List<OrderModel> _models = [];
  bool _initialized = false;

  List<String> _getLocalizedCategories(BuildContext context) {
    return [
      context.l10n.categoryDress,
      context.l10n.categorySuit,
      context.l10n.categoryPants,
      context.l10n.categoryShirt,
      context.l10n.categorySkirt,
      context.l10n.categoryCoat,
      context.l10n.categoryOther,
    ];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadModels());
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value.toLowerCase();
      });
    });
  }

  Future<void> _loadModels() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final models = await api.getModels();
      setState(() {
        _models = models;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.loadingError(e.toString())),
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
      drawer: const AppDrawer(currentRoute: 'models'),
      appBar: AppBar(
        title: Text(context.l10n.models),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              children: [
                AppSearchBar(
                  controller: _searchController,
                  hint: context.l10n.searchModels,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _searchDebounce?.cancel();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.surfaceVariantColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _categoryFilter,
                      isExpanded: true,
                      hint: Text(context.l10n.allCategories),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(context.l10n.allCategories),
                        ),
                        ..._getLocalizedCategories(context).map(
                          (cat) => DropdownMenuItem<String?>(
                            value: cat,
                            child: Text(cat),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _categoryFilter = value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildModelsList(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'models_fab',
        onPressed: () => _openModelForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(context.l10n.newModel),
      ),
    );
  }

  Widget _buildModelsList() {
    var filteredModels = _models;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filteredModels = filteredModels.where((model) {
        final name = model.name.toLowerCase();
        final category = model.category?.toLowerCase() ?? '';
        final description = model.description?.toLowerCase() ?? '';
        return name.contains(_searchQuery) ||
            category.contains(_searchQuery) ||
            description.contains(_searchQuery);
      }).toList();
    }

    // Category filter
    if (_categoryFilter != null) {
      filteredModels = filteredModels.where((model) {
        return model.category?.toLowerCase() == _categoryFilter?.toLowerCase();
      }).toList();
    }

    if (filteredModels.isEmpty) {
      return EmptyState(
        icon: Icons.checkroom_outlined,
        title: _searchQuery.isNotEmpty || _categoryFilter != null
            ? context.l10n.nothingFound
            : context.l10n.noModels,
        subtitle: _searchQuery.isNotEmpty || _categoryFilter != null
            ? context.l10n.tryChangeSearchParams
            : context.l10n.addFirstModel,
        actionLabel: _searchQuery.isEmpty && _categoryFilter == null
            ? context.l10n.addModel
            : null,
        onAction: _searchQuery.isEmpty && _categoryFilter == null
            ? () => _openModelForm()
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadModels,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.85,
        ),
        itemCount: filteredModels.length,
        itemBuilder: (context, index) {
          final model = filteredModels[index];
          return _ModelCard(
            model: model,
            onTap: () => _showModelDetails(model),
          );
        },
      ),
    );
  }

  Future<void> _showModelDetails(OrderModel model) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ModelDetailScreen(model: model),
      ),
    );
    if (result == true) {
      _loadModels();
    }
  }

  Future<void> _openModelForm({OrderModel? model}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ModelFormScreen(model: model),
      ),
    );
    if (result == true) {
      _loadModels();
    }
  }

}

class _ModelCard extends StatelessWidget {
  final OrderModel model;
  final VoidCallback onTap;

  const _ModelCard({
    required this.model,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/Image placeholder
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                clipBehavior: Clip.antiAlias,
                child: model.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: model.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: Icon(
                            Icons.checkroom,
                            size: 40,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            Icons.checkroom,
                            size: 40,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.checkroom,
                          size: 40,
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Name
              Text(
                model.name,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Category badge
              if (model.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    model.category!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const Spacer(),
              // Price
              Text(
                '${model.basePrice.toStringAsFixed(0)} сом',
                style: AppTypography.h4.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

