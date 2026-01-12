import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_user.dart';
import 'storage_service.dart';
import 'base_api_service.dart';

/// Exception class for EmployeeApiService
class EmployeeApiException extends BaseApiException {
  EmployeeApiException(
    super.message, {
    super.statusCode,
    super.isNetworkError,
  });
}

class EmployeeApiService extends BaseApiService {
  EmployeeApiService(StorageService storage) : super(storage);

  // ==================== ABSTRACT METHOD IMPLEMENTATIONS ====================

  @override
  String get logPrefix => '[EmployeeApiService]';

  @override
  String get authRefreshEndpoint => '/employee/auth/refresh';

  @override
  Future<String?> getAccessToken() => storage.getEmployeeAccessToken();

  @override
  Future<String?> getRefreshToken() => storage.getEmployeeRefreshToken();

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) =>
      storage.saveEmployeeTokens(accessToken, refreshToken);

  @override
  Future<void> clearTokens() => storage.clearEmployeeTokens();

  @override
  EmployeeApiException createException(
    String message, {
    int? statusCode,
    dynamic data,
    bool isNetworkError = false,
  }) =>
      EmployeeApiException(message, statusCode: statusCode, isNetworkError: isNetworkError);

  // ==================== AUTH ====================

  Future<EmployeeAuthResponse> login({
    required String email,
    required String password,
  }) async {
    return withNetworkErrorHandling(() async {
      final url = '${BaseApiService.baseUrl}/employee/auth/login';
      log('LOGIN: Attempting employee login to $url');

      final response = await http.post(
        Uri.parse(url),
        headers: await getHeaders(auth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      log('LOGIN: Response status: ${response.statusCode}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'] ?? body;
        final authResponse = EmployeeAuthResponse.fromJson(data as Map<String, dynamic>);
        await storage.saveEmployeeTokens(
            authResponse.accessToken, authResponse.refreshToken);
        await storage.saveEmployeeUser(authResponse.user);
        return authResponse;
      }

      // For login, 401 means invalid credentials, not expired session
      final errorMessage = body['error']?['message'] ??
          body['message'] ??
          (response.statusCode == 401
              ? 'Неверный email или пароль'
              : 'Произошла ошибка');
      throw EmployeeApiException(errorMessage, statusCode: response.statusCode);
    });
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('${BaseApiService.baseUrl}/employee/auth/logout'),
        headers: await getHeaders(),
      );
    } finally {
      await storage.clearEmployeeTokens();
    }
  }

  Future<EmployeeUser> getProfile() async {
    return withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/employee/auth/me'),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return handleResponse(response, EmployeeUser.fromJson);
    });
  }

  // ==================== PORTAL: ASSIGNMENTS ====================

  Future<EmployeeAssignmentsResponse> getAssignments({
    int page = 1,
    int limit = 20,
    bool includeCompleted = false,
  }) async {
    return withNetworkErrorHandling(() async {
      final params = <String>[
        'page=$page',
        'limit=$limit',
        'includeCompleted=$includeCompleted',
      ];

      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/employee/portal/assignments?${params.join('&')}'),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return handleResponse(response, EmployeeAssignmentsResponse.fromJson);
    });
  }

  Future<Map<String, dynamic>> getAssignmentById(String id) async {
    return withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/employee/portal/assignments/$id'),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body['data'] ?? body;
      }

      throw EmployeeApiException(
        body['message'] ?? 'Failed to get assignment',
        statusCode: response.statusCode,
      );
    });
  }

  // ==================== PORTAL: WORKLOGS ====================

  Future<EmployeeWorkLog> createWorkLog(CreateWorkLogRequest request) async {
    return withNetworkErrorHandling(() async {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrl}/employee/portal/worklogs'),
        headers: await getHeaders(),
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      return handleResponse(response, EmployeeWorkLog.fromJson);
    });
  }

  /// Get work log for specific assignment and date
  /// Returns null if no record exists for that date
  Future<Map<String, dynamic>?> getWorkLogByDate(String assignmentId, String date) async {
    return withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/employee/portal/worklogs/by-date/$assignmentId/$date'),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Server returns null if no record exists
        if (body == null) return null;
        final data = body['data'] ?? body;
        if (data == null) return null;
        return data as Map<String, dynamic>;
      }

      if (response.statusCode == 404) {
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw EmployeeApiException(
        body['message'] ?? 'Failed to fetch work log',
        statusCode: response.statusCode,
      );
    });
  }

  Future<List<EmployeeWorkLog>> getWorkLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return withNetworkErrorHandling(() async {
      var url = '${BaseApiService.baseUrl}/employee/portal/worklogs';
      final params = <String>[];
      if (startDate != null) {
        params.add('startDate=${startDate.toIso8601String()}');
      }
      if (endDate != null) {
        params.add('endDate=${endDate.toIso8601String()}');
      }
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return handleListResponse(response, EmployeeWorkLog.fromJson);
    });
  }

  // ==================== PORTAL: PAYROLLS ====================

  Future<List<EmployeePayroll>> getPayrolls() async {
    return withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/employee/portal/payrolls'),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return handleListResponse(response, EmployeePayroll.fromJson);
    });
  }

  // ==================== PUSH NOTIFICATIONS ====================

  Future<void> registerPushDevice(String playerId) async {
    await http.post(
      Uri.parse('${BaseApiService.baseUrl}/employee/portal/push/register'),
      headers: await getHeaders(),
      body: jsonEncode({'playerId': playerId}),
    );
  }

  Future<void> unregisterPushDevice() async {
    await http.post(
      Uri.parse('${BaseApiService.baseUrl}/employee/portal/push/unregister'),
      headers: await getHeaders(),
    );
  }
}
