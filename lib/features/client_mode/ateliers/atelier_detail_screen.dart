import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/client_provider.dart';
import '../../../core/models/client_user.dart';
import '../orders/client_create_order_screen.dart';
import '../orders/client_order_detail_screen.dart';

class AtelierDetailScreen extends StatefulWidget {
  final TenantLink tenant;

  const AtelierDetailScreen({super.key, required this.tenant});

  @override
  State<AtelierDetailScreen> createState() => _AtelierDetailScreenState();
}

class _AtelierDetailScreenState extends State<AtelierDetailScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  // Local filter/sort state
  String _searchQuery = '';
  String? _statusFilter;
  String _sortBy = 'createdAt';
  bool _sortAsc = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().refreshOrders(tenantId: widget.tenant.tenantId);
    });
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
        _searchQuery = value;
      });
    });
  }

  List<ClientOrder> _getFilteredOrders(List<ClientOrder> allOrders) {
    var orders = allOrders.where((o) => o.tenantId == widget.tenant.tenantId).toList();

    // Apply search
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((o) =>
        o.model.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      orders = orders.where((o) => o.status == _statusFilter).toList();
    }

    // Apply sorting
    orders.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case 'dueDate':
          final aDate = a.dueDate ?? DateTime(2100);
          final bDate = b.dueDate ?? DateTime(2100);
          cmp = aDate.compareTo(bDate);
          break;
        case 'price':
          cmp = a.totalCost.compareTo(b.totalCost);
          break;
        default: // createdAt
          cmp = a.createdAt.compareTo(b.createdAt);
      }
      return _sortAsc ? cmp : -cmp;
    });

    return orders;
  }

  double _calculateTotal(List<ClientOrder> orders) {
    return orders.fold(0.0, (sum, o) => sum + o.totalCost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(widget.tenant.tenantName),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Сортировка',
          ),
        ],
      ),
      body: Consumer<ClientProvider>(
        builder: (context, provider, _) {
          final filteredOrders = _getFilteredOrders(provider.orders);
          final total = _calculateTotal(filteredOrders);

          return Column(
            children: [
              // Header with stats and filters
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: context.surfaceColor,
                child: Column(
                  children: [
                    // Summary row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _ordersLabel(filteredOrders.length),
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                        Text(
                          'Итого: ${_formatPrice(total)}',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Поиск по названию модели...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchDebounce?.cancel();
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
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Status filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Все',
                            isSelected: _statusFilter == null,
                            onTap: () => setState(() => _statusFilter = null),
                          ),
                          _FilterChip(
                            label: 'Ожидают',
                            isSelected: _statusFilter == 'pending',
                            onTap: () => setState(() => _statusFilter = 'pending'),
                          ),
                          _FilterChip(
                            label: 'В работе',
                            isSelected: _statusFilter == 'in_progress',
                            onTap: () => setState(() => _statusFilter = 'in_progress'),
                          ),
                          _FilterChip(
                            label: 'Готово',
                            isSelected: _statusFilter == 'completed',
                            onTap: () => setState(() => _statusFilter = 'completed'),
                          ),
                          _FilterChip(
                            label: 'Отменены',
                            isSelected: _statusFilter == 'cancelled',
                            onTap: () => setState(() => _statusFilter = 'cancelled'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Orders list
              Expanded(
                child: filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => provider.refreshOrders(
                          tenantId: widget.tenant.tenantId,
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _OrderCard(
                              order: order,
                              onTap: () => _openOrderDetail(order),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'atelier_detail_fab',
        onPressed: _createOrder,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Новый заказ'),
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SortSheet(
        sortBy: _sortBy,
        sortAsc: _sortAsc,
        onApply: (sortBy, sortAsc) {
          setState(() {
            _sortBy = sortBy;
            _sortAsc = sortAsc;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _searchQuery.isNotEmpty || _statusFilter != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.receipt_long_outlined,
              size: 80,
              color: context.textSecondaryColor,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              hasFilters ? 'Ничего не найдено' : 'Нет заказов',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasFilters
                  ? 'Попробуйте изменить фильтры'
                  : 'Создайте первый заказ в этом ателье',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _statusFilter = null;
                  });
                },
                child: const Text('Сбросить фильтры'),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: _createOrder,
                icon: const Icon(Icons.add),
                label: const Text('Создать заказ'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openOrderDetail(ClientOrder order) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ClientOrderDetailScreen(order: order),
      ),
    );
    if (result == true && mounted) {
      context.read<ClientProvider>().refreshOrders(
        tenantId: widget.tenant.tenantId,
      );
    }
  }

  void _createOrder() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ClientCreateOrderScreen(
          preselectedTenant: widget.tenant,
        ),
      ),
    );
    if (result == true && mounted) {
      context.read<ClientProvider>().refreshOrders(
        tenantId: widget.tenant.tenantId,
      );
    }
  }

  String _ordersLabel(int count) {
    if (count == 0) return 'Нет заказов';
    if (count == 1) return '1 заказ';
    if (count >= 2 && count <= 4) return '$count заказа';
    return '$count заказов';
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0)} ₽';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : context.textSecondaryColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : context.borderColor,
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ClientOrder order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Model image/icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: order.model.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Image.network(
                          order.model.imageUrl!,
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
              // Order info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.model.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusBadge(status: order.status, label: order.statusLabel),
                        const Spacer(),
                        Text(
                          '${order.quantity} шт.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (order.model.basePrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${order.totalCost.toStringAsFixed(0)} ₽',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const _StatusBadge({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'pending':
        color = AppColors.warning;
        break;
      case 'in_progress':
        color = AppColors.info;
        break;
      case 'completed':
        color = AppColors.success;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = context.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SortSheet extends StatefulWidget {
  final String sortBy;
  final bool sortAsc;
  final void Function(String, bool) onApply;

  const _SortSheet({
    required this.sortBy,
    required this.sortAsc,
    required this.onApply,
  });

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late String _sortBy;
  late bool _sortAsc;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.sortBy;
    _sortAsc = widget.sortAsc;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Сортировка', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Сортировать по',
            style: AppTypography.labelMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text('Дате создания'),
                selected: _sortBy == 'createdAt',
                onSelected: (_) => setState(() => _sortBy = 'createdAt'),
              ),
              ChoiceChip(
                label: const Text('Сроку'),
                selected: _sortBy == 'dueDate',
                onSelected: (_) => setState(() => _sortBy = 'dueDate'),
              ),
              ChoiceChip(
                label: const Text('Цене'),
                selected: _sortBy == 'price',
                onSelected: (_) => setState(() => _sortBy = 'price'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Порядок',
            style: AppTypography.labelMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text('По убыванию'),
                selected: !_sortAsc,
                onSelected: (_) => setState(() => _sortAsc = false),
              ),
              ChoiceChip(
                label: const Text('По возрастанию'),
                selected: _sortAsc,
                onSelected: (_) => setState(() => _sortAsc = true),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_sortBy, _sortAsc),
              child: const Text('Применить'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
