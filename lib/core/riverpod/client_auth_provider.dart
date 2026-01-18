import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/client_user.dart';
import '../services/client_api_service.dart';
import 'base_auth_state.dart';
import 'base_auth_notifier.dart';
import 'storage_provider.dart';

void _log(String message) {
  debugPrint('[ClientAuthNotifier] $message');
}

/// Client auth state enum - maps to shared AuthLoadingState for compatibility
@Deprecated('Use AuthLoadingState instead')
typedef ClientAuthState = AuthLoadingState;

/// Client auth state class with user data
class ClientAuthStateData implements BaseAuthStateData<ClientUser> {
  @override
  final AuthLoadingState loadingState;
  @override
  final ClientUser? user;
  @override
  final String? error;

  // Client-specific fields
  final List<TenantLink> tenants;
  final List<ClientOrder> orders;
  final bool isLoadingMoreOrders;
  final bool hasMoreOrders;
  final int ordersPage;

  const ClientAuthStateData({
    this.loadingState = AuthLoadingState.initial,
    this.user,
    this.error,
    this.tenants = const [],
    this.orders = const [],
    this.isLoadingMoreOrders = false,
    this.hasMoreOrders = true,
    this.ordersPage = 1,
  });

  /// Legacy getter for backwards compatibility
  AuthLoadingState get state => loadingState;

  @override
  bool get isAuthenticated => loadingState == AuthLoadingState.authenticated;

  @override
  bool get isLoading => loadingState == AuthLoadingState.loading;

  ClientAuthStateData copyWith({
    AuthLoadingState? loadingState,
    AuthLoadingState? state, // Legacy parameter name
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
      loadingState: loadingState ?? state ?? this.loadingState,
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
class ClientAuthNotifier extends BaseAuthNotifier<ClientAuthStateData, ClientUser> {
  @override
  String get authType => 'client';

  @override
  ClientAuthStateData get initialState =>
      const ClientAuthStateData(loadingState: AuthLoadingState.loading);

  @override
  ClientAuthStateData createAuthenticatedState(ClientUser user) =>
      ClientAuthStateData(loadingState: AuthLoadingState.authenticated, user: user);

  @override
  ClientAuthStateData createUnauthenticatedState({String? error}) =>
      ClientAuthStateData(loadingState: AuthLoadingState.unauthenticated, error: error);

  @override
  ClientAuthStateData createLoadingState() =>
      state.copyWith(loadingState: AuthLoadingState.loading, clearError: true);

  ClientApiService get _api => ref.read(clientApiServiceProvider);

  @override
  Future<ClientUser?> loadUserFromStorage() async {
    final storage = ref.read(storageServiceProvider);
    return storage.getClientUser();
  }

  @override
  Future<void> clearStorage() async {
    final storage = ref.read(storageServiceProvider);
    await storage.clearClientData();
  }

  @override
  Future<void> onInitWithUser(ClientUser user) async {
    await refreshData();
  }

  Future<bool> login({String? email, String? phone, required String password}) async {
    _log('login() called');

    final success = await performLogin<ClientApiException>(
      apiCall: () async {
        final response = await _api.login(
          email: email,
          phone: phone,
          password: password,
        );
        _log('Login successful, user: ${response.user.name}');
        return response.user;
      },
      getApiExceptionMessage: (e) {
        _log('ClientApiException: ${e.message}');
        return e.message;
      },
    );

    if (success) {
      await refreshData();
    }
    return success;
  }

  Future<bool> register({
    String? email,
    String? phone,
    required String password,
    required String name,
  }) async {
    state = createLoadingState();

    try {
      final response = await _api.register(
        email: email,
        phone: phone,
        password: password,
        name: name,
      );

      state = createAuthenticatedState(response.user);
      return true;
    } on ClientApiException catch (e) {
      state = createUnauthenticatedState(error: e.message);
      return false;
    } catch (e) {
      state = createUnauthenticatedState(
        error: 'Не удалось подключиться к серверу',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await performLogout(apiLogout: () => _api.logout());
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

  @override
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
