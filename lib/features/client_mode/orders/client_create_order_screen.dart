import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/client_user.dart';

class ClientCreateOrderScreen extends ConsumerStatefulWidget {
  final TenantLink? preselectedTenant;

  const ClientCreateOrderScreen({super.key, this.preselectedTenant});

  @override
  ConsumerState<ClientCreateOrderScreen> createState() => _ClientCreateOrderScreenState();
}

class _ClientCreateOrderScreenState extends ConsumerState<ClientCreateOrderScreen> {
  TenantLink? _selectedTenant;
  ClientOrderModel? _selectedModel;
  int _quantity = 1;
  DateTime? _dueDate;

  List<ClientOrderModel> _models = [];
  bool _isLoadingModels = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(clientAuthNotifierProvider);

      // Use preselected tenant if provided, otherwise first available
      if (widget.preselectedTenant != null) {
        _selectedTenant = widget.preselectedTenant;
        _loadModels();
      } else if (authState.tenants.isNotEmpty) {
        _selectedTenant = authState.tenants.first;
        _loadModels();
      }
    });
  }

  Future<void> _loadModels() async {
    if (_selectedTenant == null) return;

    setState(() {
      _isLoadingModels = true;
      _models = [];
      _selectedModel = null;
    });

    try {
      final notifier = ref.read(clientAuthNotifierProvider.notifier);
      final models = await notifier.getTenantModels(_selectedTenant!.tenantId);
      setState(() {
        _models = models;
        _isLoadingModels = false;
      });
    } catch (e) {
      setState(() => _isLoadingModels = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки моделей: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createOrder() async {
    if (_selectedTenant == null || _selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите ателье и модель')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(clientAuthNotifierProvider.notifier);
      await notifier.createOrder(
        tenantId: _selectedTenant!.tenantId,
        modelId: _selectedModel!.id,
        quantity: _quantity,
        dueDate: _dueDate?.toIso8601String(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заказ успешно создан'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(clientAuthNotifierProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Новый заказ'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Builder(
        builder: (context) {
          if (authState.tenants.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 80,
                      color: context.textSecondaryColor,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Сначала привяжитесь к ателье',
                      style: AppTypography.h3,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Tenant selection (only show selector if not preselected)
              if (widget.preselectedTenant == null) ...[
                _buildSectionTitle('Ателье'),
                const SizedBox(height: AppSpacing.sm),
                _buildTenantSelector(authState),
                const SizedBox(height: AppSpacing.lg),
              ] else ...[
                // Show selected tenant as read-only
                _buildSelectedTenantCard(),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Model selection
              _buildSectionTitle('Модель'),
              const SizedBox(height: AppSpacing.sm),
              _buildModelSelector(),

              const SizedBox(height: AppSpacing.lg),

              // Quantity
              _buildSectionTitle('Количество'),
              const SizedBox(height: AppSpacing.sm),
              _buildQuantitySelector(),

              const SizedBox(height: AppSpacing.lg),

              // Due date
              _buildSectionTitle('Желаемая дата готовности'),
              const SizedBox(height: AppSpacing.sm),
              _buildDateSelector(),

              const SizedBox(height: AppSpacing.lg),

              // Summary
              if (_selectedModel != null) ...[
                _buildSectionTitle('Итого'),
                const SizedBox(height: AppSpacing.sm),
                _buildSummary(),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Submit button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _selectedModel == null
                      ? null
                      : _createOrder,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Создать заказ'),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelLarge.copyWith(
        color: context.textSecondaryColor,
      ),
    );
  }

  Widget _buildSelectedTenantCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.store,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedTenant!.tenantName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_selectedTenant!.tenantDomain != null)
                  Text(
                    _selectedTenant!.tenantDomain!,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantSelector(ClientAuthStateData authState) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: DropdownButtonFormField<TenantLink>(
        value: _selectedTenant,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: InputBorder.none,
        ),
        isExpanded: true,
        items: authState.tenants.map((tenant) {
          return DropdownMenuItem<TenantLink>(
            value: tenant,
            child: Row(
              children: [
                Icon(Icons.store, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tenant.tenantName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedTenant = value;
            _selectedModel = null;
          });
          _loadModels();
        },
      ),
    );
  }

  Widget _buildModelSelector() {
    if (_isLoadingModels) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_models.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: context.textSecondaryColor),
            const SizedBox(width: 12),
            const Text('Нет доступных моделей'),
          ],
        ),
      );
    }

    // Show selected model or picker button
    return GestureDetector(
      onTap: _showModelPicker,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _selectedModel != null ? AppColors.primary : context.borderColor,
            width: _selectedModel != null ? 2 : 1,
          ),
        ),
        child: _selectedModel != null
            ? Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: context.surfaceVariantColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: _selectedModel!.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: Image.network(
                              _selectedModel!.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.checkroom,
                                color: context.textSecondaryColor,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.checkroom,
                            color: context.textSecondaryColor,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedModel!.name,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_selectedModel!.category != null)
                          Text(
                            _selectedModel!.category!,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        if (_selectedModel!.basePrice != null)
                          Text(
                            '${_selectedModel!.basePrice!.toStringAsFixed(0)} сом',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: context.textSecondaryColor),
                ],
              )
            : Row(
                children: [
                  Icon(Icons.checkroom, color: context.textSecondaryColor),
                  const SizedBox(width: 12),
                  Text(
                    'Выберите модель',
                    style: AppTypography.bodyLarge.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: context.textSecondaryColor),
                ],
              ),
      ),
    );
  }

  void _showModelPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModelPickerSheet(
        models: _models,
        selectedModel: _selectedModel,
        onSelected: (model) {
          setState(() => _selectedModel = model);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _quantity > 1
                ? () => setState(() => _quantity--)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primary,
          ),
          const SizedBox(width: 16),
          Text(
            '$_quantity',
            style: AppTypography.h3,
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => setState(() => _quantity++),
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
          ),
          const Spacer(),
          Text(
            'шт.',
            style: AppTypography.bodyLarge.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          locale: const Locale('ru'),
        );
        if (date != null) {
          setState(() => _dueDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: context.textSecondaryColor),
            const SizedBox(width: 12),
            Text(
              _dueDate != null
                  ? '${_dueDate!.day.toString().padLeft(2, '0')}.${_dueDate!.month.toString().padLeft(2, '0')}.${_dueDate!.year}'
                  : 'Не указана',
              style: AppTypography.bodyLarge,
            ),
            const Spacer(),
            if (_dueDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _dueDate = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final total = (_selectedModel?.basePrice ?? 0) * _quantity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_selectedModel!.name} × $_quantity',
                style: AppTypography.bodyMedium,
              ),
              Text(
                _selectedTenant!.tenantName,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
          if (_selectedModel!.basePrice != null)
            Text(
              '${total.toStringAsFixed(0)} сом',
              style: AppTypography.h3.copyWith(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

class _ModelPickerSheet extends StatefulWidget {
  final List<ClientOrderModel> models;
  final ClientOrderModel? selectedModel;
  final ValueChanged<ClientOrderModel> onSelected;

  const _ModelPickerSheet({
    required this.models,
    required this.selectedModel,
    required this.onSelected,
  });

  @override
  State<_ModelPickerSheet> createState() => _ModelPickerSheetState();
}

class _ModelPickerSheetState extends State<_ModelPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClientOrderModel> get _filteredModels {
    if (_searchQuery.isEmpty) return widget.models;
    return widget.models.where((model) {
      final query = _searchQuery.toLowerCase();
      return model.name.toLowerCase().contains(query) ||
          (model.category?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Выберите модель', style: AppTypography.h4),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
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
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ],
            ),
          ),
          // Models list
          Expanded(
            child: _filteredModels.isEmpty
                ? Center(
                    child: Text(
                      'Ничего не найдено',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: _filteredModels.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final model = _filteredModels[index];
                      final isSelected = widget.selectedModel?.id == model.id;
                      return _ModelTile(
                        model: model,
                        isSelected: isSelected,
                        onTap: () => widget.onSelected(model),
                      );
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  final ClientOrderModel model;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModelTile({
    required this.model,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isSelected ? AppColors.primary : context.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              // Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: model.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Image.network(
                          model.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.checkroom,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      )
                    : Icon(Icons.checkroom, color: context.textSecondaryColor),
              ),
              const SizedBox(width: AppSpacing.md),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    if (model.category != null)
                      Text(
                        model.category!,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                  ],
                ),
              ),
              // Price
              if (model.basePrice != null)
                Text(
                  '${model.basePrice!.toStringAsFixed(0)} сом',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle, color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
