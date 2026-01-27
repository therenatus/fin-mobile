import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart';
import 'storage_provider.dart';

void _log(String message) {
  debugPrint('[DashboardNotifier] $message');
}

/// Dashboard state class with all data
class DashboardStateData {
  final bool isLoading;
  final DashboardStats? dashboardStats;
  final AnalyticsDashboard? analyticsDashboard;
  final FinanceReport? financeReport;
  final List<Order> recentOrders;
  final List<Client> clients;
  final List<EmployeeRole> employeeRoles;
  final String analyticsPeriod;

  // Errors
  final String? dashboardError;
  final String? ordersError;
  final String? clientsError;

  // Orders pagination
  final int ordersPage;
  final bool isLoadingMoreOrders;
  final bool hasMoreOrders;

  const DashboardStateData({
    this.isLoading = false,
    this.dashboardStats,
    this.analyticsDashboard,
    this.financeReport,
    this.recentOrders = const [],
    this.clients = const [],
    this.employeeRoles = const [],
    this.analyticsPeriod = 'month',
    this.dashboardError,
    this.ordersError,
    this.clientsError,
    this.ordersPage = 1,
    this.isLoadingMoreOrders = false,
    this.hasMoreOrders = true,
  });

  DashboardStateData copyWith({
    bool? isLoading,
    DashboardStats? dashboardStats,
    AnalyticsDashboard? analyticsDashboard,
    FinanceReport? financeReport,
    List<Order>? recentOrders,
    List<Client>? clients,
    List<EmployeeRole>? employeeRoles,
    String? analyticsPeriod,
    String? dashboardError,
    String? ordersError,
    String? clientsError,
    int? ordersPage,
    bool? isLoadingMoreOrders,
    bool? hasMoreOrders,
    bool clearDashboardError = false,
    bool clearOrdersError = false,
    bool clearClientsError = false,
    bool clearDashboardStats = false,
    bool clearAnalyticsDashboard = false,
    bool clearFinanceReport = false,
  }) {
    return DashboardStateData(
      isLoading: isLoading ?? this.isLoading,
      dashboardStats: clearDashboardStats ? null : (dashboardStats ?? this.dashboardStats),
      analyticsDashboard: clearAnalyticsDashboard ? null : (analyticsDashboard ?? this.analyticsDashboard),
      financeReport: clearFinanceReport ? null : (financeReport ?? this.financeReport),
      recentOrders: recentOrders ?? this.recentOrders,
      clients: clients ?? this.clients,
      employeeRoles: employeeRoles ?? this.employeeRoles,
      analyticsPeriod: analyticsPeriod ?? this.analyticsPeriod,
      dashboardError: clearDashboardError ? null : (dashboardError ?? this.dashboardError),
      ordersError: clearOrdersError ? null : (ordersError ?? this.ordersError),
      clientsError: clearClientsError ? null : (clientsError ?? this.clientsError),
      ordersPage: ordersPage ?? this.ordersPage,
      isLoadingMoreOrders: isLoadingMoreOrders ?? this.isLoadingMoreOrders,
      hasMoreOrders: hasMoreOrders ?? this.hasMoreOrders,
    );
  }

  String getRoleLabel(String code) {
    final role = employeeRoles.firstWhere(
      (r) => r.code == code,
      orElse: () => EmployeeRole(id: '', code: code, label: code, sortOrder: 0),
    );
    return role.label;
  }
}

/// Dashboard notifier for managing dashboard data.
class DashboardNotifier extends Notifier<DashboardStateData> {
  @override
  DashboardStateData build() {
    // Listen to auth state changes
    ref.listen<AuthStateData>(
      authNotifierProvider,
      (previous, next) {
        _log('Auth state changed: ${previous?.loadingState} -> ${next.loadingState}');
        if (next.isAuthenticated && previous?.isAuthenticated != true) {
          // User just logged in or app started with valid session - load dashboard data
          _log('User authenticated - loading dashboard data');
          Future.microtask(() => _loadDashboardData());
        } else if (!next.isAuthenticated && previous?.isAuthenticated == true) {
          // User logged out - clear data
          _log('User logged out - clearing data');
          state = const DashboardStateData();
        }
      },
      fireImmediately: true,
    );

    return const DashboardStateData();
  }

  ApiService get _api => ref.read(apiServiceProvider);

