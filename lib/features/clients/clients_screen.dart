import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/models/models.dart';
import '../orders/create_order_screen.dart';
import 'client_form_screen.dart';
import 'widgets/clients_widgets.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onMenuPressed;

  const ClientsScreen({super.key, this.onMenuPressed});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  String _sortBy = 'name'; // name, orders, spent

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.customers),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: widget.onMenuPressed != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onMenuPressed,
              )
            : null,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: context.l10n.sortLabel,
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (ctx) => [
              _buildSortOption(ctx, 'name', context.l10n.sortByName),
              _buildSortOption(ctx, 'orders', context.l10n.sortByOrders),
              _buildSortOption(ctx, 'spent', context.l10n.sortByAmount),
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
              hint: context.l10n.searchCustomers,
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
      body: _buildClientsList(),
      floatingActionButton: _buildFab(),
    );
  }

  PopupMenuItem<String> _buildSortOption(BuildContext context, String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            _sortBy == value ? Icons.check : Icons.sort,
            size: 18,
            color: _sortBy == value ? AppColors.primary : context.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: _sortBy == value ? AppColors.primary : context.textPrimaryColor,
              fontWeight: _sortBy == value ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFab() {
    final user = ref.watch(currentUserProvider);
    final canEdit = user?.canEditClients ?? false;
    if (!canEdit) return null;

    return FloatingActionButton.extended(
      heroTag: 'clients_fab',
      onPressed: () => _openClientForm(),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.person_add),
      label: Text(context.l10n.newCustomer),
    );
  }

  Widget _buildClientsList() {
    final clients = ref.watch(clientsProvider);
    final user = ref.watch(currentUserProvider);
    final canEdit = user?.canEditClients ?? false;

    var filteredClients = clients.toList();

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filteredClients = filteredClients.where((client) {
        final name = client.name.toLowerCase();
        final phone = client.contacts.phone?.toLowerCase() ?? '';
        final email = client.contacts.email?.toLowerCase() ?? '';
        return name.contains(_searchQuery) ||
               phone.contains(_searchQuery) ||
               email.contains(_searchQuery);
      }).toList();
    }

    // Sort
    filteredClients = List.from(filteredClients);
    switch (_sortBy) {
      case 'name':
        filteredClients.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'orders':
        filteredClients.sort((a, b) => (b.ordersCount ?? 0).compareTo(a.ordersCount ?? 0));
        break;
      case 'spent':
        filteredClients.sort((a, b) => (b.totalSpent ?? 0).compareTo(a.totalSpent ?? 0));
        break;
    }

    if (filteredClients.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: _searchQuery.isNotEmpty
          ? context.l10n.noResults
          : context.l10n.noCustomers,
        subtitle: _searchQuery.isNotEmpty
          ? context.l10n.tryDifferentSearch
          : canEdit ? context.l10n.addFirstCustomer : context.l10n.customersNotAdded,
        actionLabel: _searchQuery.isEmpty && canEdit ? context.l10n.addCustomer : null,
        onAction: _searchQuery.isEmpty && canEdit ? () => _openClientForm() : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardNotifierProvider.notifier).refreshDashboard(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: filteredClients.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final client = filteredClients[index];
          return ClientCard(
            client: client,
            onTap: () => _showClientDetails(client),
          );
        },
      ),
    );
  }

  void _showClientDetails(Client client) {
    final user = ref.read(currentUserProvider);
    final canEdit = user?.canEditClients ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClientDetailsSheet(
        client: client,
        canEdit: canEdit,
        onEdit: () => _openClientForm(client: client),
        onCreateOrder: () => _openCreateOrder(client: client),
      ),
    );
  }

  Future<void> _openClientForm({Client? client}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ClientFormScreen(client: client),
      ),
    );
    if (result == true) {
      // Refreshed via provider
    }
  }

  void _openCreateOrder({required Client client}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateOrderScreen(),
        // TODO: pass client to pre-select
      ),
    );
  }
}
