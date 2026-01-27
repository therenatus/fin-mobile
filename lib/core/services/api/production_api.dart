import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';
import '../api_service.dart';

/// Production planning and workload management API mixin
mixin ProductionApiMixin on BaseApiService {
  // ==================== PLANS ====================

  /// Get all production plans
  Future<PlansResponse> getPlans({
    int page = 1,
    int limit = 20,
    String? status,
    String? orderId,
    String? startFrom,
    String? startTo,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (orderId != null) 'orderId': orderId,
      if (startFrom != null) 'startFrom': startFrom,
      if (startTo != null) 'startTo': startTo,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };

    final uri = Uri.parse('${BaseApiService.baseUrl}/production/plans')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await getHeaders());
    return handleResponse(response, PlansResponse.fromJson);
  }

  /// Get production plan by ID
  Future<ProductionPlan> getPlan(String planId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/production/plans/$planId'),
      headers: await getHeaders(),
    );
    return handleResponse(response, ProductionPlan.fromJson);
  }

  /// Create production plan manually
  Future<ProductionPlan> createPlan({
    required String orderId,
    required List<Map<String, dynamic>> tasks,
    String? plannedStart,
    String? plannedEnd,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/production/plans'),
      headers: await getHeaders(),
      body: jsonEncode({
        'orderId': orderId,
        'tasks': tasks,
        if (plannedStart != null) 'plannedStart': plannedStart,
        if (plannedEnd != null) 'plannedEnd': plannedEnd,
      }),
    );
    return handleResponse(response, ProductionPlan.fromJson);
  }

  /// Schedule order automatically using backward scheduling
  Future<ProductionPlan> scheduleOrder({
    required String orderId,
    String? priority,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/production/plans/schedule'),
      headers: await getHeaders(),
      body: jsonEncode({
        'orderId': orderId,
        if (priority != null) 'priority': priority,
      }),
    );
    return handleResponse(response, ProductionPlan.fromJson);
  }

  /// Update production plan
  Future<ProductionPlan> updatePlan(
    String planId, {
    String? status,
    String? plannedStart,
    String? plannedEnd,
    List<Map<String, dynamic>>? tasks,
  }) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/production/plans/$planId'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (status != null) 'status': status,
        if (plannedStart != null) 'plannedStart': plannedStart,
        if (plannedEnd != null) 'plannedEnd': plannedEnd,
        if (tasks != null) 'tasks': tasks,
      }),
    );
    return handleResponse(response, ProductionPlan.fromJson);
  }

  /// Delete production plan
  Future<void> deletePlan(String planId) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/production/plans/$planId'),
      headers: await getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Ошибка удаления плана',
        statusCode: response.statusCode,
      );
    }
  }

  /// Reschedule production plan
  Future<ProductionPlan> reschedulePlan(String planId) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/production/plans/$planId/reschedule'),
      headers: await getHeaders(),
    );
    return handleResponse(response, ProductionPlan.fromJson);
  }

  // ==================== PLAN STATUS ====================

  /// Update plan status
  Future<ProductionPlan> updatePlanStatus(String planId, String status) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/production/plans/$planId/status'),
      headers: await getHeaders(),
      body: jsonEncode({'status': status}),
    );
    return handleResponse(response, ProductionPlan.fromJson);
  }

  /// Start production plan
  Future<ProductionPlan> startPlan(String planId) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/production/plans/$planId/start'),
      headers: await getHeaders(),
    );
    return handleResponse(response, ProductionPlan.fromJson);
  }

  /// Complete production plan
  Future<ProductionPlan> completePlan(String planId) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/production/plans/$planId/complete'),
      headers: await getHeaders(),
    );
    return handleResponse(response, ProductionPlan.fromJson);
  }

  // ==================== TASKS ====================

  /// Get all tasks
  Future<TasksResponse> getTasks({
    int page = 1,
    int limit = 20,
    String? status,
    String? assigneeId,
    String? planId,
    String? date,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (assigneeId != null) 'assigneeId': assigneeId,
      if (planId != null) 'planId': planId,
      if (date != null) 'date': date,
    };

    final uri = Uri.parse('${BaseApiService.baseUrl}/production/tasks')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await getHeaders());
    return handleResponse(response, TasksResponse.fromJson);
  }

  /// Get my tasks (for employees)
  Future<TasksResponse> getMyTasks({String? date}) async {
    final queryParams = {
      if (date != null) 'date': date,
    };

    final uri = Uri.parse('${BaseApiService.baseUrl}/production/tasks/my')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(uri, headers: await getHeaders());
    return handleResponse(response, TasksResponse.fromJson);
  }

  /// Assign task to employee
  Future<ProductionTask> assignTask(String taskId, String assigneeId) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/production/tasks/$taskId/assign'),
      headers: await getHeaders(),
      body: jsonEncode({'assigneeId': assigneeId}),
    );
    return handleResponse(response, ProductionTask.fromJson);
  }

  /// Start task
  Future<ProductionTask> startTask(String taskId) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/production/tasks/$taskId/start'),
      headers: await getHeaders(),
    );
    return handleResponse(response, ProductionTask.fromJson);
  }

  /// Complete task
  Future<ProductionTask> completeTask(
    String taskId, {
    double? actualHours,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/production/tasks/$taskId/complete'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (actualHours != null) 'actualHours': actualHours,
        if (notes != null) 'notes': notes,
      }),
    );
    return handleResponse(response, ProductionTask.fromJson);
  }

  // ==================== GANTT ====================

  /// Get Gantt chart data
  Future<GanttData> getGanttData({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };

    final uri = Uri.parse('${BaseApiService.baseUrl}/production/workload/gantt')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(uri, headers: await getHeaders());
    return handleResponse(response, GanttData.fromJson);
  }
}
