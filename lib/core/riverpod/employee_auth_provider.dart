import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_user.dart';
import '../services/employee_api_service.dart';
import 'base_auth_state.dart';
import 'base_auth_notifier.dart';
import 'storage_provider.dart';

void _log(String message) {
  debugPrint('[EmployeeAuthNotifier] $message');
}

/// Employee auth state enum - maps to shared AuthLoadingState for compatibility
@Deprecated('Use AuthLoadingState instead')
typedef EmployeeAuthState = AuthLoadingState;

/// Employee auth state class with user data
class EmployeeAuthStateData implements BaseAuthStateData<EmployeeUser> {
  @override
  final AuthLoadingState loadingState;
  @override
  final EmployeeUser? user;
  @override
  final String? error;

  // Employee-specific fields
  final List<EmployeeAssignment> assignments;
  final List<EmployeeWorkLog> workLogs;
  final List<EmployeePayroll> payrolls;
  final bool isLoadingMoreAssignments;
  final bool hasMoreAssignments;
  final int assignmentsPage;

  const EmployeeAuthStateData({
    this.loadingState = AuthLoadingState.initial,
    this.user,
    this.error,
    this.assignments = const [],
    this.workLogs = const [],
    this.payrolls = const [],
    this.isLoadingMoreAssignments = false,
    this.hasMoreAssignments = true,
    this.assignmentsPage = 1,
  });

  /// Legacy getter for backwards compatibility
  AuthLoadingState get state => loadingState;

  @override
  bool get isAuthenticated => loadingState == AuthLoadingState.authenticated;

  @override
  bool get isLoading => loadingState == AuthLoadingState.loading;

  EmployeeAuthStateData copyWith({
    AuthLoadingState? loadingState,
    AuthLoadingState? state, // Legacy parameter name
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
      loadingState: loadingState ?? state ?? this.loadingState,
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
class EmployeeAuthNotifier extends BaseAuthNotifier<EmployeeAuthStateData, EmployeeUser> {
  @override
  String get authType => 'employee';

  @override
  EmployeeAuthStateData get initialState =>
      const EmployeeAuthStateData(loadingState: AuthLoadingState.loading);

  @override
  EmployeeAuthStateData createAuthenticatedState(EmployeeUser user) =>
      EmployeeAuthStateData(loadingState: AuthLoadingState.authenticated, user: user);

  @override
  EmployeeAuthStateData createUnauthenticatedState({String? error}) =>
      EmployeeAuthStateData(loadingState: AuthLoadingState.unauthenticated, error: error);

  @override
  EmployeeAuthStateData createLoadingState() =>
      state.copyWith(loadingState: AuthLoadingState.loading, clearError: true);

  EmployeeApiService get _api => ref.read(employeeApiServiceProvider);

  @override
  Future<EmployeeUser?> loadUserFromStorage() async {
    final storage = ref.read(storageServiceProvider);
    return storage.getEmployeeUser();
  }

  @override
  Future<void> clearStorage() async {
    final storage = ref.read(storageServiceProvider);
    await storage.clearEmployeeData();
  }

  @override
  Future<void> onInitWithUser(EmployeeUser user) async {
    await refreshData();
  }

  Future<bool> login({required String email, required String password}) async {
    _log('login() called with email: $email');

    final success = await performLogin<EmployeeApiException>(
      apiCall: () async {
        final response = await _api.login(
          email: email,
          password: password,
        );
        _log('Login successful, user: ${response.user.name}');
        return response.user;
      },
      getApiExceptionMessage: (e) {
        _log('EmployeeApiException: ${e.message}');
        return e.message;
      },
    );

    if (success) {
      await refreshData();
    }
    return success;
  }

  Future<void> logout() async {
    await performLogout(apiLogout: () => _api.logout());
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

  @override
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
