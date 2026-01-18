import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/client_user.dart';
import '../services/client_api_service.dart';
import '../services/base_api_service.dart';
import 'storage_provider.dart';

void _log(String message) {
  debugPrint('[ClientAuthNotifier] $message');
}

/// Client auth state enum
enum ClientAuthState { initial, loading, authenticated, unauthenticated, error }

/// Client auth state class with user data
class ClientAuthStateData {
  final ClientAuthState state;
  final ClientUser? user;
  final String? error;
  final List<TenantLink> tenants;
  final List<ClientOrder> orders;
  final bool isLoadingMoreOrders;
  final bool hasMoreOrders;
  final int ordersPage;

  const ClientAuthStateData({
    this.state = ClientAuthState.initial,
    this.user,
    this.error,
    this.tenants = const [],
    this.orders = const [],
    this.isLoadingMoreOrders = false,
    this.hasMoreOrders = true,
    this.ordersPage = 1,
  });

  bool get isAuthenticated => state == ClientAuthState.authenticated;
  bool get isLoading => state == ClientAuthState.loading;

  ClientAuthStateData copyWith({
    ClientAuthState? state,
    ClientUser? user,
    String? error,
    List<TenantLink>? tenants,
    List<ClientOrder>? orders,
    bool? isLoadingMoreOrders,
    bool? hasMoreOrders,
    int? ordersPage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return ClientAuthStateData(
      state: state ?? this.state,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      tenants: tenants ?? this.tenants,
      orders: orders ?? this.orders,
      isLoadingMoreOrders: isLoadingMoreOrders ?? this.isLoadingMoreOrders,
      hasMoreOrders: hasMoreOrders ?? this.hasMoreOrders,
      ordersPage: ordersPage ?? this.ordersPage,
    );
  }

  List<ClientOrder> getOrdersForTenant(String tenantId) {
    return orders.where((o) => o.tenantId == tenantId).toList();
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
}

/// Provider for ClientApiService
final clientApiServiceProvider = Provider<ClientApiService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ClientApiService(storage);
});

/// Client auth notifier for managing client authentication state.
class ClientAuthNotifier extends Notifier<ClientAuthStateData> {
  @override
  ClientAuthStateData build() {
    BaseApiService.registerSessionExpiredCallback('client', _handleSessionExpired);
    _init();
    return const ClientAuthStateData(state: ClientAuthState.loading);
  }

  ClientApiService get _api => ref.read(clientApiServiceProvider);

  void _handleSessionExpired() {
    _log('Session expired - logging out');
    final storage = ref.read(storageServiceProvider);
    storage.clearClientTokens();
    storage.clearClientData();
    state = const ClientAuthStateData(state: ClientAuthState.unauthenticated);
  }

  Future<void> _init() async {
    final storage = ref.read(storageServiceProvider);

    try {
      final user = await storage.getClientUser();
      if (user != null) {
        state = ClientAuthStateData(state: ClientAuthState.authenticated, user: user);
        await refreshData();
        return;
      }
      state = const ClientAuthStateData(state: ClientAuthState.unauthenticated);
    } catch (e) {
      state = ClientAuthStateData(
        state: ClientAuthState.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<bool> login({String? email, String? phone, required String password}) async {
    _log('login() called');
    state = state.copyWith(state: ClientAuthState.loading, clearError: true);

    try {
      final response = await _api.login(
        email: email,
        phone: phone,
        password: password,
      );
      _log('Login successful, user: ${response.user.name}');

      state = ClientAuthStateData(
        state: ClientAuthState.authenticated,
        user: response.user,
      );

      await refreshData();
      return true;
    } on ClientApiException catch (e) {
      _log('ClientApiException: ${e.message}');
      state = ClientAuthStateData(
        state: ClientAuthState.unauthenticated,
        error: e.message,
      );
      return false;
    } catch (e) {
      _log('General error: $e');
      state = ClientAuthStateData(
        state: ClientAuthState.unauthenticated,
        error: 'Не удалось подключиться к серверу: $e',
      );
      return false;
    }
  }

  Future<bool> register({
    String? email,
    String? phone,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(state: ClientAuthState.loading, clearError: true);

    try {
      final response = await _api.register(
        email: email,
        phone: phone,
        password: password,
        name: name,
      );

      state = ClientAuthStateData(
        state: ClientAuthState.authenticated,
        user: response.user,
      );

      return true;
    } on ClientApiException catch (e) {
      state = ClientAuthStateData(
        state: ClientAuthState.unauthenticated,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = ClientAuthStateData(
        state: ClientAuthState.unauthenticated,
        error: 'Не удалось подключиться к серверу',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      final storage = ref.read(storageServiceProvider);
      await storage.clearClientData();
      state = const ClientAuthStateData(state: ClientAuthState.unauthenticated);
    }
  }

  Future<void> refreshData() async {
    if (state.user == null) return;

    try {
      final tenants = await _api.getMyTenants();
      state = state.copyWith(tenants: tenants);
      await refreshOrders();
    } catch (e) {
      _log('Error refreshing data: $e');
    }
  }

  Future<void> refreshOrders({String? tenantId, String? status}) async {
    try {
      final response = await _api.getMyOrders(
        tenantId: tenantId,
        page: 1,
        limit: 20,
        status: status,
      );
      state = state.copyWith(
        orders: response.orders,
        hasMoreOrders: response.meta.hasNextPage,
        ordersPage: 1,
      );
    } catch (e) {
      _log('Error refreshing orders: $e');
    }
  }

  Future<void> loadMoreOrders({String? tenantId, String? status}) async {
    if (state.isLoadingMoreOrders || !state.hasMoreOrders) return;

    state = state.copyWith(isLoadingMoreOrders: true);

    try {
      final response = await _api.getMyOrders(
        tenantId: tenantId,
        page: state.ordersPage + 1,
        limit: 20,
        status: status,
      );
      state = state.copyWith(
        orders: [...state.orders, ...response.orders],
        hasMoreOrders: response.meta.hasNextPage,
        ordersPage: state.ordersPage + 1,
        isLoadingMoreOrders: false,
      );
    } catch (e) {
      _log('Error loading more orders: $e');
      state = state.copyWith(isLoadingMoreOrders: false);
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

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for client auth state.
final clientAuthNotifierProvider = NotifierProvider<ClientAuthNotifier, ClientAuthStateData>(
  ClientAuthNotifier.new,
);

/// Convenience provider for checking if client is authenticated.
final isClientAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(clientAuthNotifierProvider).isAuthenticated;
});

/// Convenience provider for current client user.
final currentClientUserProvider = Provider<ClientUser?>((ref) {
  return ref.watch(clientAuthNotifierProvider).user;
});

/// Convenience provider for client tenants.
final clientTenantsProvider = Provider<List<TenantLink>>((ref) {
  return ref.watch(clientAuthNotifierProvider).tenants;
});

/// Convenience provider for client orders.
final clientOrdersProvider = Provider<List<ClientOrder>>((ref) {
  return ref.watch(clientAuthNotifierProvider).orders;
});
