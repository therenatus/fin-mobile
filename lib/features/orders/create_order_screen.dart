import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/models/models.dart';
import '../../core/services/base_api_service.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');

  Client? _selectedClient;
  OrderModel? _selectedModel;
  DateTime? _dueDate;

  int get _quantity => int.tryParse(_quantityController.text) ?? 1;

  List<Client> _clients = [];
  List<OrderModel> _allModels = [];
  List<OrderModel> _availableModels = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isLoadingModels = false;
  String? _error;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadData());
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final results = await Future.wait([
        api.getClients(limit: 100),
        api.getModels(limit: 100),
      ]);

      setState(() {
        _clients = results[0] as List<Client>;
        _allModels = results[1] as List<OrderModel>;
        _availableModels = []; // Don't show models until client is selected
        _isLoading = false;
      });
    } on BaseApiException catch (e, stack) {
      debugPrint('ERROR loading data: $e');
      debugPrint('Stack: $stack');

      // If session expired, redirect to login
      if (e.statusCode == 401) {
        if (mounted) {
          final storage = ref.read(storageServiceProvider);
          await storage.clearAll();
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return;
      }

      setState(() {
        _error = 'Ошибка загрузки: ${e.message}';
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('ERROR loading data: $e');
      debugPrint('Stack: $stack');
      setState(() {
        _error = 'Ошибка загрузки: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onClientChanged(Client? client) async {
    setState(() {
      _selectedClient = client;
      _selectedModel = null;
      _availableModels = [];
    });

    if (client == null) {
      return;
    }

    setState(() => _isLoadingModels = true);

    try {
      final api = ref.read(apiServiceProvider);
      final clientDetails = await api.getClient(client.id);

      if (mounted) {
        setState(() {
          if (clientDetails.assignedModelIds.isEmpty) {
            // No models assigned - show empty list with message
            _availableModels = [];
          } else {
            // Filter to only show assigned models
            _availableModels = _allModels.where((model) {
              return clientDetails.assignedModelIds.contains(model.id);
            }).toList();
          }
          _isLoadingModels = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableModels = [];
          _isLoadingModels = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки моделей: $e')),
        );
      }
    }
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null || _selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите заказчика и модель')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final api = ref.read(apiServiceProvider);
      await api.createOrder(
        clientId: _selectedClient!.id,
        modelId: _selectedModel!.id,
        quantity: _quantity,
        dueDate: _dueDate?.toIso8601String(),
      );

      if (mounted) {
        await ref.read(dashboardNotifierProvider.notifier).refreshDashboard();
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

  void _showClientPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchableClientSheet(
        clients: _clients,
        selectedClient: _selectedClient,
        onSelected: (client) {
          Navigator.pop(context);
          _onClientChanged(client);
        },
      ),
    );
  }

  void _showModelPicker() {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала выберите заказчика')),
      );
      return;
    }

    if (_availableModels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('У заказчика нет назначенных моделей')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchableModelSheet(
        models: _availableModels,
        selectedModel: _selectedModel,
        onSelected: (model) {
          Navigator.pop(context);
          setState(() => _selectedModel = model);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Новый заказ'),
        centerTitle: true,
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      // Client selection
                      _buildSectionTitle('Заказчик'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildClientSelector(),

                      const SizedBox(height: AppSpacing.lg),

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
                      _buildSectionTitle('Дата сдачи'),
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
                          onPressed: _isSubmitting ? null : _createOrder,
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
                  ),
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

  Widget _buildClientSelector() {
    return GestureDetector(
      onTap: _clients.isEmpty ? null : _showClientPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.borderColor),
        ),
        child: _clients.isEmpty
            ? Row(
                children: [
                  Icon(Icons.warning, color: AppColors.warning),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Нет заказчиков. Сначала создайте заказчика.'),
                  ),
                ],
              )
            : Row(
                children: [
                  if (_selectedClient != null) ...[
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        _selectedClient!.name.isNotEmpty
                            ? _selectedClient!.name.substring(0, 1).toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedClient!.name,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_selectedClient!.contacts.phone != null)
                            Text(
                              _selectedClient!.contacts.phone!,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Icon(Icons.person_outline, color: context.textSecondaryColor),
                    const SizedBox(width: 12),
                    Text(
                      'Выберите заказчика',
                      style: AppTypography.bodyLarge.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const Spacer(),
                  ],
                  Icon(Icons.keyboard_arrow_down, color: context.textSecondaryColor),
                ],
              ),
      ),
    );
  }

  Widget _buildModelSelector() {
    if (_isLoadingModels) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.borderColor),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Загрузка моделей...'),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _showModelPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            if (_selectedModel != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedModel!.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _selectedModel!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.checkroom,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      )
                    : Icon(Icons.checkroom, color: context.textSecondaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedModel!.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_selectedModel!.basePrice.toStringAsFixed(0)} сом',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Icon(Icons.checkroom_outlined, color: context.textSecondaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedClient == null
                      ? 'Сначала выберите заказчика'
                      : _availableModels.isEmpty
                          ? 'Нет назначенных моделей'
                          : 'Выберите модель',
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
            ],
            Icon(Icons.keyboard_arrow_down, color: context.textSecondaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return TextFormField(
      controller: _quantityController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      style: AppTypography.h3,
      decoration: InputDecoration(
        hintText: '1',
        suffixText: 'шт.',
        suffixStyle: AppTypography.bodyLarge.copyWith(
          color: context.textSecondaryColor,
        ),
        prefixIcon: const Icon(Icons.inventory_2_outlined),
        filled: true,
        fillColor: context.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите количество';
        }
        final qty = int.tryParse(value);
        if (qty == null || qty < 1) {
          return 'Минимум 1';
        }
        return null;
      },
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
              if (_dueDate != null)
                Text(
                  'Срок: ${_dueDate!.day.toString().padLeft(2, '0')}.${_dueDate!.month.toString().padLeft(2, '0')}.${_dueDate!.year}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
            ],
          ),
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

// Searchable Client Bottom Sheet
class _SearchableClientSheet extends StatefulWidget {
  final List<Client> clients;
  final Client? selectedClient;
  final Function(Client) onSelected;

  const _SearchableClientSheet({
    required this.clients,
    required this.selectedClient,
    required this.onSelected,
  });

  @override
  State<_SearchableClientSheet> createState() => _SearchableClientSheetState();
}

class _SearchableClientSheetState extends State<_SearchableClientSheet> {
  final _searchController = TextEditingController();
  List<Client> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    _filteredClients = widget.clients;
  }

  void _filterClients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredClients = widget.clients;
      } else {
        _filteredClients = widget.clients.where((client) {
          return client.name.toLowerCase().contains(query.toLowerCase()) ||
              (client.contacts.phone?.contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Выберите заказчика',
              style: AppTypography.h4,
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterClients,
              decoration: InputDecoration(
                hintText: 'Поиск по имени или телефону',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: context.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: _filteredClients.isEmpty
                ? Center(
                    child: Text(
                      'Заказчики не найдены',
                      style: AppTypography.bodyLarge.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = _filteredClients[index];
                      final isSelected = widget.selectedClient?.id == client.id;

                      return ListTile(
                        onTap: () => widget.onSelected(client),
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.1),
                          child: Text(
                            client.name.isNotEmpty
                                ? client.name.substring(0, 1).toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(
                          client.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        subtitle: client.contacts.phone != null
                            ? Text(client.contacts.phone!)
                            : null,
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: AppColors.primary)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Searchable Model Bottom Sheet
class _SearchableModelSheet extends StatefulWidget {
  final List<OrderModel> models;
  final OrderModel? selectedModel;
  final Function(OrderModel) onSelected;

  const _SearchableModelSheet({
    required this.models,
    required this.selectedModel,
    required this.onSelected,
  });

  @override
  State<_SearchableModelSheet> createState() => _SearchableModelSheetState();
}

class _SearchableModelSheetState extends State<_SearchableModelSheet> {
  final _searchController = TextEditingController();
  List<OrderModel> _filteredModels = [];

  @override
  void initState() {
    super.initState();
    _filteredModels = widget.models;
  }

  void _filterModels(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredModels = widget.models;
      } else {
        _filteredModels = widget.models.where((model) {
          return model.name.toLowerCase().contains(query.toLowerCase()) ||
              (model.category?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Выберите модель',
              style: AppTypography.h4,
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterModels,
              decoration: InputDecoration(
                hintText: 'Поиск по названию или категории',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: context.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: _filteredModels.isEmpty
                ? Center(
                    child: Text(
                      'Модели не найдены',
                      style: AppTypography.bodyLarge.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _filteredModels.length,
                    itemBuilder: (context, index) {
                      final model = _filteredModels[index];
                      final isSelected = widget.selectedModel?.id == model.id;

                      return ListTile(
                        onTap: () => widget.onSelected(model),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.surfaceVariantColor,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: AppColors.primary, width: 2)
                                : null,
                          ),
                          child: model.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
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
                        title: Text(
                          model.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${model.basePrice.toStringAsFixed(0)} сом${model.category != null ? ' • ${model.category}' : ''}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: AppColors.primary)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
