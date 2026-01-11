import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/models/models.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../orders/create_order_screen.dart';
import 'client_form_screen.dart';

class ClientsScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const ClientsScreen({super.key, this.onMenuPressed});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name'; // name, orders, spent

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Заказчики'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuPressed,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Сортировка',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (ctx) => [
              _buildSortOption(ctx, 'name', 'По имени'),
              _buildSortOption(ctx, 'orders', 'По заказам'),
              _buildSortOption(ctx, 'spent', 'По сумме'),
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
              hint: 'Поиск заказчиков...',
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
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return _buildClientsList(provider.clients, provider.user?.canEditClients ?? false);
        },
      ),
      floatingActionButton: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final canEdit = provider.user?.canEditClients ?? false;
          if (!canEdit) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            heroTag: 'clients_fab',
            onPressed: () => _openClientForm(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add),
            label: const Text('Новый заказчик'),
          );
        },
      ),
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

  Widget _buildClientsList(List<Client> clients, bool canEdit) {
    var filteredClients = clients;

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
          ? 'Ничего не найдено'
          : 'Нет заказчиков',
        subtitle: _searchQuery.isNotEmpty
          ? 'Попробуйте изменить поисковый запрос'
          : canEdit ? 'Добавьте первого заказчика' : 'Заказчики пока не добавлены',
        actionLabel: _searchQuery.isEmpty && canEdit ? 'Добавить заказчика' : null,
        onAction: _searchQuery.isEmpty && canEdit ? () => _openClientForm() : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AppProvider>().refreshDashboard(),
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
    final user = context.read<AppProvider>().user;
    final canEdit = user?.canEditClients ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ClientDetailsSheet(
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

class _ClientDetailsSheet extends StatefulWidget {
  final Client client;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onCreateOrder;

  const _ClientDetailsSheet({
    required this.client,
    required this.canEdit,
    required this.onEdit,
    required this.onCreateOrder,
  });

  @override
  State<_ClientDetailsSheet> createState() => _ClientDetailsSheetState();
}

class _ClientDetailsSheetState extends State<_ClientDetailsSheet> {
  Client? _clientDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientDetails();
  }

  Future<void> _loadClientDetails() async {
    try {
      final api = ApiService(StorageService());
      final client = await api.getClient(widget.client.id);
      if (mounted) {
        setState(() {
          _clientDetails = client;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _clientDetails = widget.client;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openModelAssignmentDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ModelAssignmentDialog(
        clientId: widget.client.id,
        assignedModelIds: _clientDetails?.assignedModelIds ?? [],
      ),
    );
    if (result == true) {
      _loadClientDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = _clientDetails ?? widget.client;

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

          // Header with avatar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      (client.name.isNotEmpty ? client.name.substring(0, 1).toUpperCase() : '?'),
                      style: AppTypography.h2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
                        client.name,
                        style: AppTypography.h3.copyWith(
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Заказчик с ${_formatDate(client.createdAt)}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Stats
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Заказов',
                    value: '${client.ordersCount ?? 0}',
                    icon: Icons.receipt_long_outlined,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: context.borderColor,
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Потрачено',
                    value: _formatCurrency(client.totalSpent ?? 0),
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assigned Models section
                  _buildAssignedModelsSection(context, client),

                  const SizedBox(height: AppSpacing.lg),

                  // Contact info
                  _buildContactSection(context, client),

                  if (client.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildNotesSection(context, client),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Actions
                  Row(
                    children: [
                      if (widget.canEdit) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onEdit();
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Изменить'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onCreateOrder();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Создать заказ'),
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

  Widget _buildAssignedModelsSection(BuildContext context, Client client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.checkroom_outlined, size: 18, color: context.textSecondaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Доступные модели',
                style: AppTypography.labelLarge.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _openModelAssignmentDialog,
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Настроить'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (client.assignedModels.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.surfaceVariantColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: context.borderColor,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.checkroom_outlined,
                  size: 32,
                  color: context.textTertiaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Модели не назначены',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Заказчик может заказывать любые модели',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textTertiaryColor,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.surfaceVariantColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: client.assignedModels.map((model) {
                return Chip(
                  avatar: const Icon(
                    Icons.checkroom,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Text(model.name),
                  labelStyle: AppTypography.labelMedium.copyWith(
                    color: context.textPrimaryColor,
                  ),
                  backgroundColor: context.surfaceColor,
                  side: BorderSide(color: context.borderColor),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context, Client client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.contact_phone_outlined, size: 18, color: context.textSecondaryColor),
            const SizedBox(width: 8),
            Text(
              'Контакты',
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
          child: Column(
            children: [
              if (client.contacts.phone != null)
                _ContactRow(
                  icon: Icons.phone_outlined,
                  label: 'Телефон',
                  value: client.contacts.phone!,
                  onTap: () {},
                ),
              if (client.contacts.email != null) ...[
                if (client.contacts.phone != null)
                  const Divider(height: AppSpacing.md),
                _ContactRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: client.contacts.email!,
                  onTap: () {},
                ),
              ],
              if (client.contacts.telegram != null) ...[
                const Divider(height: AppSpacing.md),
                _ContactRow(
                  icon: Icons.telegram,
                  label: 'Telegram',
                  value: client.contacts.telegram!,
                  onTap: () {},
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, Client client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notes_outlined, size: 18, color: context.textSecondaryColor),
            const SizedBox(width: 8),
            Text(
              'Заметки',
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
            client.notes!,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₽';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ₽';
    }
    return '${amount.toStringAsFixed(0)} ₽';
  }
}

// Dialog for selecting which models to assign to a client
class _ModelAssignmentDialog extends StatefulWidget {
  final String clientId;
  final List<String> assignedModelIds;

  const _ModelAssignmentDialog({
    required this.clientId,
    required this.assignedModelIds,
  });

  @override
  State<_ModelAssignmentDialog> createState() => _ModelAssignmentDialogState();
}

class _ModelAssignmentDialogState extends State<_ModelAssignmentDialog> {
  List<OrderModel> _allModels = [];
  Set<String> _selectedModelIds = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedModelIds = Set.from(widget.assignedModelIds);
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      final api = ApiService(StorageService());
      final models = await api.getModels();
      if (mounted) {
        setState(() {
          _allModels = models;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить модели';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAssignments() async {
    setState(() => _isSaving = true);
    try {
      final api = ApiService(StorageService());
      await api.setClientAssignedModels(widget.clientId, _selectedModelIds.toList());
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  const Icon(Icons.checkroom, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Доступные модели',
                      style: AppTypography.h4.copyWith(
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Info text
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                'Выберите модели, которые заказчик сможет заказать. Если ни одна модель не выбрана - доступны все.',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),

            // Content
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        )
                      : _allModels.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Text(
                                  'Нет доступных моделей',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: context.textSecondaryColor,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              itemCount: _allModels.length,
                              itemBuilder: (context, index) {
                                final model = _allModels[index];
                                final isSelected = _selectedModelIds.contains(model.id);
                                return CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedModelIds.add(model.id);
                                      } else {
                                        _selectedModelIds.remove(model.id);
                                      }
                                    });
                                  },
                                  title: Text(
                                    model.name,
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      if (model.category != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(25),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            model.category!,
                                            style: AppTypography.labelSmall.copyWith(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        '${model.basePrice.toStringAsFixed(0)} ₽',
                                        style: AppTypography.labelMedium.copyWith(
                                          color: context.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  secondary: Icon(
                                    Icons.checkroom_outlined,
                                    color: isSelected
                                        ? AppColors.primary
                                        : context.textTertiaryColor,
                                  ),
                                  activeColor: AppColors.primary,
                                  checkColor: Colors.white,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                );
                              },
                            ),
            ),

            const Divider(height: 1),

            // Actions
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAssignments,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _selectedModelIds.isEmpty
                                  ? 'Сбросить'
                                  : 'Сохранить (${_selectedModelIds.length})',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.h4.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textTertiaryColor,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: context.textTertiaryColor,
          ),
        ],
      ),
    );
  }
}
