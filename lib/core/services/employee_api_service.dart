import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/employee_user.dart';
import 'storage_service.dart';

void _log(String message) {
  debugPrint('[EmployeeApiService] $message');
}

class EmployeeApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  EmployeeApiException(this.message, {this.statusCode, this.isNetworkError = false});

  @override
  String toString() => message;
}

/// Helper to handle network errors
Future<T> _withNetworkErrorHandling<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on SocketException catch (_) {
    throw EmployeeApiException(
      'Не удалось подключиться к серверу. Проверьте интернет-соединение.',
      isNetworkError: true,
    );
  } on TimeoutException catch (_) {
    throw EmployeeApiException(
      'Сервер не отвечает. Попробуйте позже.',
      isNetworkError: true,
    );
  } on HttpException catch (_) {
    throw EmployeeApiException(
      'Ошибка соединения с сервером.',
      isNetworkError: true,
    );
  } on HandshakeException catch (_) {
    throw EmployeeApiException(
      'Ошибка безопасного соединения.',
      isNetworkError: true,
    );
  }
}

class EmployeeApiService {
  static const String _baseUrl = 'http://localhost:4000/api/v1';

  static String get baseUrl {
    if (kIsWeb) return _baseUrl;
    if (Platform.isAndroid) return 'http://10.225.124.142:4000/api/v1';
    return 'http://10.225.124.142:4000/api/v1';
  }

  /// Callback for session expiration
  static VoidCallback? onSessionExpired;

  final StorageService _storage;

  EmployeeApiService(this._storage);

  Future<Map<String, String>> _getHeaders({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await _storage.getEmployeeAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Wrapper для автоматического retry при 401 после refresh токена
  Future<T> _withRetry<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on EmployeeApiException catch (e) {
      if (e.message == 'Retry' && e.statusCode == 401) {
        // Повторяем запрос с обновлёнными токенами
        return await request();
      }
      rethrow;
    }
  }

  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body['data'] != null) {
        return fromJson(body['data'] as Map<String, dynamic>);
      }
      return fromJson(body);
    }

    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (!refreshed) {
        onSessionExpired?.call();
        throw EmployeeApiException('Сессия истекла. Войдите снова.',
            statusCode: 401);
      }
      throw EmployeeApiException('Retry', statusCode: 401);
    }

    final errorMessage =
        body['error']?['message'] ?? body['message'] ?? 'Произошла ошибка';
    throw EmployeeApiException(errorMessage, statusCode: response.statusCode);
  }

  Future<List<T>> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      List data;
      if (body is List) {
        data = body;
      } else if (body['data'] != null && body['data'] is List) {
        data = body['data'] as List;
      } else {
        data = body as List;
      }
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }

    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (!refreshed) {
        onSessionExpired?.call();
        throw EmployeeApiException('Сессия истекла. Войдите снова.',
            statusCode: 401);
      }
      throw EmployeeApiException('Retry', statusCode: 401);
    }

    final bodyMap = body as Map<String, dynamic>;
    throw EmployeeApiException(
      bodyMap['error']?['message'] ?? 'Произошла ошибка',
      statusCode: response.statusCode,
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getEmployeeRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/employee/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        await _storage.saveEmployeeTokens(
          data['accessToken'] as String,
          data['refreshToken'] as String,
        );
        return true;
      }

      await _storage.clearEmployeeTokens();
      return false;
    } catch (e) {
      await _storage.clearEmployeeTokens();
      return false;
    }
  }

  // ==================== AUTH ====================

  Future<EmployeeAuthResponse> login({
    required String email,
    required String password,
  }) async {
    return _withNetworkErrorHandling(() async {
      final url = '$baseUrl/employee/auth/login';
      _log('LOGIN: Attempting employee login to $url');

      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(auth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      _log('LOGIN: Response status: ${response.statusCode}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'] ?? body;
        final authResponse = EmployeeAuthResponse.fromJson(data as Map<String, dynamic>);
        await _storage.saveEmployeeTokens(
            authResponse.accessToken, authResponse.refreshToken);
        await _storage.saveEmployeeUser(authResponse.user);
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
        Uri.parse('$baseUrl/employee/auth/logout'),
        headers: await _getHeaders(),
      );
    } finally {
      await _storage.clearEmployeeTokens();
    }
  }

  Future<EmployeeUser> getProfile() async {
    return _withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('$baseUrl/employee/auth/me'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response, EmployeeUser.fromJson);
    });
  }

  // ==================== PORTAL: ASSIGNMENTS ====================

  Future<EmployeeAssignmentsResponse> getAssignments({
    int page = 1,
    int limit = 20,
    bool includeCompleted = false,
  }) async {
    return _withNetworkErrorHandling(() async {
      final params = <String>[
        'page=$page',
        'limit=$limit',
        'includeCompleted=$includeCompleted',
      ];

      final response = await http.get(
        Uri.parse('$baseUrl/employee/portal/assignments?${params.join('&')}'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response, EmployeeAssignmentsResponse.fromJson);
    });
  }

  Future<Map<String, dynamic>> getAssignmentById(String id) async {
    return _withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('$baseUrl/employee/portal/assignments/$id'),
        headers: await _getHeaders(),
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
    return _withNetworkErrorHandling(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/employee/portal/worklogs'),
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response, EmployeeWorkLog.fromJson);
    });
  }

  /// Get work log for specific assignment and date
  /// Returns null if no record exists for that date
  Future<Map<String, dynamic>?> getWorkLogByDate(String assignmentId, String date) async {
    return _withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('$baseUrl/employee/portal/worklogs/by-date/$assignmentId/$date'),
        headers: await _getHeaders(),
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
    return _withNetworkErrorHandling(() async {
      var url = '$baseUrl/employee/portal/worklogs';
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
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return _handleListResponse(response, EmployeeWorkLog.fromJson);
    });
  }

  // ==================== PORTAL: PAYROLLS ====================

  Future<List<EmployeePayroll>> getPayrolls() async {
    return _withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('$baseUrl/employee/portal/payrolls'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return _handleListResponse(response, EmployeePayroll.fromJson);
    });
  }

  // ==================== PUSH NOTIFICATIONS ====================

  Future<void> registerPushDevice(String playerId) async {
    await http.post(
      Uri.parse('$baseUrl/employee/portal/push/register'),
      headers: await _getHeaders(),
      body: jsonEncode({'playerId': playerId}),
    );
  }

  Future<void> unregisterPushDevice() async {
    await http.post(
      Uri.parse('$baseUrl/employee/portal/push/unregister'),
      headers: await _getHeaders(),
    );
  }
}
