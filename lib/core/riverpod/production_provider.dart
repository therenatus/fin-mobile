import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

void _log(String message) {
  debugPrint('[ProductionNotifier] $message');
}

/// State enum for Production operations
enum ProductionLoadingState {
  initial,
  loading,
  loaded,
  error,
}

/// Production state data
class ProductionStateData {
  final ProductionLoadingState loadingState;
  final List<ProductionPlan> plans;
  final ProductionPlan? currentPlan;
  final List<ProductionTask> tasks;
  final List<ProductionTask> myTasks;
  final WorkloadCalendar? workloadCalendar;
  final GanttData? ganttData;
  final String? error;

  // Pagination
  final int currentPage;
  final int totalPages;
  final bool hasMorePlans;

  const ProductionStateData({
    this.loadingState = ProductionLoadingState.initial,
    this.plans = const [],
    this.currentPlan,
    this.tasks = const [],
    this.myTasks = const [],
    this.workloadCalendar,
    this.ganttData,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMorePlans = true,
  });

  bool get isLoading => loadingState == ProductionLoadingState.loading;

  ProductionStateData copyWith({
    ProductionLoadingState? loadingState,
    List<ProductionPlan>? plans,
    ProductionPlan? currentPlan,
    List<ProductionTask>? tasks,
    List<ProductionTask>? myTasks,
    WorkloadCalendar? workloadCalendar,
    GanttData? ganttData,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMorePlans,
    bool clearCurrentPlan = false,
    bool clearError = false,
    bool clearWorkloadCalendar = false,
    bool clearGanttData = false,
  }) {
    return ProductionStateData(
      loadingState: loadingState ?? this.loadingState,
      plans: plans ?? this.plans,
      currentPlan: clearCurrentPlan ? null : (currentPlan ?? this.currentPlan),
      tasks: tasks ?? this.tasks,
      myTasks: myTasks ?? this.myTasks,
      workloadCalendar: clearWorkloadCalendar
          ? null
          : (workloadCalendar ?? this.workloadCalendar),
      ganttData: clearGanttData ? null : (ganttData ?? this.ganttData),
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMorePlans: hasMorePlans ?? this.hasMorePlans,
    );
  }
}

/// Production Notifier for managing Production Planning and Workload
class ProductionNotifier extends Notifier<ProductionStateData> {
  @override
  ProductionStateData build() {
    return const ProductionStateData();
  }

  ApiService get _api => ref.read(apiServiceProvider);

  // ==================== PLANS ====================

