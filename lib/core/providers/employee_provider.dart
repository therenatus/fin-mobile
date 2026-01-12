import 'package:flutter/foundation.dart';
import '../models/employee_user.dart';
import '../services/base_api_service.dart';
import '../services/employee_api_service.dart';
import '../services/storage_service.dart';

void _log(String message) {
  debugPrint('[EmployeeProvider] $message');
}

class EmployeeProvider extends ChangeNotifier {
  final StorageService _storage;
  final EmployeeApiService _api;

  EmployeeUser? _user;
  List<EmployeeAssignment> _assignments = [];
  List<EmployeeWorkLog> _workLogs = [];
  List<EmployeePayroll> _payrolls = [];
  bool _isLoading = false;
  String? _error;

  // Pagination state for assignments
  int _assignmentsPage = 1;
  bool _isLoadingMoreAssignments = false;
  bool _hasMoreAssignments = true;

  EmployeeProvider(this._storage) : _api = EmployeeApiService(_storage) {
    // Set up session expiration callback
    BaseApiService.registerSessionExpiredCallback('employee', _handleSessionExpired);
  }

  void _handleSessionExpired() {
    _log('Session expired - logging out');
    _user = null;
    _assignments = [];
    _workLogs = [];
    _payrolls = [];
    _storage.clearEmployeeData();
    notifyListeners();
  }

  EmployeeUser? get user => _user;
  List<EmployeeAssignment> get assignments => _assignments;
  List<EmployeeWorkLog> get workLogs => _workLogs;
  List<EmployeePayroll> get payrolls => _payrolls;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isLoadingMoreAssignments => _isLoadingMoreAssignments;
  bool get hasMoreAssignments => _hasMoreAssignments;

  Future<void> init() async {
    final savedUser = await _storage.getEmployeeUser();
    if (savedUser != null) {
      _user = savedUser;
      notifyListeners();
      await refreshData();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _log('Attempting login...');
      final response = await _api.login(
        email: email,
        password: password,
      );
      _log('Login successful');
      _user = response.user;
      await refreshData();
      return true;
    } on EmployeeApiException catch (e) {
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
      _assignments = [];
      _workLogs = [];
      _payrolls = [];
      await _storage.clearEmployeeData();
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    if (_user == null) return;

    try {
      await Future.wait([
        refreshAssignments(),
        refreshWorkLogs(),
        refreshPayrolls(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing employee data: $e');
    }
  }

  Future<void> refreshAssignments({bool includeCompleted = false}) async {
    _assignmentsPage = 1;
    _hasMoreAssignments = true;

    try {
      final response = await _api.getAssignments(
        page: 1,
        limit: 20,
        includeCompleted: includeCompleted,
      );
      _assignments = response.assignments;
      _hasMoreAssignments = response.meta.hasNextPage;
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing assignments: $e');
    }
  }

  Future<void> loadMoreAssignments({bool includeCompleted = false}) async {
    if (_isLoadingMoreAssignments || !_hasMoreAssignments) return;

    _isLoadingMoreAssignments = true;
    notifyListeners();

    try {
      final response = await _api.getAssignments(
        page: _assignmentsPage + 1,
        limit: 20,
        includeCompleted: includeCompleted,
      );
      _assignmentsPage++;
      _assignments.addAll(response.assignments);
      _hasMoreAssignments = response.meta.hasNextPage;
    } catch (e) {
      debugPrint('Error loading more assignments: $e');
    } finally {
      _isLoadingMoreAssignments = false;
      notifyListeners();
    }
  }

  Future<void> refreshWorkLogs({DateTime? startDate, DateTime? endDate}) async {
    try {
      _workLogs = await _api.getWorkLogs(
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing work logs: $e');
    }
  }

  Future<void> refreshPayrolls() async {
    try {
      _payrolls = await _api.getPayrolls();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing payrolls: $e');
    }
  }

  Future<EmployeeWorkLog> createWorkLog(CreateWorkLogRequest request) async {
    final workLog = await _api.createWorkLog(request);
    await refreshAssignments();
    await refreshWorkLogs();
    return workLog;
  }

  /// Get work log for specific assignment and date
  /// Returns null if no record exists for that date
  Future<Map<String, dynamic>?> getWorkLogByDate(String assignmentId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    return _api.getWorkLogByDate(assignmentId, dateStr);
  }

  Future<Map<String, dynamic>> getAssignmentDetails(String id) async {
    return _api.getAssignmentById(id);
  }

  Future<void> registerPushDevice(String playerId) async {
    try {
      await _api.registerPushDevice(playerId);
    } catch (e) {
      debugPrint('Error registering push device: $e');
    }
  }

  Future<void> unregisterPushDevice() async {
    try {
      await _api.unregisterPushDevice();
    } catch (e) {
      debugPrint('Error unregistering push device: $e');
    }
  }

  /// Get role display label
  String getRoleLabel(String roleCode) {
    switch (roleCode) {
      case 'tailor':
        return 'Портной';
      case 'cutter':
        return 'Раскройщик';
      case 'seamstress':
        return 'Швея';
      case 'designer':
        return 'Дизайнер';
      case 'fitter':
        return 'Закройщик';
      default:
        return roleCode;
    }
  }
}
