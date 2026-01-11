import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'storage_service.dart';

void _log(String message) {
  debugPrint('[ApiService] $message');
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final bool isNetworkError;

  ApiException(this.message, {this.statusCode, this.data, this.isNetworkError = false});

  @override
  String toString() => message;
}

/// Helper to handle network errors
Future<T> _withNetworkErrorHandling<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on SocketException catch (_) {
    throw ApiException(
      'Не удалось подключиться к серверу. Проверьте интернет-соединение.',
      isNetworkError: true,
    );
  } on TimeoutException catch (_) {
    throw ApiException(
      'Сервер не отвечает. Попробуйте позже.',
      isNetworkError: true,
    );
  } on HttpException catch (_) {
    throw ApiException(
      'Ошибка соединения с сервером.',
      isNetworkError: true,
    );
  } on HandshakeException catch (_) {
    throw ApiException(
      'Ошибка безопасного соединения.',
      isNetworkError: true,
    );
  }
}

class ApiService {
  // Статический IP сервера
  static const String _serverIp = '10.225.124.142';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:4000/api/v1';
    // Для эмулятора Android используем 10.0.2.2, для реального устройства - реальный IP
    if (Platform.isAndroid) return 'http://$_serverIp:4000/api/v1';
    // Для iOS
    return 'http://$_serverIp:4000/api/v1';
  }

  /// Callback для обработки истечения сессии
  static VoidCallback? onSessionExpired;

  final StorageService _storage;

  ApiService(this._storage);

  Future<Map<String, String>> _getHeaders({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await _storage.getAccessToken();
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
    } on ApiException catch (e) {
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
      if (body['success'] == true && body['data'] != null) {
        return fromJson(body['data'] as Map<String, dynamic>);
      }
      return fromJson(body);
    }

    if (response.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _refreshToken();
      if (!refreshed) {
        throw ApiException('Сессия истекла. Войдите снова.', statusCode: 401);
      }
      throw ApiException('Retry', statusCode: 401);
    }

    final errorMessage = body['error']?['message'] ??
                         body['message'] ??
                         'Произошла ошибка';
    throw ApiException(errorMessage, statusCode: response.statusCode, data: body);
  }

  Future<List<T>> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
    String key,
  ) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] ?? body;
      // If data is already a list, use it directly; otherwise try to get by key
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data[key] != null) {
        list = data[key] as List<dynamic>;
      } else {
        list = [];
      }
      return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }

    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (!refreshed) {
        // Вызываем callback для выхода из приложения
        onSessionExpired?.call();
        throw ApiException('Сессия истекла', statusCode: 401);
      }
      throw ApiException('Retry', statusCode: 401);
    }

    throw ApiException(
      body['error']?['message'] ?? 'Произошла ошибка',
      statusCode: response.statusCode,
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        await _storage.saveTokens(
          data['accessToken'] as String,
          data['refreshToken'] as String,
        );
        return true;
      }

      await _storage.clearTokens();
      return false;
    } catch (e) {
      await _storage.clearTokens();
      return false;
    }
  }

  // ==================== AUTH ====================

  Future<AuthResponse> login(String email, String password) async {
    return _withNetworkErrorHandling(() async {
      final url = '$baseUrl/auth/login';
      _log('LOGIN: Attempting login to $url');
      _log('LOGIN: Email: $email');

      final headers = await _getHeaders(auth: false);
      _log('LOGIN: Headers: $headers');

      final requestBody = jsonEncode({'email': email, 'password': password});
      _log('LOGIN: Request body: $requestBody');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      _log('LOGIN: Response status: ${response.statusCode}');
      _log('LOGIN: Response body: ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'] ?? body;
        final authResponse = AuthResponse.fromJson(data as Map<String, dynamic>);
        await _storage.saveTokens(authResponse.accessToken, authResponse.refreshToken);
        await _storage.saveUser(authResponse.user);
        _log('LOGIN: Success! User: ${authResponse.user.email}');
        return authResponse;
      }

      // For login, 401 means invalid credentials, not expired session
      final errorMessage = body['error']?['message'] ??
          body['message'] ??
          (response.statusCode == 401
              ? 'Неверный email или пароль'
              : 'Произошла ошибка');
      throw ApiException(errorMessage, statusCode: response.statusCode);
    });
  }

  Future<AuthResponse> register(String email, String password, String tenantName) async {
    return _withNetworkErrorHandling(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: await _getHeaders(auth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
          'tenantName': tenantName,
        }),
      ).timeout(const Duration(seconds: 15));

      final authResponse = await _handleResponse(response, AuthResponse.fromJson);
      await _storage.saveTokens(authResponse.accessToken, authResponse.refreshToken);
      await _storage.saveUser(authResponse.user);

      return authResponse;
    });
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(),
      );
    } finally {
      await _storage.clearAll();
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    _log('getProfile: calling $baseUrl/auth/me');
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _getHeaders(),
    );

    _log('getProfile: status=${response.statusCode}, body=${response.body}');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['data'] ?? body;
    }
    throw ApiException(
      body['message'] ?? 'Failed to get profile',
      statusCode: response.statusCode,
    );
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Failed to change password',
        statusCode: response.statusCode,
      );
    }
  }

  Future<User> uploadAvatar(File file) async {
    final token = await _storage.getAccessToken();
    _log('uploadAvatar: file=${file.path}');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/profile/avatar'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    // Determine content type from file extension
    final extension = file.path.split('.').last.toLowerCase();
    final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      file.path,
      contentType: MediaType.parse(mimeType),
    );
    request.files.add(multipartFile);

    _log('uploadAvatar: sending to $baseUrl/auth/profile/avatar');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    _log('uploadAvatar: status=${response.statusCode}, body=${response.body}');

    final user = await _handleResponse(response, User.fromJson);
    await _storage.saveUser(user);
    return user;
  }

  Future<User> deleteAvatar() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/auth/profile/avatar'),
      headers: await _getHeaders(),
    );

    final user = await _handleResponse(response, User.fromJson);
    await _storage.saveUser(user);
    return user;
  }

  // ==================== ORDERS ====================

  Future<OrdersResponse> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

    final uri = Uri.parse('$baseUrl/orders').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    return _handleResponse(response, OrdersResponse.fromJson);
  }

  Future<Order> getOrder(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$id'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, Order.fromJson);
  }

  Future<Order> createOrder({
    required String clientId,
    required String modelId,
    required int quantity,
    String? dueDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'clientId': clientId,
        'modelId': modelId,
        'quantity': quantity,
        if (dueDate != null) 'dueDate': dueDate,
      }),
    );

    return _handleResponse(response, Order.fromJson);
  }

  Future<Order> updateOrderStatus(String id, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$id/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );

    return _handleResponse(response, Order.fromJson);
  }

  // ==================== CLIENTS ====================

  /// Search for existing ClientUser by email
  /// Returns user info if found, null if not found
  Future<Map<String, dynamic>?> searchClientUserByEmail(String email) async {
    if (email.isEmpty) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/clients/search-user?email=${Uri.encodeComponent(email)}'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'] ?? body;
      if (data == null) return null;
      return data as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Client>> getClients({int page = 1, int limit = 20}) async {
    return _getListWithRetry(
      () async => http.get(
        Uri.parse('$baseUrl/clients?page=$page&limit=$limit'),
        headers: await _getHeaders(),
      ),
      Client.fromJson,
      'clients',
    );
  }

  Future<List<T>> _getListWithRetry<T>(
    Future<http.Response> Function() request,
    T Function(Map<String, dynamic>) fromJson,
    String key,
  ) async {
    try {
      final response = await request();
      return await _handleListResponse(response, fromJson, key);
    } on ApiException catch (e) {
      if (e.message == 'Retry') {
        // Token was refreshed, retry the request
        final response = await request();
        return await _handleListResponse(response, fromJson, key);
      }
      rethrow;
    }
  }

  Future<Client> getClient(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/clients/$id'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, Client.fromJson);
  }

  Future<Client> createClient({
    required String name,
    String? email,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        'contacts': {'email': email, 'phone': phone},
      }),
    );

    return _handleResponse(response, Client.fromJson);
  }

  Future<Client> updateClient({
    required String id,
    String? name,
    String? phone,
    String? email,
    String? telegram,
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/clients/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        'contacts': {
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (telegram != null) 'telegram': telegram,
        },
        if (notes != null) 'notes': notes,
      }),
    );

    return _handleResponse(response, Client.fromJson);
  }

  Future<void> deleteClient(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/clients/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Failed to delete client',
        statusCode: response.statusCode,
      );
    }
  }

  // ==================== CLIENT MODEL ASSIGNMENTS ====================

  /// Get models assigned to a specific client
  Future<List<OrderModel>> getClientAssignedModels(String clientId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/clients/$clientId/models'),
      headers: await _getHeaders(),
    );

    return _handleListResponse(response, OrderModel.fromJson, 'models');
  }

  /// Add models to client (merges with existing assignments)
  Future<Client> assignModelsToClient(String clientId, List<String> modelIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients/$clientId/models'),
      headers: await _getHeaders(),
      body: jsonEncode({'modelIds': modelIds}),
    );

    return _handleResponse(response, Client.fromJson);
  }

  /// Set assigned models for client (replaces all existing assignments)
  Future<Client> setClientAssignedModels(String clientId, List<String> modelIds) async {
    final response = await http.put(
      Uri.parse('$baseUrl/clients/$clientId/models'),
      headers: await _getHeaders(),
      body: jsonEncode({'modelIds': modelIds}),
    );

    return _handleResponse(response, Client.fromJson);
  }

  /// Remove a single model from client's assignments
  Future<Client> unassignModelFromClient(String clientId, String modelId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/clients/$clientId/models/$modelId'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, Client.fromJson);
  }

  // ==================== MODELS ====================

  Future<List<OrderModel>> getModels({int page = 1, int limit = 50}) async {
    return _getListWithRetry(
      () async => http.get(
        Uri.parse('$baseUrl/models?page=$page&limit=$limit'),
        headers: await _getHeaders(),
      ),
      OrderModel.fromJson,
      'models',
    );
  }

  Future<OrderModel> getModel(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/models/$id'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, OrderModel.fromJson);
  }

  Future<OrderModel> createModel({
    required String name,
    String? category,
    required double basePrice,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/models'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        if (category != null) 'category': category,
        'basePrice': basePrice,
        if (description != null) 'description': description,
      }),
    );

    return _handleResponse(response, OrderModel.fromJson);
  }

  Future<OrderModel> updateModel({
    required String id,
    String? name,
    String? category,
    double? basePrice,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/models/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (category != null) 'category': category,
        if (basePrice != null) 'basePrice': basePrice,
        if (description != null) 'description': description,
      }),
    );

    return _handleResponse(response, OrderModel.fromJson);
  }

  Future<void> deleteModel(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/models/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Failed to delete model',
        statusCode: response.statusCode,
      );
    }
  }

  Future<OrderModel> uploadModelImage(String modelId, File file) async {
    final token = await _storage.getAccessToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/models/$modelId/image'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response, OrderModel.fromJson);
  }

  Future<OrderModel> deleteModelImage(String modelId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/models/$modelId/image'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, OrderModel.fromJson);
  }

  // ==================== WORK LOGS (PAYROLL) ====================

  Future<List<WorkLog>> getWorkLogs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payroll/worklogs'),
      headers: await _getHeaders(),
    );

    return _handleListResponse(response, WorkLog.fromJson, 'worklogs');
  }

  Future<WorkLog> createWorkLog({
    required String employeeId,
    required String orderId,
    required String step,
    required int quantity,
    required double hours,
    required DateTime date,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payroll/worklogs'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'employeeId': employeeId,
        'orderId': orderId,
        'step': step,
        'quantity': quantity,
        'hours': hours,
        'date': date.toIso8601String(),
      }),
    );

    return _handleResponse(response, WorkLog.fromJson);
  }

  // ==================== PAYROLL ====================

  Future<List<Payroll>> getPayrolls() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payroll'),
      headers: await _getHeaders(),
    );

    return _handleListResponse(response, Payroll.fromJson, 'payrolls');
  }

  Future<Payroll> generatePayroll({
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payroll/generate'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
      }),
    );

    return _handleResponse(response, Payroll.fromJson);
  }

  // ==================== PROCESS STEPS ====================

  Future<List<ProcessStep>> getProcessSteps(String modelId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/models/$modelId/steps'),
      headers: await _getHeaders(),
    );

    return _handleListResponse(response, ProcessStep.fromJson, 'steps');
  }

  Future<ProcessStep> createProcessStep({
    required String modelId,
    required int stepOrder,
    required String name,
    required int estimatedTime,
    required String executorRole,
    double? rate,
    String? rateType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/models/$modelId/steps'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'stepOrder': stepOrder,
        'name': name,
        'estimatedTime': estimatedTime,
        'executorRole': executorRole,
        if (rate != null) 'rate': rate,
        if (rateType != null) 'rateType': rateType,
      }),
    );

    return _handleResponse(response, ProcessStep.fromJson);
  }

  Future<ProcessStep> updateProcessStep({
    required String stepId,
    int? stepOrder,
    String? name,
    int? estimatedTime,
    String? executorRole,
    double? rate,
    String? rateType,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/models/steps/$stepId'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (stepOrder != null) 'stepOrder': stepOrder,
        if (name != null) 'name': name,
        if (estimatedTime != null) 'estimatedTime': estimatedTime,
        if (executorRole != null) 'executorRole': executorRole,
        if (rate != null) 'rate': rate,
        if (rateType != null) 'rateType': rateType,
      }),
    );

    return _handleResponse(response, ProcessStep.fromJson);
  }

  Future<void> deleteProcessStep(String stepId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/models/steps/$stepId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Failed to delete process step',
        statusCode: response.statusCode,
      );
    }
  }

  // ==================== ANALYTICS ====================

  Future<AnalyticsDashboard> getAnalyticsDashboard({String period = 'month'}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/dashboard?period=$period'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, AnalyticsDashboard.fromJson);
  }

  Future<DashboardStats> getDashboardStats({String period = 'month'}) async {
    final dashboard = await getAnalyticsDashboard(period: period);
    return dashboard.summary;
  }

  /// Get workload calendar showing production load by day
  Future<Map<String, dynamic>> getWorkloadCalendar({
    int days = 14,
    String? employeeId,
  }) async {
    final queryParams = <String, String>{
      'days': days.toString(),
    };
    if (employeeId != null) queryParams['employeeId'] = employeeId;

    final uri = Uri.parse('$baseUrl/analytics/workload/calendar')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      // Extract data field from response wrapper
      final data = body['data'] ?? body;
      return data as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _refreshToken();
      if (!refreshed) {
        onSessionExpired?.call();
        throw ApiException('Сессия истекла', statusCode: 401);
      }
      // Retry request after token refresh
      final retryResponse = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      if (retryResponse.statusCode == 200) {
        final body = json.decode(retryResponse.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        return data as Map<String, dynamic>;
      }
      throw ApiException('Failed to get workload calendar', statusCode: retryResponse.statusCode);
    } else {
      throw ApiException(
        'Failed to get workload calendar',
        statusCode: response.statusCode,
      );
    }
  }

  // ==================== FINANCE ====================

  Future<List<Transaction>> getTransactions({
    String? type,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (type != null) queryParams['type'] = type;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse('$baseUrl/finance/transactions')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    return _handleListResponse(response, Transaction.fromJson, 'transactions');
  }

  Future<Transaction> createTransaction({
    required DateTime date,
    required String type,
    required String category,
    required double amount,
    String? description,
    String? orderId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/finance/transactions'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'date': date.toIso8601String(),
        'type': type,
        'category': category,
        'amount': amount,
        if (description != null) 'description': description,
        if (orderId != null) 'orderId': orderId,
      }),
    );

    return _handleResponse(response, Transaction.fromJson);
  }

  Future<void> deleteTransaction(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/finance/transactions/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Failed to delete transaction',
        statusCode: response.statusCode,
      );
    }
  }

  Future<FinanceReport> getFinanceReport({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse('$baseUrl/finance/report')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    return _handleResponse(response, FinanceReport.fromJson);
  }

  // ==================== EMPLOYEE ROLES ====================

  Future<List<EmployeeRole>> getEmployeeRoles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/employee-roles'),
      headers: await _getHeaders(),
    );

    return _handleListResponse(response, EmployeeRole.fromJson, 'roles');
  }

  // ==================== EMPLOYEES ====================

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
      Uri.parse('$baseUrl/employees?${params.join('&')}'),
      headers: await _getHeaders(),
    );

    return _handleListResponse(response, Employee.fromJson, 'employees');
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
        ? '$baseUrl/employees/$employeeId/worklogs?${params.join('&')}'
        : '$baseUrl/employees/$employeeId/worklogs';

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] ?? body;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    }

    throw ApiException(
      body['message'] ?? 'Failed to get employee worklogs',
      statusCode: response.statusCode,
    );
  }

  /// Get all worklogs (for manager)
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
        ? '$baseUrl/worklogs?${params.join('&')}'
        : '$baseUrl/worklogs';

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] ?? body;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    }

    throw ApiException(
      body['message'] ?? 'Failed to get worklogs',
      statusCode: response.statusCode,
    );
  }

  /// Get worklogs summary (for manager)
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
        ? '$baseUrl/worklogs/summary?${params.join('&')}'
        : '$baseUrl/worklogs/summary';

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] ?? body;
      return data as Map<String, dynamic>;
    }

    throw ApiException(
      body['message'] ?? 'Failed to get worklogs summary',
      statusCode: response.statusCode,
    );
  }

  Future<Employee> getEmployee(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/employees/$id'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, Employee.fromJson);
  }

  Future<Employee> createEmployee({
    required String name,
    required String role,
    String? phone,
    String? email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employees'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        'role': role,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      }),
    );

    return _handleResponse(response, Employee.fromJson);
  }

  Future<Employee> updateEmployee({
    required String id,
    String? name,
    String? role,
    String? phone,
    String? email,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/employees/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (role != null) 'role': role,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      }),
    );

    return _handleResponse(response, Employee.fromJson);
  }

  Future<void> deleteEmployee(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/employees/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Failed to delete employee',
        statusCode: response.statusCode,
      );
    }
  }

  // ==================== ORDER ASSIGNMENTS ====================

  Future<List<OrderAssignment>> getOrderAssignments(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId/assignments'),
      headers: await _getHeaders(),
    );

    return _handleListResponse(response, OrderAssignment.fromJson, 'assignments');
  }

  Future<OrderAssignment> createOrderAssignment({
    required String orderId,
    required String stepName,
    required String employeeId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/assignments'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'stepName': stepName,
        'employeeId': employeeId,
      }),
    );

    return _handleResponse(response, OrderAssignment.fromJson);
  }

  Future<void> deleteOrderAssignment(String orderId, String assignmentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/orders/$orderId/assignments/$assignmentId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Failed to delete assignment',
        statusCode: response.statusCode,
      );
    }
  }

  // ==================== PUSH NOTIFICATIONS ====================

  /// Register device for push notifications
  Future<void> registerPushDevice(String playerId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/devices/register'),
        headers: await _getHeaders(),
        body: jsonEncode({'playerId': playerId}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _log('Push device registered successfully');
      } else {
        _log('Failed to register push device: ${response.statusCode}');
      }
    } catch (e) {
      _log('Error registering push device: $e');
    }
  }

  /// Unregister device from push notifications
  Future<void> unregisterPushDevice() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/devices/unregister'),
        headers: await _getHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _log('Push device unregistered successfully');
      } else {
        _log('Failed to unregister push device: ${response.statusCode}');
      }
    } catch (e) {
      _log('Error unregistering push device: $e');
    }
  }

  // ==================== ML FORECASTS ====================

  /// Get orders forecast for specified days
  Future<Forecast> getOrdersForecast({int days = 7}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ml/forecast/orders?days=$days'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, Forecast.fromJson);
  }

  /// Get revenue forecast for specified days
  Future<Forecast> getRevenueForecast({int days = 7}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ml/forecast/revenue?days=$days'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, Forecast.fromJson);
  }

  /// Get AI-generated business insights
  Future<BusinessInsights> getBusinessInsights() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ml/insights'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, BusinessInsights.fromJson);
  }

  /// Generate AI report
  Future<MlReport> generateMlReport({
    required String type,
    String? periodStart,
    String? periodEnd,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ml/report'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'type': type,
        if (periodStart != null) 'periodStart': periodStart,
        if (periodEnd != null) 'periodEnd': periodEnd,
      }),
    );

    return _handleResponse(response, MlReport.fromJson);
  }

  /// Get report history
  Future<List<MlReport>> getReportHistory({String? type, int limit = 10}) async {
    final queryParams = <String, String>{'limit': limit.toString()};
    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('$baseUrl/ml/reports/history')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    return _handleListResponse(response, MlReport.fromJson, 'reports');
  }

  /// Get ML usage info and limits
  Future<MlUsageInfo> getMlUsageInfo() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ml/usage'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, MlUsageInfo.fromJson);
  }

  // ==================== BILLING / SUBSCRIPTIONS ====================

  /// Get all available subscription plans
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/billing/plans'),
      headers: await _getHeaders(auth: false),
    );

    return _handleListResponse(response, SubscriptionPlan.fromJson, 'plans');
  }

  /// Get current resource usage and limits
  Future<ResourceUsage> getResourceUsage() async {
    final response = await http.get(
      Uri.parse('$baseUrl/billing/usage'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, ResourceUsage.fromJson);
  }

  /// Get current subscription
  Future<Subscription?> getCurrentSubscription() async {
    final response = await http.get(
      Uri.parse('$baseUrl/billing/subscription'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 404) {
      return null;
    }

    return _handleResponse(response, Subscription.fromJson);
  }

  /// Verify Google Play purchase
  Future<Subscription> verifyGooglePlayPurchase({
    required String productId,
    required String purchaseToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/billing/verify/google-play'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'productId': productId,
        'purchaseToken': purchaseToken,
      }),
    );

    return _handleResponse(response, Subscription.fromJson);
  }

  /// Verify App Store purchase
  Future<Subscription> verifyAppStorePurchase({
    required String receiptData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/billing/verify/app-store'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'receiptData': receiptData,
      }),
    );

    return _handleResponse(response, Subscription.fromJson);
  }
}
