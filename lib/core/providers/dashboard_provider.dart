import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

void _log(String message) {
  debugPrint('[DashboardProvider] $message');
}

class DashboardProvider with ChangeNotifier {
  final ApiService _api;

  DashboardStats? _dashboardStats;
  AnalyticsDashboard? _analyticsDashboard;
  FinanceReport? _financeReport;
  List<Client> _clients = [];
  List<EmployeeRole> _employeeRoles = [];
  bool _isLoading = false;
  String _analyticsPeriod = 'month';

  DashboardProvider(this._api);

  // Getters
  DashboardStats? get dashboardStats => _dashboardStats;
  AnalyticsDashboard? get analyticsDashboard => _analyticsDashboard;
  FinanceReport? get financeReport => _financeReport;
  List<Client> get clients => _clients;
  List<EmployeeRole> get employeeRoles => _employeeRoles;
  bool get isLoading => _isLoading;
  String get analyticsPeriod => _analyticsPeriod;

  String getRoleLabel(String code) {
    final role = _employeeRoles.firstWhere(
      (r) => r.code == code,
      orElse: () => EmployeeRole(id: '', code: code, label: code, sortOrder: 0),
    );
    return role.label;
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    // Load analytics dashboard
    try {
      _analyticsDashboard = await _api.getAnalyticsDashboard(period: _analyticsPeriod);
      _dashboardStats = _analyticsDashboard?.summary;
    } catch (e) {
      _log('Failed to load analytics: $e');
      _dashboardStats = _getMockStats();
      _analyticsDashboard = null;
    }

    // Load clients
    try {
      _clients = await _api.getClients(page: 1, limit: 10);
    } catch (e) {
      _log('Failed to load clients: $e');
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
      _log('Failed to load finance report: $e');
      _financeReport = null;
    }

    // Load employee roles
    if (_employeeRoles.isEmpty) {
      try {
        _employeeRoles = await _api.getEmployeeRoles();
      } catch (e) {
        _log('Failed to load employee roles: $e');
        _employeeRoles = [];
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }

  Future<void> setAnalyticsPeriod(String period) async {
    if (_analyticsPeriod == period) return;
    _analyticsPeriod = period;
    await loadDashboardData();
  }

  void clear() {
    _dashboardStats = null;
    _analyticsDashboard = null;
    _financeReport = null;
    _clients = [];
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
    ];
  }
}
