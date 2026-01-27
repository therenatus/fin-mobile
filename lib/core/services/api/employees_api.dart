import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

mixin EmployeesApiMixin on BaseApiService {
  Future<List<EmployeeRole>> getEmployeeRoles() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/employee-roles'),
      headers: await getHeaders(),
    );

    return handleListResponse(response, EmployeeRole.fromJson, 'roles');
  }

  Future<List<Employee>> getEmployees({
    int page = 1,
    int limit = 50,
    bool? isActive,
    String? role,
    String? sortBy,
    String? sortOrder,
  }) async {
    final params = <String>['page=$page', 'limit=$limit'];
    if (isActive != null) params.add('isActive=$isActive');
    if (role != null) params.add('role=$role');
    if (sortBy != null) params.add('sortBy=$sortBy');
    if (sortOrder != null) params.add('sortOrder=$sortOrder');

    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/employees?${params.join('&')}'),
      headers: await getHeaders(),
    );

    return handleListResponse(response, Employee.fromJson, 'employees');
  }

  Future<List<Map<String, dynamic>>> getEmployeeWorkLogs(
    String employeeId, {
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String>[];
    if (dateFrom != null) params.add('dateFrom=$dateFrom');
    if (dateTo != null) params.add('dateTo=$dateTo');

    final url = params.isNotEmpty
        ? '${BaseApiService.baseUrl}/employees/$employeeId/worklogs?${params.join('&')}'
        : '${BaseApiService.baseUrl}/employees/$employeeId/worklogs';

    final response = await http.get(
      Uri.parse(url),
      headers: await getHeaders(),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] ?? body;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    }

    throw createException(
      body['message'] ?? 'Failed to get employee worklogs',
      statusCode: response.statusCode,
    );
  }

  Future<List<Map<String, dynamic>>> getAllWorklogs({
    String? employeeId,
    String? dateFrom,
    String? dateTo,
    String? step,
  }) async {
    final params = <String>[];
    if (employeeId != null) params.add('employeeId=$employeeId');
    if (dateFrom != null) params.add('dateFrom=$dateFrom');
    if (dateTo != null) params.add('dateTo=$dateTo');
    if (step != null) params.add('step=$step');

    final url = params.isNotEmpty
        ? '${BaseApiService.baseUrl}/worklogs?${params.join('&')}'
        : '${BaseApiService.baseUrl}/worklogs';

    final response = await http.get(
      Uri.parse(url),
      headers: await getHeaders(),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] ?? body;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    }

    throw createException(
      body['message'] ?? 'Failed to get worklogs',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> getWorklogsSummary({
    String? employeeId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String>[];
    if (employeeId != null) params.add('employeeId=$employeeId');
    if (dateFrom != null) params.add('dateFrom=$dateFrom');
    if (dateTo != null) params.add('dateTo=$dateTo');

    final url = params.isNotEmpty
        ? '${BaseApiService.baseUrl}/worklogs/summary?${params.join('&')}'
        : '${BaseApiService.baseUrl}/worklogs/summary';

    final response = await http.get(
      Uri.parse(url),
      headers: await getHeaders(),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] ?? body;
      return data as Map<String, dynamic>;
    }

    throw createException(
      body['message'] ?? 'Failed to get worklogs summary',
      statusCode: response.statusCode,
    );
  }

  Future<Employee> getEmployee(String id) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/employees/$id'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Employee.fromJson);
  }

  Future<Employee> createEmployee({
    required String name,
    required String role,
    String? phone,
    String? email,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/employees'),
      headers: await getHeaders(),
      body: jsonEncode({
        'name': name,
        'role': role,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      }),
    );

    return handleResponse(response, Employee.fromJson);
  }

  Future<Employee> updateEmployee({
    required String id,
    String? name,
    String? role,
    String? phone,
    String? email,
  }) async {
    final response = await http.put(
      Uri.parse('${BaseApiService.baseUrl}/employees/$id'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (role != null) 'role': role,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      }),
    );

    return handleResponse(response, Employee.fromJson);
  }

  Future<Employee> setEmployeeActiveStatus(String id, bool isActive) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/employees/$id/set-active'),
      headers: await getHeaders(),
      body: jsonEncode({'isActive': isActive}),
    );

    return handleResponse(response, Employee.fromJson);
  }
}
