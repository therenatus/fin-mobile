import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';
import '../api_service.dart';

/// Quality Control API mixin
mixin QcApiMixin on BaseApiService {
  // ==================== TEMPLATES ====================

  /// Get all QC templates
  Future<TemplatesResponse> getQcTemplates({
    int page = 1,
    int limit = 20,
    String? type,
    String? modelId,
    bool? isActive,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (type != null) 'type': type,
      if (modelId != null) 'modelId': modelId,
      if (isActive != null) 'isActive': isActive.toString(),
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };

    final uri = Uri.parse('${BaseApiService.baseUrl}/qc/templates')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await getHeaders());
    return handleResponse(response, TemplatesResponse.fromJson);
  }

  /// Get QC template by ID
  Future<QcTemplate> getQcTemplate(String templateId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/qc/templates/$templateId'),
      headers: await getHeaders(),
    );
    return handleResponse(response, QcTemplate.fromJson);
  }

  /// Create QC template
  Future<QcTemplate> createQcTemplate({
    required String name,
    required String type,
    String? description,
    String? modelId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/qc/templates'),
      headers: await getHeaders(),
      body: jsonEncode({
        'name': name,
        'type': type,
        'items': items,
        if (description != null) 'description': description,
        if (modelId != null) 'modelId': modelId,
      }),
    );
    return handleResponse(response, QcTemplate.fromJson);
  }

  /// Update QC template
  Future<QcTemplate> updateQcTemplate(
    String templateId, {
    String? name,
    String? description,
    String? type,
    String? modelId,
    bool? isActive,
    List<Map<String, dynamic>>? items,
  }) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/qc/templates/$templateId'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (type != null) 'type': type,
        if (modelId != null) 'modelId': modelId,
        if (isActive != null) 'isActive': isActive,
        if (items != null) 'items': items,
      }),
    );
    return handleResponse(response, QcTemplate.fromJson);
  }

  /// Delete QC template
  Future<void> deleteQcTemplate(String templateId) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/qc/templates/$templateId'),
      headers: await getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Ошибка удаления шаблона',
        statusCode: response.statusCode,
      );
    }
  }

  // ==================== CHECKS ====================

  /// Get all QC checks
  Future<ChecksResponse> getQcChecks({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
    String? orderId,
    String? inspectorId,
    String? dateFrom,
    String? dateTo,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      if (orderId != null) 'orderId': orderId,
      if (inspectorId != null) 'inspectorId': inspectorId,
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };

    final uri = Uri.parse('${BaseApiService.baseUrl}/qc/checks')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await getHeaders());
    return handleResponse(response, ChecksResponse.fromJson);
  }

  /// Get pending QC checks
  Future<ChecksResponse> getPendingQcChecks({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse('${BaseApiService.baseUrl}/qc/checks/pending')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await getHeaders());
    return handleResponse(response, ChecksResponse.fromJson);
  }

  /// Get QC check by ID
  Future<QcCheck> getQcCheck(String checkId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/qc/checks/$checkId'),
      headers: await getHeaders(),
    );
    return handleResponse(response, QcCheck.fromJson);
  }

  /// Create QC check
  Future<QcCheck> createQcCheck({
    required String templateId,
    String? orderId,
    String? taskId,
    String? inspectorId,
    String? scheduledAt,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/qc/checks'),
      headers: await getHeaders(),
      body: jsonEncode({
        'templateId': templateId,
        if (orderId != null) 'orderId': orderId,
        if (taskId != null) 'taskId': taskId,
        if (inspectorId != null) 'inspectorId': inspectorId,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
      }),
    );
    return handleResponse(response, QcCheck.fromJson);
  }

  /// Start QC check
  Future<QcCheck> startQcCheck(String checkId) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/qc/checks/$checkId/start'),
      headers: await getHeaders(),
    );
    return handleResponse(response, QcCheck.fromJson);
  }

  /// Submit QC check results
  Future<QcCheck> submitQcCheckResults(
    String checkId, {
    required String decision,
    required List<Map<String, dynamic>> results,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/qc/checks/$checkId/submit'),
      headers: await getHeaders(),
      body: jsonEncode({
        'decision': decision,
        'results': results,
        if (notes != null) 'notes': notes,
      }),
    );
    return handleResponse(response, QcCheck.fromJson);
  }

  /// Cancel QC check
  Future<QcCheck> cancelQcCheck(String checkId) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/qc/checks/$checkId/cancel'),
      headers: await getHeaders(),
    );
    return handleResponse(response, QcCheck.fromJson);
  }

  // ==================== DEFECTS ====================

  /// Get all defects
  Future<DefectsResponse> getDefects({
    int page = 1,
    int limit = 20,
    String? status,
    String? severity,
    String? type,
    String? orderId,
    String? checkId,
    String? assigneeId,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (severity != null) 'severity': severity,
      if (type != null) 'type': type,
      if (orderId != null) 'orderId': orderId,
      if (checkId != null) 'checkId': checkId,
      if (assigneeId != null) 'assigneeId': assigneeId,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };

    final uri = Uri.parse('${BaseApiService.baseUrl}/defects')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await getHeaders());
    return handleResponse(response, DefectsResponse.fromJson);
  }

  /// Get my assigned defects
  Future<DefectsResponse> getMyDefects({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
    };

    final uri = Uri.parse('${BaseApiService.baseUrl}/defects/my')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await getHeaders());
    return handleResponse(response, DefectsResponse.fromJson);
  }

  /// Get defect by ID
  Future<Defect> getDefect(String defectId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/defects/$defectId'),
      headers: await getHeaders(),
    );
    return handleResponse(response, Defect.fromJson);
  }

  /// Create defect
  Future<Defect> createDefect({
    required String title,
    required String type,
    required String severity,
    String? description,
    String? location,
    String? orderId,
    String? checkId,
    String? assigneeId,
    List<String>? photos,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/defects'),
      headers: await getHeaders(),
      body: jsonEncode({
        'title': title,
        'type': type,
        'severity': severity,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        if (orderId != null) 'orderId': orderId,
        if (checkId != null) 'checkId': checkId,
        if (assigneeId != null) 'assigneeId': assigneeId,
        if (photos != null) 'photos': photos,
      }),
    );
    return handleResponse(response, Defect.fromJson);
  }

  /// Update defect
  Future<Defect> updateDefect(
    String defectId, {
    String? title,
    String? description,
    String? type,
    String? severity,
    String? location,
    String? assigneeId,
    List<String>? photos,
    String? status,
  }) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/defects/$defectId'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (type != null) 'type': type,
        if (severity != null) 'severity': severity,
        if (location != null) 'location': location,
        if (assigneeId != null) 'assigneeId': assigneeId,
        if (photos != null) 'photos': photos,
        if (status != null) 'status': status,
      }),
    );
    return handleResponse(response, Defect.fromJson);
  }

  /// Assign defect
  Future<Defect> assignDefect(String defectId, String assigneeId) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/defects/$defectId/assign'),
      headers: await getHeaders(),
      body: jsonEncode({'assigneeId': assigneeId}),
    );
    return handleResponse(response, Defect.fromJson);
  }

  /// Resolve defect
  Future<Defect> resolveDefect(String defectId, String resolution) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/defects/$defectId/resolve'),
      headers: await getHeaders(),
      body: jsonEncode({'resolution': resolution}),
    );
    return handleResponse(response, Defect.fromJson);
  }

  /// Close defect
  Future<Defect> closeDefect(String defectId) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/defects/$defectId/close'),
      headers: await getHeaders(),
    );
    return handleResponse(response, Defect.fromJson);
  }

  /// Mark defect as won't fix
  Future<Defect> wontFixDefect(String defectId, String reason) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/defects/$defectId/wont-fix'),
      headers: await getHeaders(),
      body: jsonEncode({'reason': reason}),
    );
    return handleResponse(response, Defect.fromJson);
  }

  /// Reopen defect
  Future<Defect> reopenDefect(String defectId) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/defects/$defectId/reopen'),
      headers: await getHeaders(),
    );
    return handleResponse(response, Defect.fromJson);
  }

  /// Delete defect
  Future<void> deleteDefect(String defectId) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/defects/$defectId'),
      headers: await getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Ошибка удаления дефекта',
        statusCode: response.statusCode,
      );
    }
  }

  // ==================== STATS ====================

  /// Get QC statistics
  Future<QcStats> getQcStats({
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = {
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
    };

    final uri = Uri.parse('${BaseApiService.baseUrl}/qc/stats')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(uri, headers: await getHeaders());
    return handleResponse(response, QcStats.fromJson);
  }
}
