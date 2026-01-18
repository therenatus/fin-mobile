import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_user.dart';
import '../services/employee_api_service.dart';
import '../services/base_api_service.dart';
import 'storage_provider.dart';

void _log(String message) {
  debugPrint('[EmployeeAuthNotifier] $message');
}

/// Employee auth state enum
enum EmployeeAuthState { initial, loading, authenticated, unauthenticated, error }

/// Employee auth state class with user data
class EmployeeAuthStateData {
  final EmployeeAuthState state;
  final EmployeeUser? user;
  final String? error;
  final List<EmployeeAssignment> assignments;
  final List<EmployeeWorkLog> workLogs;
  final List<EmployeePayroll> payrolls;
  final bool isLoadingMoreAssignments;
  final bool hasMoreAssignments;
  final int assignmentsPage;

  const EmployeeAuthStateData({
    this.state = EmployeeAuthState.initial,
    this.user,
    this.error,
    this.assignments = const [],
    this.workLogs = const [],
    this.payrolls = const [],
    this.isLoadingMoreAssignments = false,
    this.hasMoreAssignments = true,
    this.assignmentsPage = 1,
  });

  bool get isAuthenticated => state == EmployeeAuthState.authenticated;
  bool get isLoading => state == EmployeeAuthState.loading;

  EmployeeAuthStateData copyWith({
    EmployeeAuthState? state,
    EmployeeUser? user,
    String? error,
    List<EmployeeAssignment>? assignments,
    List<EmployeeWorkLog>? workLogs,
    List<EmployeePayroll>? payrolls,
    bool? isLoadingMoreAssignments,
    bool? hasMoreAssignments,
    int? assignmentsPage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return EmployeeAuthStateData(
      state: state ?? this.state,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      assignments: assignments ?? this.assignments,
      workLogs: workLogs ?? this.workLogs,
      payrolls: payrolls ?? this.payrolls,
      isLoadingMoreAssignments: isLoadingMoreAssignments ?? this.isLoadingMoreAssignments,
      hasMoreAssignments: hasMoreAssignments ?? this.hasMoreAssignments,
      assignmentsPage: assignmentsPage ?? this.assignmentsPage,
    );
  }
}

/// Provider for EmployeeApiService
final employeeApiServiceProvider = Provider<EmployeeApiService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return EmployeeApiService(storage);
});

/// Employee auth notifier for managing employee authentication state.
class EmployeeAuthNotifier extends Notifier<EmployeeAuthStateData> {
  @override
  EmployeeAuthStateData build() {
    BaseApiService.registerSessionExpiredCallback('employee', _handleSessionExpired);
    _init();
    return const EmployeeAuthStateData(state: EmployeeAuthState.loading);
  }

  EmployeeApiService get _api => ref.read(employeeApiServiceProvider);

  void _handleSessionExpired() {
    _log('Session expired - logging out');
    final storage = ref.read(storageServiceProvider);
    storage.clearEmployeeTokens();
    storage.clearEmployeeData();
    state = const EmployeeAuthStateData(state: EmployeeAuthState.unauthenticated);
  }

