import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/date_range_picker_button.dart';
import '../../core/models/models.dart';
import 'create_order_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const OrdersScreen({super.key, this.onMenuPressed});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DateTimeRange? _dueDateRange;
  DateTimeRange? _createdDateRange;
  String _sortBy = 'createdAt';
  bool _sortAsc = false;

  final List<OrderStatus?> _statusFilters = [
    null, // All
    OrderStatus.pending,
    OrderStatus.inProgress,
    OrderStatus.completed,
    OrderStatus.cancelled,
  ];

  bool get _hasFilters => _dueDateRange != null || _createdDateRange != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Заказы'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuPressed,
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _hasFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFiltersDialog,
            tooltip: 'Фильтры',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppSearchBar(
                  controller: _searchController,
                  hint: 'Поиск заказов...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  onClear: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Status tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: context.textSecondaryColor,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Все'),
                  Tab(text: 'Ожидают'),
                  Tab(text: 'В работе'),
                  Tab(text: 'Готово'),
                  Tab(text: 'Отменены'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: _statusFilters.map((status) {
              return _buildOrdersList(provider.recentOrders, status);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'orders_fab',
        onPressed: () => _openCreateOrder(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Новый заказ'),
      ),
    );
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FiltersSheet(
        dueDateRange: _dueDateRange,
        createdDateRange: _createdDateRange,
        sortBy: _sortBy,
        sortAsc: _sortAsc,
        onApply: (dueDateRange, createdDateRange, sortBy, sortAsc) {
          setState(() {
            _dueDateRange = dueDateRange;
            _createdDateRange = createdDateRange;
            _sortBy = sortBy;
            _sortAsc = sortAsc;
          });
          Navigator.pop(context);
        },
        onReset: () {
          setState(() {
            _dueDateRange = null;
            _createdDateRange = null;
            _sortBy = 'createdAt';
            _sortAsc = false;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, OrderStatus? statusFilter) {
    var filteredOrders = orders;

    // Filter by status
    if (statusFilter != null) {
      filteredOrders = filteredOrders.where((o) => o.status == statusFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) {
        final clientName = order.client?.name.toLowerCase() ?? '';
        final modelName = order.model?.name.toLowerCase() ?? '';
        final orderId = order.id.toLowerCase();
        return clientName.contains(_searchQuery) ||
               modelName.contains(_searchQuery) ||
               orderId.contains(_searchQuery);
      }).toList();
    }

    // Filter by due date range
    if (_dueDateRange != null) {
      filteredOrders = filteredOrders.where((order) {
        if (order.dueDate == null) return false;
        return !order.dueDate!.isBefore(_dueDateRange!.start) &&
               !order.dueDate!.isAfter(_dueDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by created date range
    if (_createdDateRange != null) {
      filteredOrders = filteredOrders.where((order) {
        return !order.createdAt.isBefore(_createdDateRange!.start) &&
               !order.createdAt.isAfter(_createdDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort
    filteredOrders.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case 'dueDate':
          final aDate = a.dueDate ?? DateTime(2100);
          final bDate = b.dueDate ?? DateTime(2100);
          cmp = aDate.compareTo(bDate);
          break;
        case 'quantity':
          cmp = a.quantity.compareTo(b.quantity);
          break;
        default:
          cmp = a.createdAt.compareTo(b.createdAt);
      }
      return _sortAsc ? cmp : -cmp;
    });

    final provider = context.read<AppProvider>();
    final emptyWidget = EmptyState(
      icon: Icons.receipt_long_outlined,
      title: _searchQuery.isNotEmpty
        ? 'Ничего не найдено'
        : statusFilter == null
          ? 'Нет заказов'
          : 'Нет заказов с этим статусом',
      subtitle: _searchQuery.isNotEmpty
        ? 'Попробуйте изменить поисковый запрос'
        : 'Создайте первый заказ',
      actionLabel: _searchQuery.isEmpty ? 'Создать заказ' : null,
      onAction: _searchQuery.isEmpty ? () => _openCreateOrder() : null,
    );

    return InfiniteScrollList<Order>(
      items: filteredOrders,
      hasMore: provider.hasMoreOrders,
      isLoading: provider.isLoadingMoreOrders,
      onLoadMore: () => provider.loadMoreOrders(),
      onRefresh: () => provider.refreshOrders(),
      padding: const EdgeInsets.all(AppSpacing.md),
      separatorHeight: AppSpacing.sm,
      emptyWidget: emptyWidget,
      itemBuilder: (context, order, index) {
        return OrderCard(
          order: order,
          onTap: () => _showOrderDetails(order),
        );
      },
    );
  }

  void _showOrderDetails(Order order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(order: order),
      ),
    );
    // Refresh after returning from detail screen
    if (mounted) {
      context.read<AppProvider>().refreshDashboard();
    }
  }

  Future<void> _openCreateOrder() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
    );
    if (result == true && mounted) {
      // Order created, list will refresh automatically via provider
    }
  }
}

class _FiltersSheet extends StatefulWidget {
  final DateTimeRange? dueDateRange;
  final DateTimeRange? createdDateRange;
  final String sortBy;
  final bool sortAsc;
  final void Function(DateTimeRange?, DateTimeRange?, String, bool) onApply;
  final VoidCallback onReset;

  const _FiltersSheet({
    required this.dueDateRange,
    required this.createdDateRange,
    required this.sortBy,
    required this.sortAsc,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late DateTimeRange? _dueDateRange;
  late DateTimeRange? _createdDateRange;
  late String _sortBy;
  late bool _sortAsc;

  @override
  void initState() {
    super.initState();
    _dueDateRange = widget.dueDateRange;
    _createdDateRange = widget.createdDateRange;
    _sortBy = widget.sortBy;
    _sortAsc = widget.sortAsc;
  }

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

          // Title
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Фильтры',
                  style: AppTypography.h4.copyWith(color: context.textPrimaryColor),
                ),
                TextButton(
                  onPressed: widget.onReset,
                  child: const Text('Сбросить'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filters
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Due date filter
                  Text(
                    'Срок сдачи',
                    style: AppTypography.labelLarge.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DateRangePickerButton(
                    dateRange: _dueDateRange,
                    onChanged: (range) => setState(() => _dueDateRange = range),
                    placeholder: 'Все даты',
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Created date filter
                  Text(
                    'Дата создания',
                    style: AppTypography.labelLarge.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DateRangePickerButton(
                    dateRange: _createdDateRange,
                    onChanged: (range) => setState(() => _createdDateRange = range),
                    placeholder: 'Все даты',
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Sort
                  Text(
                    'Сортировка',
                    style: AppTypography.labelLarge.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        label: const Text('По дате создания'),
                        selected: _sortBy == 'createdAt',
                        onSelected: (_) => setState(() => _sortBy = 'createdAt'),
                      ),
                      ChoiceChip(
                        label: const Text('По сроку'),
                        selected: _sortBy == 'dueDate',
                        onSelected: (_) => setState(() => _sortBy = 'dueDate'),
                      ),
                      ChoiceChip(
                        label: const Text('По кол-ву'),
                        selected: _sortBy == 'quantity',
                        onSelected: (_) => setState(() => _sortBy = 'quantity'),
                      ),
                    ],
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

                  const SizedBox(height: AppSpacing.xl),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => widget.onApply(
                        _dueDateRange,
                        _createdDateRange,
                        _sortBy,
                        _sortAsc,
                      ),
                      child: const Text('Применить'),
                    ),
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
