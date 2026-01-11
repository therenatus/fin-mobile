import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

void _log(String message) {
  debugPrint('[AppProvider] $message');
}

enum AppState { initial, loading, authenticated, unauthenticated, error }

class AppProvider with ChangeNotifier {
  final StorageService _storage;
  late final ApiService _api;

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

  // Orders pagination state
  int _ordersPage = 1;
  bool _isLoadingMoreOrders = false;
  bool _hasMoreOrders = true;

  AppProvider(this._storage) {
    _api = ApiService(_storage);
    // Регистрируем callback для обработки истечения сессии
    ApiService.onSessionExpired = _handleSessionExpired;
    _init();
  }

  /// Обработка истечения сессии - выход без вызова API
  void _handleSessionExpired() {
    _log('Session expired - logging out');
    _storage.clearTokens();
    _storage.clearUser();
    _user = null;
    _state = AppState.unauthenticated;
    notifyListeners();
  }

  // Getters
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

  /// Получить label роли по коду
  String getRoleLabel(String code) {
    final role = _employeeRoles.firstWhere(
      (r) => r.code == code,
      orElse: () => EmployeeRole(id: '', code: code, label: code, sortOrder: 0),
    );
    return role.label;
  }

  // Initialization
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
          // Load dashboard data in background
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

  // Auth methods
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

      // Load dashboard data
      _loadDashboardData();

      // Register push notification device
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

  /// Register device for push notifications
  Future<void> _registerPushDevice() async {
    try {
      final playerId = await NotificationService.instance.getPlayerId();
      if (playerId != null && _user != null) {
        await _api.registerPushDevice(playerId);
        // Set user context for OneSignal
        NotificationService.instance.setExternalUserId(_user!.id);
        NotificationService.instance.setTenantTag(_user!.tenantId);
        NotificationService.instance.setRoleTag('manager');
        _log('Push device registered successfully');
      }
    } catch (e) {
      _log('Failed to register push device: $e');
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

      // Register push notification device
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
      // Unregister push notification device
      await _api.unregisterPushDevice();
      NotificationService.instance.clearUser();
      await _api.logout();
    } finally {
      _user = null;
      _dashboardStats = null;
      _recentOrders = [];
      _clients = [];
      _state = AppState.unauthenticated;
      notifyListeners();
    }
  }

  /// Update user data (e.g. after avatar upload)
  void updateUser(User user) {
    _user = user;
    _storage.saveUser(user);
    notifyListeners();
  }

  // Data loading
  Future<void> _loadDashboardData() async {
    _isLoadingData = true;
    notifyListeners();

    // Refresh user profile from server
    try {
      final profileData = await _api.getProfile();
      _log('Profile data: $profileData');
      _log('avatarUrl from API: ${profileData['avatarUrl']}');
      _user = User.fromJson(profileData);
      _log('User avatarUrl after parse: ${_user?.avatarUrl}');
      _storage.saveUser(_user!);
      notifyListeners(); // Notify UI about updated user
    } catch (e) {
      _log('Failed to refresh user profile: $e');
    }

    try {
      _analyticsDashboard = await _api.getAnalyticsDashboard(period: _analyticsPeriod);
      _dashboardStats = _analyticsDashboard?.summary;
    } catch (e) {
      // Use mock stats
      _dashboardStats = _getMockStats();
      _analyticsDashboard = null;
    }

    // Load recent orders
    try {
      final ordersResponse = await _api.getOrders(page: 1, limit: 5);
      _recentOrders = ordersResponse.orders;
    } catch (e) {
      // Ignore - use mock data
      _recentOrders = _getMockOrders();
    }

    // Load clients
    try {
      _clients = await _api.getClients(page: 1, limit: 10);
    } catch (e) {
      // Ignore - use mock data
      _clients = _getMockClients();
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

    // Load employee roles (if not loaded)
    if (_employeeRoles.isEmpty) {
      try {
        _employeeRoles = await _api.getEmployeeRoles();
      } catch (e) {
        // Use default roles if API fails
        _employeeRoles = [];
      }
    }

    _isLoadingData = false;
    notifyListeners();
  }

  DashboardStats _getMockStats() {
    return DashboardStats(
      totalOrders: 24,
      activeOrders: 8,
      completedOrders: 14,
      pendingOrders: 2,
      overdueOrders: 1,
      totalRevenue: 485000,
      periodRevenue: 125000,
      avgOrderValue: 15200,
      totalClients: 42,
      newClients: 8,
    );
  }

  Future<void> refreshDashboard() async {
    await _loadDashboardData();
  }

  Future<void> setAnalyticsPeriod(String period) async {
    if (_analyticsPeriod == period) return;
    _analyticsPeriod = period;
    await _loadDashboardData();
  }

  // Theme
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

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Mock data for demo
  List<Order> _getMockOrders() {
    final now = DateTime.now();
    return [
      Order(
        id: '1',
        clientId: '1',
        modelId: '1',
        quantity: 2,
        status: OrderStatus.inProgress,
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
        client: Client(
          id: '1',
          name: 'Анна Петрова',
          contacts: ClientContact(phone: '+7 999 123-45-67'),
          createdAt: now,
          updatedAt: now,
        ),
        model: OrderModel(
          id: '1',
          name: 'Вечернее платье',
          basePrice: 25000,
        ),
      ),
      Order(
        id: '2',
        clientId: '2',
        modelId: '2',
        quantity: 1,
        status: OrderStatus.pending,
        dueDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        client: Client(
          id: '2',
          name: 'Мария Сидорова',
          contacts: ClientContact(phone: '+7 999 765-43-21'),
          createdAt: now,
          updatedAt: now,
        ),
        model: OrderModel(
          id: '2',
          name: 'Деловой костюм',
          basePrice: 35000,
        ),
      ),
      Order(
        id: '3',
        clientId: '3',
        modelId: '3',
        quantity: 3,
        status: OrderStatus.completed,
        dueDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
        client: Client(
          id: '3',
          name: 'Елена Козлова',
          contacts: ClientContact(phone: '+7 999 111-22-33'),
          createdAt: now,
          updatedAt: now,
        ),
        model: OrderModel(
          id: '3',
          name: 'Свадебное платье',
          basePrice: 85000,
        ),
      ),
    ];
  }

  List<Client> _getMockClients() {
    final now = DateTime.now();
    return [
      Client(
        id: '1',
        name: 'Анна Петрова',
        contacts: ClientContact(phone: '+7 999 123-45-67', email: 'anna@mail.ru'),
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now,
        ordersCount: 8,
        totalSpent: 125000,
      ),
      Client(
        id: '2',
        name: 'Мария Сидорова',
        contacts: ClientContact(phone: '+7 999 765-43-21'),
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        ordersCount: 3,
        totalSpent: 45000,
      ),
      Client(
        id: '3',
        name: 'Елена Козлова',
        contacts: ClientContact(phone: '+7 999 111-22-33'),
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now,
        ordersCount: 15,
        totalSpent: 380000,
      ),
      Client(
        id: '4',
        name: 'Ольга Новикова',
        contacts: ClientContact(phone: '+7 999 444-55-66'),
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
        ordersCount: 5,
        totalSpent: 67000,
      ),
      Client(
        id: '5',
        name: 'Татьяна Морозова',
        contacts: ClientContact(phone: '+7 999 777-88-99'),
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now,
        ordersCount: 1,
        totalSpent: 28000,
      ),
    ];
  }

  /// Refresh orders with pagination reset
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

  /// Load more orders for infinite scroll
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
