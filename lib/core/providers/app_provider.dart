import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/base_api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

void _log(String message) {
  debugPrint('[AppProvider] $message');
}

enum AppState { initial, loading, authenticated, unauthenticated, error }

/// Main application provider that manages auth state and coordinates other providers.
///
/// This is a refactored version that delegates to specialized providers:
/// - ThemeProvider: theme mode management
/// - DashboardProvider: dashboard data (use via AppProvider for now)
/// - OrdersProvider: orders pagination (use via AppProvider for now)
class AppProvider with ChangeNotifier {
  final StorageService _storage;
  late final ApiService _api;

  // Auth state
  AppState _state = AppState.initial;
  User? _user;
  String? _error;
  ThemeMode _themeMode = ThemeMode.system;

  // Dashboard data
  DashboardStats? _dashboardStats;
  AnalyticsDashboard? _analyticsDashboard;
  FinanceReport? _financeReport;
  List<Order> _recentOrders = [];
  List<Client> _clients = [];
  List<EmployeeRole> _employeeRoles = [];
  bool _isLoadingData = false;
  String _analyticsPeriod = 'month';

  // Dashboard errors
  String? _dashboardError;
  String? _ordersError;
  String? _clientsError;

  // Orders pagination state
  int _ordersPage = 1;
  bool _isLoadingMoreOrders = false;
  bool _hasMoreOrders = true;

  AppProvider(this._storage) {
    _api = ApiService(_storage);
    BaseApiService.registerSessionExpiredCallback('manager', _handleSessionExpired);
    _init();
  }

  void _handleSessionExpired() {
    _log('Session expired - logging out');
    _storage.clearTokens();
    _storage.clearUser();
    _user = null;
    _state = AppState.unauthenticated;
    notifyListeners();
  }

  // ============ Getters ============

  AppState get state => _state;
  User? get user => _user;
  String? get error => _error;
  ThemeMode get themeMode => _themeMode;
  bool get isAuthenticated => _state == AppState.authenticated;
  bool get isLoading => _state == AppState.loading || _isLoadingData;
  ApiService get api => _api;

  DashboardStats? get dashboardStats => _dashboardStats;
  AnalyticsDashboard? get analyticsDashboard => _analyticsDashboard;
  FinanceReport? get financeReport => _financeReport;
  String get analyticsPeriod => _analyticsPeriod;
  List<Order> get recentOrders => _recentOrders;
  List<Client> get clients => _clients;
  List<EmployeeRole> get employeeRoles => _employeeRoles;
  bool get isLoadingMoreOrders => _isLoadingMoreOrders;
  bool get hasMoreOrders => _hasMoreOrders;
  String? get dashboardError => _dashboardError;
  String? get ordersError => _ordersError;
  String? get clientsError => _clientsError;

  String getRoleLabel(String code) {
    final role = _employeeRoles.firstWhere(
      (r) => r.code == code,
      orElse: () => EmployeeRole(id: '', code: code, label: code, sortOrder: 0),
    );
    return role.label;
  }

  // ============ Initialization ============