  Future<void> _init() async {
    final storage = ref.read(storageServiceProvider);

    try {
      final user = await storage.getEmployeeUser();
      if (user != null) {
        state = EmployeeAuthStateData(state: EmployeeAuthState.authenticated, user: user);
        await refreshData();
        return;
      }
      state = const EmployeeAuthStateData(state: EmployeeAuthState.unauthenticated);
    } catch (e) {
      state = EmployeeAuthStateData(
        state: EmployeeAuthState.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _log('login() called with email: $email');
    state = state.copyWith(state: EmployeeAuthState.loading, clearError: true);

    try {
      final response = await _api.login(
        email: email,
        password: password,
      );
      _log('Login successful, user: ${response.user.name}');

      state = EmployeeAuthStateData(
        state: EmployeeAuthState.authenticated,
        user: response.user,
      );

      await refreshData();
      return true;
    } on EmployeeApiException catch (e) {
      _log('EmployeeApiException: ${e.message}');
      state = EmployeeAuthStateData(
        state: EmployeeAuthState.unauthenticated,
        error: e.message,
      );
      return false;
    } catch (e) {
      _log('General error: $e');
      state = EmployeeAuthStateData(
        state: EmployeeAuthState.unauthenticated,
        error: 'Не удалось подключиться к серверу: $e',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      final storage = ref.read(storageServiceProvider);
      await storage.clearEmployeeData();
      state = const EmployeeAuthStateData(state: EmployeeAuthState.unauthenticated);
    }
  }

  Future<void> refreshData() async {
    if (state.user == null) return;

    try {
      await Future.wait([
        refreshAssignments(),
        refreshWorkLogs(),
        refreshPayrolls(),
      ]);
    } catch (e) {
      _log('Error refreshing data: $e');
    }
  }

  Future<void> refreshAssignments({bool includeCompleted = false}) async {
    try {
      final response = await _api.getAssignments(
        page: 1,
        limit: 20,
        includeCompleted: includeCompleted,
      );
      state = state.copyWith(
        assignments: response.assignments,
        hasMoreAssignments: response.meta.hasNextPage,
        assignmentsPage: 1,
      );
    } catch (e) {
      _log('Error refreshing assignments: $e');
    }
  }

  Future<void> loadMoreAssignments({bool includeCompleted = false}) async {
    if (state.isLoadingMoreAssignments || !state.hasMoreAssignments) return;

    state = state.copyWith(isLoadingMoreAssignments: true);

    try {
      final response = await _api.getAssignments(
        page: state.assignmentsPage + 1,
        limit: 20,
        includeCompleted: includeCompleted,
      );
      state = state.copyWith(
        assignments: [...state.assignments, ...response.assignments],
        hasMoreAssignments: response.meta.hasNextPage,
        assignmentsPage: state.assignmentsPage + 1,
        isLoadingMoreAssignments: false,
      );
    } catch (e) {
      _log('Error loading more assignments: $e');
      state = state.copyWith(isLoadingMoreAssignments: false);
    }
  }

  Future<void> refreshWorkLogs({DateTime? startDate, DateTime? endDate}) async {
    try {
      final workLogs = await _api.getWorkLogs(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(workLogs: workLogs);
    } catch (e) {
      _log('Error refreshing work logs: $e');
    }
  }

  Future<void> refreshPayrolls() async {
    try {
      final payrolls = await _api.getPayrolls();
      state = state.copyWith(payrolls: payrolls);
    } catch (e) {
      _log('Error refreshing payrolls: $e');
    }
  }

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

  Future<void> registerPushDevice(String playerId) async {
    try {
      await _api.registerPushDevice(playerId);
    } catch (e) {
      _log('Error registering push device: $e');
    }
  }

  Future<void> unregisterPushDevice() async {
    try {
      await _api.unregisterPushDevice();
    } catch (e) {
      _log('Error unregistering push device: $e');
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

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

/// Provider for employee auth state.
final employeeAuthNotifierProvider = NotifierProvider<EmployeeAuthNotifier, EmployeeAuthStateData>(
  EmployeeAuthNotifier.new,
);

/// Convenience provider for checking if employee is authenticated.
final isEmployeeAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(employeeAuthNotifierProvider).isAuthenticated;
});

/// Convenience provider for current employee user.
final currentEmployeeUserProvider = Provider<EmployeeUser?>((ref) {
  return ref.watch(employeeAuthNotifierProvider).user;
});

/// Convenience provider for employee assignments.
final employeeAssignmentsProvider = Provider<List<EmployeeAssignment>>((ref) {
  return ref.watch(employeeAuthNotifierProvider).assignments;
});

/// Convenience provider for employee work logs.
final employeeWorkLogsProvider = Provider<List<EmployeeWorkLog>>((ref) {
  return ref.watch(employeeAuthNotifierProvider).workLogs;
});

/// Convenience provider for employee payrolls.
final employeePayrollsProvider = Provider<List<EmployeePayroll>>((ref) {
  return ref.watch(employeeAuthNotifierProvider).payrolls;
});
