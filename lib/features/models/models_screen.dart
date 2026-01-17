import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/models/order.dart';
import '../../core/services/api_service.dart';
import 'model_form_screen.dart';
import 'model_detail_screen.dart';

class ModelsScreen extends StatefulWidget {
  const ModelsScreen({super.key});

  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  String? _categoryFilter;
  bool _isLoading = true;
  List<OrderModel> _models = [];
  bool _initialized = false;

  ApiService get _api => context.read<AppProvider>().api;

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
      _loadModels();
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
      final api = _api;
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
        actions: [
          PopupMenuButton<String?>(
            icon: Badge(
              isLabelVisible: _categoryFilter != null,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: context.l10n.filterByCategory,
            onSelected: (value) {
              setState(() {
                _categoryFilter = value;
              });
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(
                      _categoryFilter == null ? Icons.check : Icons.clear,
                      size: 18,
                      color: _categoryFilter == null
                          ? AppColors.primary
                          : ctx.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.allCategories,
                      style: TextStyle(
                        color: _categoryFilter == null
                            ? AppColors.primary
                            : ctx.textPrimaryColor,
                        fontWeight: _categoryFilter == null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ..._getLocalizedCategories(context).map((cat) => PopupMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(
                          _categoryFilter == cat ? Icons.check : Icons.label_outline,
                          size: 18,
                          color: _categoryFilter == cat
                              ? AppColors.primary
                              : ctx.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat,
                          style: TextStyle(
                            color: _categoryFilter == cat
                                ? AppColors.primary
                                : ctx.textPrimaryColor,
                            fontWeight: _categoryFilter == cat
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: AppSearchBar(
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

  void _confirmDelete(OrderModel model) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteModelTitle),
        content: Text(l10n.deleteModelMessage(model.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              try {
                final api = _api;
                await api.deleteModel(model.id);
                _loadModels();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.modelDeleted),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  );
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
              }
            },
            child: Text(
              l10n.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
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
                '${model.basePrice.toStringAsFixed(0)} ₽',
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

class _ModelDetailsSheet extends StatelessWidget {
  final OrderModel model;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ModelDetailsSheet({
    required this.model,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.surfaceVariantColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: model.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: model.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: Icon(
                              Icons.checkroom,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.checkroom,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.checkroom,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: AppTypography.h3.copyWith(
                          color: context.textPrimaryColor,
                        ),
                      ),
                      if (model.category != null) ...[
                        const SizedBox(height: 4),
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
                      ],
                    ],
                  ),
                ),
                Text(
                  '${model.basePrice.toStringAsFixed(0)} ₽',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (model.description?.isNotEmpty == true) ...[
                    Row(
                      children: [
                        Icon(Icons.description_outlined,
                            size: 18, color: context.textSecondaryColor),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.description,
                          style: AppTypography.labelLarge.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.surfaceVariantColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        model.description!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          icon: Icon(Icons.delete_outline, color: AppColors.error),
                          label: Text(
                            context.l10n.delete,
                            style: TextStyle(color: AppColors.error),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onEdit();
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(context.l10n.changeAction),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
