import 'package:flutter/foundation.dart';
import '../models/client_user.dart';
import '../services/base_api_service.dart';
import '../services/client_api_service.dart';
import '../services/storage_service.dart';
import 'mixins/authentication_mixin.dart';
import 'mixins/pagination_mixin.dart';

void _log(String message) {
  debugPrint('[ClientProvider] $message');
}

class ClientProvider extends ChangeNotifier
    with AuthenticationMixin, PaginationMixin {
  final StorageService _storage;
  final ClientApiService _api;

  ClientUser? _user;
  List<TenantLink> _tenants = [];
  List<ClientOrder> _orders = [];

  // Pagination state using mixin
  late final PaginationState<ClientOrder> _ordersPagination;

  ClientProvider(this._storage) : _api = ClientApiService(_storage) {
    _ordersPagination = createPaginationController<ClientOrder>(
      logPrefix: 'ClientOrders',
    );
    BaseApiService.registerSessionExpiredCallback('client', _handleSessionExpired);
  }

  void _handleSessionExpired() {
    _log('Session expired - logging out');
    _storage.clearClientData();
    _user = null;
    _tenants = [];
    _orders = [];
    clearAllPagination();
    notifyListeners();
  }

  // ==================== Getters ====================

  ClientUser? get user => _user;
  List<TenantLink> get tenants => _tenants;
  List<ClientOrder> get orders => _orders;
  bool get isAuthenticated => _user != null;

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

  // ==================== Initialization ====================

  Future<void> init() async {
    final savedUser = await _storage.getClientUser();
    if (savedUser != null) {
      _user = savedUser;
      notifyListeners();
      await refreshData();
    }
  }

  // ==================== Authentication ====================

  Future<bool> login({String? email, String? phone, required String password}) async {
    return performAuthenticatedAction(
      action: () => _api.login(
        email: email,
        phone: phone,
        password: password,
      ),
      onSuccess: (response) async {
        _user = response.user;
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
      action: () => _api.register(
        email: email,
        phone: phone,
        password: password,
        name: name,
      ),
      onSuccess: (response) async {
        _user = response.user;
      },
      log: _log,
      actionName: 'registration',
    );
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      _user = null;
      _tenants = [];
      _orders = [];
      clearAllPagination();
      await _storage.clearClientData();
      notifyListeners();
    }
  }

  // ==================== Data Refresh ====================

  Future<void> refreshData() async {
    if (_user == null) return;

    try {
      _tenants = await _api.getMyTenants();
      await refreshOrders();
    } catch (e) {
      debugPrint('Error refreshing client data: $e');
    }
  }

  Future<void> refreshOrders({String? tenantId, String? status}) async {
    await _ordersPagination.refresh(
      fetcher: (page, limit) async {
        final response = await _api.getMyOrders(
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
        final response = await _api.getMyOrders(
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
    return _api.getTenantModels(tenantId);
  }

  Future<ClientOrder> createOrder({
    required String tenantId,
    required String modelId,
    required int quantity,
    String? dueDate,
  }) async {
    final order = await _api.createOrder(
      tenantId: tenantId,
      modelId: modelId,
      quantity: quantity,
      dueDate: dueDate,
    );
    await refreshOrders();
    return order;
  }

  Future<TenantLink> linkToTenant(String tenantId, {String? name}) async {
    final link = await _api.linkToTenant(tenantId, name: name);
    await refreshData();
    return link;
  }

  Future<ClientOrder> updateOrder({
    required String orderId,
    String? modelId,
    int? quantity,
    String? dueDate,
  }) async {
    final order = await _api.updateOrder(
      orderId: orderId,
      modelId: modelId,
      quantity: quantity,
      dueDate: dueDate,
    );
    await refreshOrders();
    return order;
  }

  Future<void> cancelOrder(String orderId) async {
    await _api.cancelOrder(orderId);
    await refreshOrders();
  }
}
