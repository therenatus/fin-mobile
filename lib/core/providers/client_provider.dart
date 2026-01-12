import 'package:flutter/foundation.dart';
import '../models/client_user.dart';
import '../services/base_api_service.dart';
import '../services/client_api_service.dart';
import '../services/storage_service.dart';

void _log(String message) {
  debugPrint('[ClientProvider] $message');
}

class ClientProvider extends ChangeNotifier {
  final StorageService _storage;
  final ClientApiService _api;

  ClientUser? _user;
  List<TenantLink> _tenants = [];
  List<ClientOrder> _orders = [];
  bool _isLoading = false;
  String? _error;

  // Pagination state for orders
  int _ordersPage = 1;
  bool _isLoadingMoreOrders = false;
  bool _hasMoreOrders = true;

  ClientProvider(this._storage) : _api = ClientApiService(_storage) {
    // Регистрируем callback для обработки истечения сессии
    BaseApiService.registerSessionExpiredCallback('client', _handleSessionExpired);
  }

  /// Обработка истечения сессии
  void _handleSessionExpired() {
    _log('Session expired - logging out');
    _storage.clearClientData();
    _user = null;
    _tenants = [];
    _orders = [];
    _isLoading = false;
    notifyListeners();
  }

  ClientUser? get user => _user;
  List<TenantLink> get tenants => _tenants;
  List<ClientOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isLoadingMoreOrders => _isLoadingMoreOrders;
  bool get hasMoreOrders => _hasMoreOrders;

  /// Получить заказы для конкретного ателье
  List<ClientOrder> getOrdersForTenant(String tenantId) {
    return _orders.where((o) => o.tenantId == tenantId).toList();
  }

  /// Получить общую сумму заказов для ателье
  double getTotalSpentForTenant(String tenantId) {
    return getOrdersForTenant(tenantId)
        .fold(0.0, (sum, order) => sum + order.totalCost);
  }

  /// Получить количество заказов для ателье
  int getOrdersCountForTenant(String tenantId) {
    return getOrdersForTenant(tenantId).length;
  }

  /// Получить количество заказов в ожидании для ателье
  int getPendingOrdersCountForTenant(String tenantId) {
    return getOrdersForTenant(tenantId)
        .where((o) => o.status == 'pending')
        .length;
  }

  Future<void> init() async {
    final savedUser = await _storage.getClientUser();
    if (savedUser != null) {
      _user = savedUser;
      notifyListeners();
      await refreshData();
    }
  }

  Future<bool> login({String? email, String? phone, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _log('Attempting login...');
      final response = await _api.login(
        email: email,
        phone: phone,
        password: password,
      );
      _log('Login successful');
      _user = response.user;
      await refreshData();
      return true;
    } on ClientApiException catch (e) {
      _log('API error: ${e.message}, code: ${e.statusCode}');
      _error = e.message;
      return false;
    } catch (e) {
      _log('Unexpected error: $e');
      _error = 'Не удалось подключиться к серверу';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    String? email,
    String? phone,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _log('Attempting registration...');
      final response = await _api.register(
        email: email,
        phone: phone,
        password: password,
        name: name,
      );
      _log('Registration successful');
      _user = response.user;
      notifyListeners();
      return true;
    } on ClientApiException catch (e) {
      _log('API error: ${e.message}, code: ${e.statusCode}');
      _error = e.message;
      return false;
    } catch (e) {
      _log('Unexpected error: $e');
      _error = 'Не удалось подключиться к серверу';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      _user = null;
      _tenants = [];
      _orders = [];
      await _storage.clearClientData();
      notifyListeners();
    }
  }

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
    _ordersPage = 1;
    _hasMoreOrders = true;

    try {
      final response = await _api.getMyOrders(
        tenantId: tenantId,
        page: 1,
        limit: 20,
        status: status,
      );
      _orders = response.orders;
      _hasMoreOrders = response.meta.hasNextPage;
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing orders: $e');
    }
  }

  Future<void> loadMoreOrders({String? tenantId, String? status}) async {
    if (_isLoadingMoreOrders || !_hasMoreOrders) return;

    _isLoadingMoreOrders = true;
    notifyListeners();

    try {
      final response = await _api.getMyOrders(
        tenantId: tenantId,
        page: _ordersPage + 1,
        limit: 20,
        status: status,
      );
      _ordersPage++;
      _orders.addAll(response.orders);
      _hasMoreOrders = response.meta.hasNextPage;
    } catch (e) {
      debugPrint('Error loading more orders: $e');
    } finally {
      _isLoadingMoreOrders = false;
      notifyListeners();
    }
  }

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
