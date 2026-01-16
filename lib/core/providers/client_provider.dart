import 'package:flutter/foundation.dart';
import '../models/client_user.dart';
import '../services/client_api_service.dart';
import '../services/storage_service.dart';
import 'base_user_provider.dart';
import 'mixins/pagination_mixin.dart';

void _log(String message) {
  debugPrint('[ClientProvider] $message');
}

class ClientProvider extends BaseUserProvider<ClientUser, ClientApiService> {
  List<TenantLink> _tenants = [];
  List<ClientOrder> _orders = [];

  // Pagination state using mixin
  late final PaginationState<ClientOrder> _ordersPagination;

  ClientProvider(StorageService storage)
      : super(
          storage: storage,
          api: ClientApiService(storage),
          modeName: 'client',
        ) {
    _ordersPagination = createPaginationController<ClientOrder>(
      logPrefix: 'ClientOrders',
    );
  }

  // ==================== Getters ====================

  List<TenantLink> get tenants => _tenants;
  List<ClientOrder> get orders => _orders;

  // Pagination getters - delegate to PaginationState
  bool get isLoadingMoreOrders => _ordersPagination.isLoadingMore;
  bool get hasMoreOrders => _ordersPagination.hasMore;

  List<ClientOrder> getOrdersForTenant(String tenantId) {
    return _orders.where((o) => o.tenantId == tenantId).toList();
  }

  double getTotalSpentForTenant(String tenantId) {
    return getOrdersForTenant(tenantId)
        .fold(0.0, (sum, order) => sum + order.totalCost);
  }

  int getOrdersCountForTenant(String tenantId) {
    return getOrdersForTenant(tenantId).length;
  }

  int getPendingOrdersCountForTenant(String tenantId) {
    return getOrdersForTenant(tenantId)
        .where((o) => o.status == 'pending')
        .length;
  }

  // ==================== Abstract Method Implementations ====================

  @override
  Future<ClientUser?> loadSavedUser() => storage.getClientUser();

  @override
  Future<void> clearUserData() => storage.clearClientData();

  @override
  void clearDomainData() {
    _tenants = [];
    _orders = [];
  }

  @override
  Future<void> refreshData() async {
    if (user == null) return;

    try {
      _tenants = await api.getMyTenants();
      await refreshOrders();
    } catch (e) {
      debugPrint('Error refreshing client data: $e');
    }
  }

  // ==================== Authentication ====================

  Future<bool> login({String? email, String? phone, required String password}) async {
    return performAuthenticatedAction(
      action: () => api.login(
        email: email,
        phone: phone,
        password: password,
      ),
      onSuccess: (response) async {
        setUser(response.user);
        await refreshData();
      },
      log: _log,
      actionName: 'login',
    );
  }

  Future<bool> register({
    String? email,
    String? phone,
    required String password,
    required String name,
  }) async {
    return performAuthenticatedAction(
      action: () => api.register(
        email: email,
        phone: phone,
        password: password,
        name: name,
      ),
      onSuccess: (response) async {
        setUser(response.user);
      },
      log: _log,
      actionName: 'registration',
    );
  }

  @override
  Future<void> logout() async {
    try {
      await api.logout();
    } finally {
      await super.logout();
    }
  }

  // ==================== Data Refresh ====================

  Future<void> refreshOrders({String? tenantId, String? status}) async {
    await _ordersPagination.refresh(
      fetcher: (page, limit) async {
        final response = await api.getMyOrders(
          tenantId: tenantId,
          page: page,
          limit: limit,
          status: status,
        );
        return PaginatedResult(
          items: response.orders,
          meta: PaginationMeta.fromHasNextPage(
            response.meta.page,
            response.meta.hasNextPage,
          ),
        );
      },
      onUpdate: () {
        _orders = _ordersPagination.items;
        notifyListeners();
      },
    );
  }

  Future<void> loadMoreOrders({String? tenantId, String? status}) async {
    await _ordersPagination.loadMore(
      fetcher: (page, limit) async {
        final response = await api.getMyOrders(
          tenantId: tenantId,
          page: page,
          limit: limit,
          status: status,
        );
        return PaginatedResult(
          items: response.orders,
          meta: PaginationMeta.fromHasNextPage(
            response.meta.page,
            response.meta.hasNextPage,
          ),
        );
      },
      onUpdate: () {
        _orders = _ordersPagination.items;
        notifyListeners();
      },
    );
  }

  // ==================== Orders Operations ====================

  Future<List<ClientOrderModel>> getTenantModels(String tenantId) async {
    return api.getTenantModels(tenantId);
  }

  Future<ClientOrder> createOrder({
    required String tenantId,
    required String modelId,
    required int quantity,
    String? dueDate,
  }) async {
    final order = await api.createOrder(
      tenantId: tenantId,
      modelId: modelId,
      quantity: quantity,
      dueDate: dueDate,
    );
    await refreshOrders();
    return order;
  }

  Future<TenantLink> linkToTenant(String tenantId, {String? name}) async {
    final link = await api.linkToTenant(tenantId, name: name);
    await refreshData();
    return link;
  }

  Future<ClientOrder> updateOrder({
    required String orderId,
    String? modelId,
    int? quantity,
    String? dueDate,
  }) async {
    final order = await api.updateOrder(
      orderId: orderId,
      modelId: modelId,
      quantity: quantity,
      dueDate: dueDate,
    );
    await refreshOrders();
    return order;
  }

  Future<void> cancelOrder(String orderId) async {
    await api.cancelOrder(orderId);
    await refreshOrders();
  }
}
