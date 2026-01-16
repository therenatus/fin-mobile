import 'package:flutter/foundation.dart';
import '../models/employee_user.dart';
import '../services/employee_api_service.dart';
import '../services/storage_service.dart';
import 'base_user_provider.dart';
import 'mixins/pagination_mixin.dart';

void _log(String message) {
  debugPrint('[EmployeeProvider] $message');
}

class EmployeeProvider extends BaseUserProvider<EmployeeUser, EmployeeApiService> {
  List<EmployeeAssignment> _assignments = [];
  List<EmployeeWorkLog> _workLogs = [];
  List<EmployeePayroll> _payrolls = [];

  // Pagination state using mixin
  late final PaginationState<EmployeeAssignment> _assignmentsPagination;

  EmployeeProvider(StorageService storage)
      : super(
          storage: storage,
          api: EmployeeApiService(storage),
          modeName: 'employee',
        ) {
    _assignmentsPagination = createPaginationController<EmployeeAssignment>(
      logPrefix: 'EmployeeAssignments',
    );
  }

  // ==================== Getters ====================

  List<EmployeeAssignment> get assignments => _assignments;
  List<EmployeeWorkLog> get workLogs => _workLogs;
  List<EmployeePayroll> get payrolls => _payrolls;

  // Pagination getters
  bool get isLoadingMoreAssignments => _assignmentsPagination.isLoadingMore;
  bool get hasMoreAssignments => _assignmentsPagination.hasMore;

  // ==================== Abstract Method Implementations ====================

  @override
  Future<EmployeeUser?> loadSavedUser() => storage.getEmployeeUser();

  @override
  Future<void> clearUserData() => storage.clearEmployeeData();

  @override
  void clearDomainData() {
    _assignments = [];
    _workLogs = [];
    _payrolls = [];
  }

  @override
  Future<void> refreshData() async {
    if (user == null) return;

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

  // ==================== Authentication ====================

  Future<bool> login({required String email, required String password}) async {
    return performAuthenticatedAction(
      action: () => api.login(
        email: email,
        password: password,
      ),
      onSuccess: (response) async {
        setUser(response.user);
        await refreshData();
      },
      log: _log,
      actionName: 'login',
    );
  }

  @override
  Future<void> logout() async {
    try {
      await api.logout();
    } finally {
      await super.logout();
    }
  }

  // ==================== Data Refresh ====================

  Future<void> refreshAssignments({bool includeCompleted = false}) async {
    await _assignmentsPagination.refresh(
      fetcher: (page, limit) async {
        final response = await api.getAssignments(
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
        final response = await api.getAssignments(
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
      _workLogs = await api.getWorkLogs(
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
      _payrolls = await api.getPayrolls();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing payrolls: $e');
    }
  }

  // ==================== WorkLog Operations ====================

  Future<EmployeeWorkLog> createWorkLog(CreateWorkLogRequest request) async {
    final workLog = await api.createWorkLog(request);
    await refreshAssignments();
    await refreshWorkLogs();
    return workLog;
  }

  Future<Map<String, dynamic>?> getWorkLogByDate(String assignmentId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    return api.getWorkLogByDate(assignmentId, dateStr);
  }

  Future<Map<String, dynamic>> getAssignmentDetails(String id) async {
    return api.getAssignmentById(id);
  }

  // ==================== Push Notifications ====================

  Future<void> registerPushDevice(String playerId) async {
    try {
      await api.registerPushDevice(playerId);
    } catch (e) {
      debugPrint('Error registering push device: $e');
    }
  }

  Future<void> unregisterPushDevice() async {
    try {
      await api.unregisterPushDevice();
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