  /// Load production plans (with pagination)
  Future<void> loadPlans({
    bool refresh = false,
    String? status,
    String? orderId,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (refresh) {
      state = state.copyWith(
        currentPage: 1,
        plans: [],
        hasMorePlans: true,
      );
    }

    if (!state.hasMorePlans && !refresh) return;

    state = state.copyWith(
      loadingState: ProductionLoadingState.loading,
      clearError: true,
    );

    try {
      final page = refresh ? 1 : state.currentPage;
      final response = await _api.getPlans(
        page: page,
        limit: 20,
        status: status,
        orderId: orderId,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final newPlans = refresh ? response.plans : [...state.plans, ...response.plans];

      state = state.copyWith(
        plans: newPlans,
        totalPages: response.meta.totalPages,
        hasMorePlans: page < response.meta.totalPages,
        currentPage: page + 1,
        loadingState: ProductionLoadingState.loaded,
      );
    } catch (e) {
      _log('loadPlans error: $e');
      state = state.copyWith(
        error: e.toString(),
        loadingState: ProductionLoadingState.error,
      );
    }
  }

  /// Load more plans (for infinite scroll)
  Future<void> loadMorePlans({
    String? status,
    String? orderId,
  }) async {
    await loadPlans(
      refresh: false,
      status: status,
      orderId: orderId,
    );
  }

  /// Refresh plans
  Future<void> refreshPlans({
    String? status,
    String? orderId,
  }) async {
    await loadPlans(
      refresh: true,
      status: status,
      orderId: orderId,
    );
  }

  /// Get plan by ID
  Future<ProductionPlan?> getPlan(String planId) async {
    try {
      final plan = await _api.getPlan(planId);
      state = state.copyWith(currentPlan: plan);
      return plan;
    } catch (e) {
      _log('getPlan error: $e');
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Schedule order automatically
  Future<ProductionPlan?> scheduleOrder(String orderId, {String? priority}) async {
    state = state.copyWith(loadingState: ProductionLoadingState.loading);

    try {
      final plan = await _api.scheduleOrder(
        orderId: orderId,
        priority: priority,
      );
      state = state.copyWith(
        currentPlan: plan,
        plans: [plan, ...state.plans],
        loadingState: ProductionLoadingState.loaded,
      );
      return plan;
    } catch (e) {
      _log('scheduleOrder error: $e');
      state = state.copyWith(
        error: e.toString(),
        loadingState: ProductionLoadingState.error,
      );
      rethrow;
    }
  }

  /// Create plan manually
  Future<ProductionPlan?> createPlan({
    required String orderId,
    required List<Map<String, dynamic>> tasks,
    String? plannedStart,
    String? plannedEnd,
  }) async {
    try {
      final plan = await _api.createPlan(
        orderId: orderId,
        tasks: tasks,
        plannedStart: plannedStart,
        plannedEnd: plannedEnd,
      );
      state = state.copyWith(
        currentPlan: plan,
        plans: [plan, ...state.plans],
      );
      return plan;
    } catch (e) {
      _log('createPlan error: $e');
      rethrow;
    }
  }

  /// Update plan
  Future<ProductionPlan?> updatePlan(
    String planId, {
    String? status,
    String? plannedStart,
    String? plannedEnd,
    List<Map<String, dynamic>>? tasks,
  }) async {
    try {
      final plan = await _api.updatePlan(
        planId,
        status: status,
        plannedStart: plannedStart,
        plannedEnd: plannedEnd,
        tasks: tasks,
      );
      _updatePlanInList(plan);
      return plan;
    } catch (e) {
      _log('updatePlan error: $e');
      rethrow;
    }
  }

  /// Delete plan
  Future<bool> deletePlan(String planId) async {
    try {
      await _api.deletePlan(planId);
      final plans = List<ProductionPlan>.from(state.plans);
      plans.removeWhere((p) => p.id == planId);
      state = state.copyWith(
        plans: plans,
        clearCurrentPlan: state.currentPlan?.id == planId,
      );
      return true;
    } catch (e) {
      _log('deletePlan error: $e');
      return false;
    }
  }

  /// Reschedule plan
  Future<ProductionPlan?> reschedulePlan(String planId) async {
    try {
      final plan = await _api.reschedulePlan(planId);
      _updatePlanInList(plan);
      return plan;
    } catch (e) {
      _log('reschedulePlan error: $e');
      rethrow;
    }
  }

  // ==================== PLAN STATUS ====================

  /// Start plan
  Future<ProductionPlan?> startPlan(String planId) async {
    try {
      final plan = await _api.startPlan(planId);
      _updatePlanInList(plan);
      return plan;
    } catch (e) {
      _log('startPlan error: $e');
      rethrow;
    }
  }

  /// Complete plan
  Future<ProductionPlan?> completePlan(String planId) async {
    try {
      final plan = await _api.completePlan(planId);
      _updatePlanInList(plan);
      return plan;
    } catch (e) {
      _log('completePlan error: $e');
      rethrow;
    }
  }

  void _updatePlanInList(ProductionPlan plan) {
    final plans = List<ProductionPlan>.from(state.plans);
    final index = plans.indexWhere((p) => p.id == plan.id);
    if (index != -1) {
      plans[index] = plan;
    }
    state = state.copyWith(
      currentPlan: plan,
      plans: plans,
    );
  }

  // ==================== TASKS ====================

  /// Load tasks
  Future<void> loadTasks({
    String? status,
    String? assigneeId,
    String? planId,
    String? date,
  }) async {
    try {
      final response = await _api.getTasks(
        status: status,
        assigneeId: assigneeId,
        planId: planId,
        date: date,
      );
      state = state.copyWith(tasks: response.tasks);
    } catch (e) {
      _log('loadTasks error: $e');
    }
  }

  /// Load my tasks
  Future<void> loadMyTasks({String? date}) async {
    try {
      final response = await _api.getMyTasks(date: date);
      state = state.copyWith(myTasks: response.tasks);
    } catch (e) {
      _log('loadMyTasks error: $e');
    }
  }

  /// Assign task
  Future<ProductionTask?> assignTask(String taskId, String assigneeId) async {
    try {
      final task = await _api.assignTask(taskId, assigneeId);
      _updateTaskInLists(task);
      return task;
    } catch (e) {
      _log('assignTask error: $e');
      rethrow;
    }
  }

  /// Start task
  Future<ProductionTask?> startTask(String taskId) async {
    try {
      final task = await _api.startTask(taskId);
      _updateTaskInLists(task);
      return task;
    } catch (e) {
      _log('startTask error: $e');
      rethrow;
    }
  }

  /// Complete task
  Future<ProductionTask?> completeTask(
    String taskId, {
    double? actualHours,
    String? notes,
  }) async {
    try {
      final task = await _api.completeTask(
        taskId,
        actualHours: actualHours,
        notes: notes,
      );
      _updateTaskInLists(task);
      return task;
    } catch (e) {
      _log('completeTask error: $e');
      rethrow;
    }
  }

  void _updateTaskInLists(ProductionTask task) {
    // Update in tasks list
    final tasks = List<ProductionTask>.from(state.tasks);
    final taskIndex = tasks.indexWhere((t) => t.id == task.id);
    if (taskIndex != -1) {
      tasks[taskIndex] = task;
    }

    // Update in myTasks list
    final myTasks = List<ProductionTask>.from(state.myTasks);
    final myTaskIndex = myTasks.indexWhere((t) => t.id == task.id);
    if (myTaskIndex != -1) {
      myTasks[myTaskIndex] = task;
    }

    state = state.copyWith(
      tasks: tasks,
      myTasks: myTasks,
    );
  }

  // ==================== WORKLOAD ====================

  /// Load workload calendar
  Future<void> loadWorkloadCalendar({
    int days = 14,
    String? employeeId,
  }) async {
    state = state.copyWith(loadingState: ProductionLoadingState.loading);

    try {
      final calendar = await _api.getProductionWorkloadCalendar(
        days: days,
        employeeId: employeeId,
      );
      state = state.copyWith(
        workloadCalendar: calendar,
        loadingState: ProductionLoadingState.loaded,
      );
    } catch (e) {
      _log('loadWorkloadCalendar error: $e');
      state = state.copyWith(
        error: e.toString(),
        loadingState: ProductionLoadingState.error,
      );
    }
  }

  /// Refresh workload calendar
  Future<void> refreshWorkload({
    int days = 14,
    String? employeeId,
  }) async {
    await loadWorkloadCalendar(days: days, employeeId: employeeId);
  }

  // ==================== GANTT ====================

  /// Load Gantt chart data
  Future<void> loadGanttData({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final gantt = await _api.getGanttData(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(ganttData: gantt);
    } catch (e) {
      _log('loadGanttData error: $e');
    }
  }

  /// Refresh Gantt data
  Future<void> refreshGantt({
    String? startDate,
    String? endDate,
  }) async {
    await loadGanttData(startDate: startDate, endDate: endDate);
  }

  // ==================== HELPERS ====================

  /// Clear current plan
  void clearCurrentPlan() {
    state = state.copyWith(clearCurrentPlan: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state
  void reset() {
    state = const ProductionStateData();
  }
}

/// Provider for Production state
final productionNotifierProvider =
    NotifierProvider<ProductionNotifier, ProductionStateData>(
  ProductionNotifier.new,
);

// ============ Convenience Providers ============

/// Provider for production plans list
final productionPlansProvider = Provider<List<ProductionPlan>>((ref) {
  return ref.watch(productionNotifierProvider).plans;
});

/// Provider for current production plan
final currentProductionPlanProvider = Provider<ProductionPlan?>((ref) {
  return ref.watch(productionNotifierProvider).currentPlan;
});

/// Provider for production tasks
final productionTasksProvider = Provider<List<ProductionTask>>((ref) {
  return ref.watch(productionNotifierProvider).tasks;
});

/// Provider for my production tasks
final myProductionTasksProvider = Provider<List<ProductionTask>>((ref) {
  return ref.watch(productionNotifierProvider).myTasks;
});

/// Provider for workload calendar
final workloadCalendarProvider = Provider<WorkloadCalendar?>((ref) {
  return ref.watch(productionNotifierProvider).workloadCalendar;
});

/// Provider for Gantt data
final ganttDataProvider = Provider<GanttData?>((ref) {
  return ref.watch(productionNotifierProvider).ganttData;
});

/// Provider for production loading state
final productionLoadingStateProvider = Provider<ProductionLoadingState>((ref) {
  return ref.watch(productionNotifierProvider).loadingState;
});

/// Provider for production error
final productionErrorProvider = Provider<String?>((ref) {
  return ref.watch(productionNotifierProvider).error;
});

/// Provider for is production loading
final isProductionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(productionNotifierProvider).isLoading;
});

/// Provider for has more plans
final hasMorePlansProvider = Provider<bool>((ref) {
  return ref.watch(productionNotifierProvider).hasMorePlans;
});
