import 'package:flutter/foundation.dart';
import '../models/employee_user.dart';
import '../services/base_api_service.dart';
import '../services/employee_api_service.dart';
import '../services/storage_service.dart';
import 'mixins/authentication_mixin.dart';
import 'mixins/pagination_mixin.dart';

void _log(String message) {
  debugPrint('[EmployeeProvider] $message');
}

class EmployeeProvider extends ChangeNotifier
    with AuthenticationMixin, PaginationMixin {
  final StorageService _storage;
  final EmployeeApiService _api;

  EmployeeUser? _user;
  List<EmployeeAssignment> _assignments = [];
  List<EmployeeWorkLog> _workLogs = [];
  List<EmployeePayroll> _payrolls = [];

  // Pagination state using mixin
  late final PaginationState<EmployeeAssignment> _assignmentsPagination;

  EmployeeProvider(this._storage) : _api = EmployeeApiService(_storage) {
    _assignmentsPagination = createPaginationController<EmployeeAssignment>(
      logPrefix: 'EmployeeAssignments',
    );
    BaseApiService.registerSessionExpiredCallback('employee', _handleSessionExpired);
  }

  void _handleSessionExpired() {
    _log('Session expired - logging out');
    _user = null;
    _assignments = [];
    _workLogs = [];
    _payrolls = [];
    clearAllPagination();
    _storage.clearEmployeeData();
    notifyListeners();
  }

  // ==================== Getters ====================

  EmployeeUser? get user => _user;
  List<EmployeeAssignment> get assignments => _assignments;
  List<EmployeeWorkLog> get workLogs => _workLogs;
  List<EmployeePayroll> get payrolls => _payrolls;
  bool get isAuthenticated => _user != null;

  // Pagination getters
  bool get isLoadingMoreAssignments => _assignmentsPagination.isLoadingMore;
  bool get hasMoreAssignments => _assignmentsPagination.hasMore;

  // ==================== Initialization ====================

  Future<void> init() async {
    final savedUser = await _storage.getEmployeeUser();
    if (savedUser != null) {
      _user = savedUser;
      notifyListeners();
      await refreshData();
    }
  }

  // ==================== Authentication ====================

  Future<bool> login({required String email, required String password}) async {
    return performAuthenticatedAction(
      action: () => _api.login(
        email: email,
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

  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      _user = null;
      _assignments = [];
      _workLogs = [];
      _payrolls = [];
      clearAllPagination();
      await _storage.clearEmployeeData();
      notifyListeners();
    }
  }

  // ==================== Data Refresh ====================

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
    await _assignmentsPagination.refresh(
      fetcher: (page, limit) async {
        final response = await _api.getAssignments(
          page: page,
          limit: limit,
          includeCompleted: includeCompleted,
        );
        return PaginatedResult(
          items: response.assignments,
          meta: PaginationMeta.fromHasNextPage(
            response.meta.page,
            response.meta.hasNextPage,
          ),
        );
      },
      onUpdate: () {
        _assignments = _assignmentsPagination.items;
        notifyListeners();
      },
    );
  }

  Future<void> loadMoreAssignments({bool includeCompleted = false}) async {
    await _assignmentsPagination.loadMore(
      fetcher: (page, limit) async {
        final response = await _api.getAssignments(
          page: page,
          limit: limit,
          includeCompleted: includeCompleted,
        );
        return PaginatedResult(
          items: response.assignments,
          meta: PaginationMeta.fromHasNextPage(
            response.meta.page,
            response.meta.hasNextPage,
          ),
        );
      },
      onUpdate: () {
        _assignments = _assignmentsPagination.items;
        notifyListeners();
      },
    );
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

  // ==================== WorkLog Operations ====================

  Future<EmployeeWorkLog> createWorkLog(CreateWorkLogRequest request) async {
    final workLog = await _api.createWorkLog(request);
    await refreshAssignments();
    await refreshWorkLogs();
    return workLog;
  }

  Future<Map<String, dynamic>?> getWorkLogByDate(String assignmentId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    return _api.getWorkLogByDate(assignmentId, dateStr);
  }

  Future<Map<String, dynamic>> getAssignmentDetails(String id) async {
    return _api.getAssignmentById(id);
  }

  // ==================== Push Notifications ====================

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

  // ==================== Utilities ====================

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