  Future<void> _init() async {
    _state = AppState.loading;
    notifyListeners();

    try {
      // Load theme
      final themeModeStr = await _storage.getThemeMode();
      _themeMode = _parseThemeMode(themeModeStr);

      // Check for saved session
      final hasTokens = await _storage.hasTokens();
      if (hasTokens) {
        _user = await _storage.getUser();
        if (_user != null) {
          _state = AppState.authenticated;
          _loadDashboardData();
        } else {
          _state = AppState.unauthenticated;
        }
      } else {
        _state = AppState.unauthenticated;
      }
    } catch (e) {
      _state = AppState.unauthenticated;
      _error = e.toString();
    }

    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // ============ Auth Methods ============

  Future<bool> login(String email, String password) async {
    _log('login() called with email: $email');
    _state = AppState.loading;
    _error = null;
    notifyListeners();

    try {
      _log('Calling api.login()...');
      final response = await _api.login(email, password);
      _log('Login response received, user: ${response.user.email}');
      _user = response.user;
      _state = AppState.authenticated;
      notifyListeners();

      // Set Sentry user context for error tracking
      Sentry.configureScope((scope) {
        scope.setUser(SentryUser(id: _user!.id, email: _user!.email));
        scope.setTag('tenant_id', _user!.tenantId);
      });

      _loadDashboardData();
      _registerPushDevice();

      return true;
    } on ApiException catch (e) {
      _log('ApiException: ${e.message}, code: ${e.statusCode}');
      _error = e.message;
      _state = AppState.unauthenticated;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _log('General error: $e');
      _log('Stack trace: $stackTrace');
      _error = 'Не удалось подключиться к серверу: $e';
      _state = AppState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String businessName) async {
    _state = AppState.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.register(email, password, businessName);
      _user = response.user;
      _state = AppState.authenticated;
      notifyListeners();

      _loadDashboardData();
      _registerPushDevice();

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _state = AppState.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Не удалось подключиться к серверу';
      _state = AppState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.unregisterPushDevice();
      NotificationService.instance.clearUser();
      await _api.logout();
    } finally {
      _user = null;
      _dashboardStats = null;
      _analyticsDashboard = null;
      _financeReport = null;
      _recentOrders = [];
      _clients = [];
      _state = AppState.unauthenticated;

      // Clear Sentry user context
      Sentry.configureScope((scope) {
        scope.setUser(null);
        scope.removeTag('tenant_id');
      });

      notifyListeners();
    }
  }

  void updateUser(User user) {
    _user = user;
    _storage.saveUser(user);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _registerPushDevice() async {
    try {
      final playerId = await NotificationService.instance.getPlayerId();
      if (playerId != null && _user != null) {
        await _api.registerPushDevice(playerId);
        NotificationService.instance.setExternalUserId(_user!.id);
        NotificationService.instance.setTenantTag(_user!.tenantId);
        NotificationService.instance.setRoleTag('manager');
        _log('Push device registered successfully');
      }
    } catch (e) {
      _log('Failed to register push device: $e');
    }
  }

  // ============ Theme ============

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final modeStr = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await _storage.saveThemeMode(modeStr);
    notifyListeners();
  }

  // ============ Dashboard Data ============

  Future<void> _loadDashboardData() async {
    _isLoadingData = true;
    _dashboardError = null;
    _ordersError = null;
    _clientsError = null;
    notifyListeners();

    // Refresh user profile from server
    try {
      final profileData = await _api.getProfile();
      _log('Profile data: $profileData');
      _user = User.fromJson(profileData);
      _storage.saveUser(_user!);
      notifyListeners();
    } catch (e) {
      _log('Failed to refresh user profile: $e');
    }

    // Load analytics dashboard
    try {
      _analyticsDashboard = await _api.getAnalyticsDashboard(period: _analyticsPeriod);
      _dashboardStats = _analyticsDashboard?.summary;
    } catch (e) {
      _log('Failed to load analytics: $e');
      _dashboardStats = null;
      _analyticsDashboard = null;
      _dashboardError = e.toString();
    }

    // Load recent orders
    try {
      final ordersResponse = await _api.getOrders(page: 1, limit: 5);
      _recentOrders = ordersResponse.orders;
    } catch (e) {
      _log('Failed to load orders: $e');
      _recentOrders = [];
      _ordersError = e.toString();
    }

    // Load clients
    try {
      _clients = await _api.getClients(page: 1, limit: 10);
    } catch (e) {
      _log('Failed to load clients: $e');
      _clients = [];
      _clientsError = e.toString();
    }

    // Load finance report for current month
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      _financeReport = await _api.getFinanceReport(
        startDate: startOfMonth.toIso8601String().split('T')[0],
        endDate: now.toIso8601String().split('T')[0],
      );
    } catch (e) {
      _financeReport = null;
    }

    // Load employee roles
    if (_employeeRoles.isEmpty) {
      try {
        _employeeRoles = await _api.getEmployeeRoles();
      } catch (e) {
        _employeeRoles = [];
      }
    }

    _isLoadingData = false;
    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    await _loadDashboardData();
  }

  Future<void> setAnalyticsPeriod(String period) async {
    if (_analyticsPeriod == period) return;
    _analyticsPeriod = period;
    await _loadDashboardData();
  }

  // ============ Orders Pagination ============

  Future<void> refreshOrders({
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    _ordersPage = 1;
    _hasMoreOrders = true;

    try {
      final response = await _api.getOrders(
        page: 1,
        limit: 20,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      _recentOrders = response.orders;
      _hasMoreOrders = response.meta.page < response.meta.totalPages;
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing orders: $e');
    }
  }

  Future<void> loadMoreOrders({
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (_isLoadingMoreOrders || !_hasMoreOrders) return;

    _isLoadingMoreOrders = true;
    notifyListeners();

    try {
      final response = await _api.getOrders(
        page: _ordersPage + 1,
        limit: 20,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      _ordersPage++;
      _recentOrders.addAll(response.orders);
      _hasMoreOrders = response.meta.page < response.meta.totalPages;
    } catch (e) {
      debugPrint('Error loading more orders: $e');
    } finally {
      _isLoadingMoreOrders = false;
      notifyListeners();
    }
  }
}
