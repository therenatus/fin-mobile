import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import 'api_provider.dart';

void _log(String message) {
  debugPrint('[WorkloadNotifier] $message');
}

/// Loading state for workload
enum WorkloadLoadingState {
  initial,
  loading,
  loaded,
  error,
}

/// Workload state data
class WorkloadStateData {
  final WorkloadLoadingState loadingState;
  final Map<String, dynamic>? data;
  final String? error;
  final int days;
  final String? selectedEmployeeId;

  const WorkloadStateData({
    this.loadingState = WorkloadLoadingState.initial,
    this.data,
    this.error,
    this.days = 14,
    this.selectedEmployeeId,
  });

  bool get isLoading => loadingState == WorkloadLoadingState.loading;

  List get calendar => (data?['calendar'] as List?) ?? [];
  Map<String, dynamic> get summary =>
      (data?['summary'] as Map<String, dynamic>?) ?? {};
  List get employees => (data?['employees'] as List?) ?? [];

  WorkloadStateData copyWith({
    WorkloadLoadingState? loadingState,
    Map<String, dynamic>? data,
    String? error,
    int? days,
    String? selectedEmployeeId,
    bool clearError = false,
    bool clearEmployeeId = false,
  }) {
    return WorkloadStateData(
      loadingState: loadingState ?? this.loadingState,
      data: data ?? this.data,
      error: clearError ? null : (error ?? this.error),
      days: days ?? this.days,
      selectedEmployeeId:
          clearEmployeeId ? null : (selectedEmployeeId ?? this.selectedEmployeeId),
    );
  }
}

/// Workload Notifier for managing workload calendar data
class WorkloadNotifier extends Notifier<WorkloadStateData> {
  @override
  WorkloadStateData build() {
    return const WorkloadStateData();
  }

  ApiService get _api => ref.read(apiServiceProvider);

  /// Load workload calendar data
  Future<void> loadData() async {
    state = state.copyWith(
      loadingState: WorkloadLoadingState.loading,
      clearError: true,
    );

    try {
      final data = await _api.getWorkloadCalendar(
        days: state.days,
        employeeId: state.selectedEmployeeId,
      );

      state = state.copyWith(
        data: data,
        loadingState: WorkloadLoadingState.loaded,
      );
    } catch (e) {
      _log('loadData error: $e');
      state = state.copyWith(
        error: e.toString(),
        loadingState: WorkloadLoadingState.error,
      );
    }
  }

  /// Change the number of days and reload
  Future<void> setDays(int days) async {
    state = state.copyWith(days: days);
    await loadData();
  }

  /// Filter by employee and reload
  Future<void> setEmployeeId(String? employeeId) async {
    if (employeeId == null) {
      state = state.copyWith(clearEmployeeId: true);
    } else {
      state = state.copyWith(selectedEmployeeId: employeeId);
    }
    await loadData();
  }
}

/// Provider for Workload state
final workloadNotifierProvider =
    NotifierProvider<WorkloadNotifier, WorkloadStateData>(
  WorkloadNotifier.new,
);