  Future<void> _loadDashboardData() async {
    state = state.copyWith(
      isLoading: true,
      clearDashboardError: true,
      clearOrdersError: true,
      clearClientsError: true,
    );

    // Load all data in parallel
    await Future.wait([
      _loadProfile(),
      _loadAnalytics(),
      _loadOrders(),
      _loadClients(),
      _loadFinanceReport(),
      _loadEmployeeRoles(),
    ], eagerError: false);

    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await _api.getProfile();
      _log('Profile data loaded');
      final user = User.fromJson(profileData);
      final storage = ref.read(storageServiceProvider);
      storage.saveUser(user);
      // Update user in auth provider
      ref.read(authNotifierProvider.notifier).updateUser(user);
    } catch (e) {
      _log('Failed to refresh user profile: $e');
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      final analyticsDashboard = await _api.getAnalyticsDashboard(
        period: state.analyticsPeriod,
      );
      state = state.copyWith(
        analyticsDashboard: analyticsDashboard,
        dashboardStats: analyticsDashboard.summary,
      );
    } catch (e) {
      _log('Failed to load analytics: $e');
      state = state.copyWith(
        clearDashboardStats: true,
        clearAnalyticsDashboard: true,
        dashboardError: e.toString(),
      );
    }
  }

  Future<void> _loadOrders() async {
    try {
      final ordersResponse = await _api.getOrders(page: 1, limit: 5);
      state = state.copyWith(recentOrders: ordersResponse.orders);
    } catch (e) {
      _log('Failed to load orders: $e');
      state = state.copyWith(
        recentOrders: [],
        ordersError: e.toString(),
      );
    }
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _api.getClients(page: 1, limit: 10);
      state = state.copyWith(clients: clients);
    } catch (e) {
      _log('Failed to load clients: $e');
      state = state.copyWith(
        clients: [],
        clientsError: e.toString(),
      );
    }
  }

  Future<void> _loadFinanceReport() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final financeReport = await _api.getFinanceReport(
        startDate: startOfMonth.toIso8601String().split('T')[0],
        endDate: now.toIso8601String().split('T')[0],
      );
      state = state.copyWith(financeReport: financeReport);
    } catch (e) {
      _log('Failed to load finance report: $e');
      state = state.copyWith(clearFinanceReport: true);
    }
  }

  Future<void> _loadEmployeeRoles() async {
    if (state.employeeRoles.isNotEmpty) return;

    try {
      final roles = await _api.getEmployeeRoles();
      state = state.copyWith(employeeRoles: roles);
    } catch (e) {
      _log('Failed to load employee roles: $e');
      state = state.copyWith(employeeRoles: []);
    }
  }

  Future<void> refreshDashboard() async {
    await _loadDashboardData();
  }

  Future<void> setAnalyticsPeriod(String period) async {
    if (state.analyticsPeriod == period) return;
    state = state.copyWith(analyticsPeriod: period);
    await _loadDashboardData();
  }

  // ============ Orders Pagination ============

  Future<void> refreshOrders({
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    state = state.copyWith(ordersPage: 1, hasMoreOrders: true);

    try {
      final response = await _api.getOrders(
        page: 1,
        limit: 20,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      state = state.copyWith(
        recentOrders: response.orders,
        hasMoreOrders: response.meta.page < response.meta.totalPages,
      );
    } catch (e) {
      _log('Error refreshing orders: $e');
    }
  }

  Future<void> loadMoreOrders({
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (state.isLoadingMoreOrders || !state.hasMoreOrders) return;

    state = state.copyWith(isLoadingMoreOrders: true);

    try {
      final response = await _api.getOrders(
        page: state.ordersPage + 1,
        limit: 20,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      state = state.copyWith(
        ordersPage: state.ordersPage + 1,
        recentOrders: [...state.recentOrders, ...response.orders],
        hasMoreOrders: response.meta.page < response.meta.totalPages,
        isLoadingMoreOrders: false,
      );
    } catch (e) {
      _log('Error loading more orders: $e');
      state = state.copyWith(isLoadingMoreOrders: false);
    }
  }

  /// Clear all dashboard data (called on logout)
  void clearData() {
    state = const DashboardStateData();
  }
}

/// Provider for dashboard state.
final dashboardNotifierProvider = NotifierProvider<DashboardNotifier, DashboardStateData>(
  DashboardNotifier.new,
);

// ============ Convenience Providers ============

/// Provider for dashboard loading state.
final isDashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardNotifierProvider).isLoading;
});

/// Provider for dashboard stats.
final dashboardStatsProvider = Provider<DashboardStats?>((ref) {
  return ref.watch(dashboardNotifierProvider).dashboardStats;
});

/// Provider for analytics dashboard.
final analyticsDashboardProvider = Provider<AnalyticsDashboard?>((ref) {
  return ref.watch(dashboardNotifierProvider).analyticsDashboard;
});

/// Provider for finance report.
final financeReportProvider = Provider<FinanceReport?>((ref) {
  return ref.watch(dashboardNotifierProvider).financeReport;
});

/// Provider for recent orders.
final recentOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(dashboardNotifierProvider).recentOrders;
});

/// Provider for clients list.
final clientsProvider = Provider<List<Client>>((ref) {
  return ref.watch(dashboardNotifierProvider).clients;
});

/// Provider for employee roles.
final employeeRolesProvider = Provider<List<EmployeeRole>>((ref) {
  return ref.watch(dashboardNotifierProvider).employeeRoles;
});

/// Provider for analytics period.
final analyticsPeriodProvider = Provider<String>((ref) {
  return ref.watch(dashboardNotifierProvider).analyticsPeriod;
});

/// Provider for dashboard errors.
final dashboardErrorProvider = Provider<String?>((ref) {
  return ref.watch(dashboardNotifierProvider).dashboardError;
});

/// Provider for orders error.
final ordersErrorProvider = Provider<String?>((ref) {
  return ref.watch(dashboardNotifierProvider).ordersError;
});

/// Provider for clients error.
final clientsErrorProvider = Provider<String?>((ref) {
  return ref.watch(dashboardNotifierProvider).clientsError;
});

/// Provider for orders pagination state.
final isLoadingMoreOrdersProvider = Provider<bool>((ref) {
  return ref.watch(dashboardNotifierProvider).isLoadingMoreOrders;
});

/// Provider for has more orders.
final hasMoreOrdersProvider = Provider<bool>((ref) {
  return ref.watch(dashboardNotifierProvider).hasMoreOrders;
});
