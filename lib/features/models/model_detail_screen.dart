import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/models/order.dart';
import '../../core/models/process_step.dart';
import '../../core/models/bom.dart';
import '../../core/services/api_service.dart';
import 'process_step_form_screen.dart';
import 'model_form_screen.dart';
import '../bom/bom_detail_screen.dart';

class ModelDetailScreen extends ConsumerStatefulWidget {
  final OrderModel model;

  const ModelDetailScreen({super.key, required this.model});

  @override
  ConsumerState<ModelDetailScreen> createState() => _ModelDetailScreenState();
}

class _ModelDetailScreenState extends ConsumerState<ModelDetailScreen>
    with SingleTickerProviderStateMixin {
  late OrderModel _model;
  List<ProcessStep> _processSteps = [];
  Bom? _bom;
  bool _isLoading = true;
  bool _isBomLoading = true;
  bool _initialized = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _model = widget.model;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadData());
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadProcessSteps(),
      _loadBom(),
    ]);
  }

  Future<void> _loadBom() async {
    setState(() => _isBomLoading = true);
    try {
      final bom = await ref.read(bomNotifierProvider.notifier).loadModelBom(_model.id);
      setState(() {
        _bom = bom;
        _isBomLoading = false;
      });
    } catch (e) {
      setState(() => _isBomLoading = false);
    }
  }

  Future<void> _loadProcessSteps() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final steps = await api.getProcessSteps(_model.id);
      setState(() {
        _processSteps = steps..sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки этапов: $e'),
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
        title: Text(_model.name),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editModel,
            tooltip: 'Редактировать модель',
          ),
        ],
      ),
      body: Column(
        children: [
          // Model info at top
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildModelInfo(),
          ),
          // Tab bar
          Container(
            color: context.surfaceColor,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: context.textSecondaryColor,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'Материалы'),
                Tab(text: 'Этапы'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMaterialsTab(),
                _buildStepsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          // Show different FAB based on tab
          if (_tabController.index == 0) {
            return FloatingActionButton.extended(
              heroTag: 'model_materials_fab',
              onPressed: _openBomScreen,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(_bom == null ? 'Добавить материалы' : 'Редактировать'),
            );
          } else {
            return FloatingActionButton.extended(
              heroTag: 'model_steps_fab',
              onPressed: _addProcessStep,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Добавить этап'),
            );
          }
        },
      ),
    );
  }

  Widget _buildMaterialsTab() {
    return RefreshIndicator(
      onRefresh: _loadBom,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          100, // Space for FAB
        ),
        children: [
          _buildMaterialsContent(),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    return RefreshIndicator(
      onRefresh: _loadProcessSteps,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          100, // Space for FAB
        ),
        children: [
          _buildProcessStepsContent(),
        ],
      ),
    );
  }

  Widget _buildModelInfo() {
    return Card(
      elevation: 0,
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _model.imageUrl != null ? () => _showFullScreenImage(_model.imageUrl!) : null,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: context.surfaceVariantColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _model.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: _model.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _model.name,
                        style: AppTypography.h3.copyWith(
                          color: context.textPrimaryColor,
                        ),
                      ),
                      if (_model.category != null) ...[
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
                            _model.category!,
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
                  '${_model.basePrice.toStringAsFixed(0)} сом',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (_model.description?.isNotEmpty == true) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _model.description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsContent() {
    if (_isBomLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_bom == null) {
      return _buildNoMaterialsCard();
    }

    final laborCost = _processSteps.fold<double>(
      0,
      (sum, step) => sum + (step.rate ?? 0),
    );
    final materialCost = _bom!.totalMaterialCost;
    final totalCost = materialCost + laborCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Materials list card
        Card(
          elevation: 0,
          color: context.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: context.borderColor),
          ),
          child: InkWell(
            onTap: _openBomScreen,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with version
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 20, color: context.textSecondaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Список материалов',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'v${_bom!.version}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: context.textSecondaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Materials summary
                  ..._bom!.items.take(3).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.material?.name ?? 'Материал',
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                        Text(
                          '${item.quantity} ${item.material?.materialUnit.label ?? ''}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )),
                  if (_bom!.items.length > 3)
                    Text(
                      '+ ещё ${_bom!.items.length - 3}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Cost summary card
        Card(
          elevation: 0,
          color: context.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: context.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calculate_outlined, size: 20, color: context.textSecondaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Себестоимость',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Materials cost row
                _buildCostRow('Материалы', '${_bom!.items.length}', materialCost),
                const SizedBox(height: AppSpacing.sm),
                // Labor cost row
                _buildCostRow('Работа', '${_processSteps.length} ${_getStepsLabel(_processSteps.length)}', laborCost),
                const Divider(height: AppSpacing.lg),
                // Total row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Итого',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ),
                    Text(
                      '${totalCost.toStringAsFixed(0)} сом',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, String count, double cost) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label ($count)',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textPrimaryColor,
            ),
          ),
        ),
        Text(
          '${cost.toStringAsFixed(0)} сом',
          style: AppTypography.bodyMedium.copyWith(
            color: context.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNoMaterialsCard() {
    return Card(
      elevation: 0,
      color: context.surfaceVariantColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Добавьте материалы для расчёта себестоимости',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openBomScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BomDetailScreen(
          model: _model,
          initialBom: _bom,
        ),
      ),
    );
    if (result == true || result == null) {
      // Refresh BOM after returning
      _loadBom();
    }
  }

  Widget _buildProcessStepsContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_processSteps.isEmpty) {
      return _buildEmptySteps();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepsList(),
        const SizedBox(height: AppSpacing.sm),
        _buildStepsSummaryRow(),
      ],
    );
  }

  Widget _buildEmptySteps() {
    return Card(
      elevation: 0,
      color: context.surfaceVariantColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.construction_outlined,
              size: 48,
              color: context.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Нет этапов производства',
              style: AppTypography.bodyLarge.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Добавьте этапы с расценками для расчёта зарплаты',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: _processSteps.length,
      onReorder: _onReorder,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scale = Curves.easeInOut.transform(animation.value) * 0.02 + 1;
            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final step = _processSteps[index];
        return _ProcessStepCard(
          key: ValueKey(step.id),
          step: step,
          index: index,
          onEdit: () => _editProcessStep(step),
          onDelete: () => _confirmDeleteStep(step),
        );
      },
    );
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final item = _processSteps.removeAt(oldIndex);
      _processSteps.insert(newIndex, item);
    });

    // Update step orders on server
    try {
      final api = ref.read(apiServiceProvider);
      for (int i = 0; i < _processSteps.length; i++) {
        final step = _processSteps[i];
        if (step.stepOrder != i + 1) {
          await api.updateProcessStep(
            stepId: step.id,
            stepOrder: i + 1,
          );
        }
      }
      await _loadProcessSteps();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения порядка: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        _loadProcessSteps();
      }
    }
  }

  Widget _buildStepsSummaryRow() {
    final totalTime = _processSteps.fold<int>(
      0,
      (sum, step) => sum + step.estimatedTime,
    );
    final totalRate = _processSteps.fold<double>(
      0,
      (sum, step) => sum + (step.rate ?? 0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Text(
        'Итого: ${_formatTime(totalTime)} · ${totalRate.toStringAsFixed(0)} сом',
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: context.textSecondaryColor,
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

  String _getStepsLabel(int count) {
    if (count == 1) return 'этап';
    if (count >= 2 && count <= 4) return 'этапа';
    return 'этапов';
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(
          imageUrl: imageUrl,
          title: _model.name,
        ),
      ),
    );
  }

  Future<void> _editModel() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ModelFormScreen(model: _model),
      ),
    );
    if (result == true) {
      // Reload model data
      try {
        final api = ref.read(apiServiceProvider);
        final updatedModel = await api.getModel(_model.id);
        setState(() {
          _model = updatedModel;
        });
      } catch (e) {
        // Ignore, just go back
      }
    }
  }

  Future<void> _addProcessStep() async {
    final nextOrder = _processSteps.isEmpty
        ? 1
        : _processSteps.map((s) => s.stepOrder).reduce((a, b) => a > b ? a : b) + 1;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessStepFormScreen(
          modelId: _model.id,
          nextOrder: nextOrder,
        ),
      ),
    );
    if (result == true) {
      _loadProcessSteps();
    }
  }

  Future<void> _editProcessStep(ProcessStep step) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessStepFormScreen(
          modelId: _model.id,
          step: step,
        ),
      ),
    );
    if (result == true) {
      _loadProcessSteps();
    }
  }

  void _confirmDeleteStep(ProcessStep step) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить этап?'),
        content: Text('Вы уверены, что хотите удалить этап "${step.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStep(step);
            },
            child: Text(
              'Удалить',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStep(ProcessStep step) async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.deleteProcessStep(step.id);
      _loadProcessSteps();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Этап удалён'),
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
  }
}

class _ProcessStepCard extends StatelessWidget {
  final ProcessStep step;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProcessStepCard({
    super.key,
    required this.step,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: context.borderColor),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.drag_handle,
                    color: context.textTertiaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Step number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Step info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: context.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            step.executorRoleLabel,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: context.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          step.formattedTime,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Rate
              if (step.rate != null && step.rate! > 0)
                Text(
                  '${step.rate!.toStringAsFixed(0)} сом',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              // Delete button
              IconButton(
                icon: Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: onDelete,
                tooltip: 'Удалить',
                iconSize: 20,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _FullScreenImageView({
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

