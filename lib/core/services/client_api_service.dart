import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/client_user.dart';
import 'storage_service.dart';

void _log(String message) {
  debugPrint('[ClientApiService] $message');
}

class ClientApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  ClientApiException(this.message, {this.statusCode, this.isNetworkError = false});

  @override
  String toString() => message;
}

/// Helper to handle network errors
Future<T> _withNetworkErrorHandling<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on SocketException catch (_) {
    throw ClientApiException(
      'Не удалось подключиться к серверу. Проверьте интернет-соединение.',
      isNetworkError: true,
    );
  } on TimeoutException catch (_) {
    throw ClientApiException(
      'Сервер не отвечает. Попробуйте позже.',
      isNetworkError: true,
    );
  } on HttpException catch (_) {
    throw ClientApiException(
      'Ошибка соединения с сервером.',
      isNetworkError: true,
    );
  } on HandshakeException catch (_) {
    throw ClientApiException(
      'Ошибка безопасного соединения.',
      isNetworkError: true,
    );
  }
}

class ClientApiService {
  static const String _baseUrl = 'http://localhost:4000/api/v1';

  static String get baseUrl {
    if (kIsWeb) return _baseUrl;
    if (Platform.isAndroid) return 'http://10.225.124.142:4000/api/v1';
    return 'http://10.225.124.142:4000/api/v1';
  }

  /// Callback для обработки истечения сессии
  static VoidCallback? onSessionExpired;

  final StorageService _storage;

  ClientApiService(this._storage);

  Future<Map<String, String>> _getHeaders({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await _storage.getClientAccessToken();
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
    } on ClientApiException catch (e) {
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
        throw ClientApiException('Сессия истекла. Войдите снова.',
            statusCode: 401);
      }
      throw ClientApiException('Retry', statusCode: 401);
    }

    final errorMessage =
        body['error']?['message'] ?? body['message'] ?? 'Произошла ошибка';
    throw ClientApiException(errorMessage, statusCode: response.statusCode);
  }

  Future<List<T>> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] ?? body;
      if (data is List) {
        return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      }
      return (data as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (!refreshed) {
        onSessionExpired?.call();
        throw ClientApiException('Сессия истекла. Войдите снова.',
            statusCode: 401);
      }
      throw ClientApiException('Retry', statusCode: 401);
    }

    throw ClientApiException(
      body['error']?['message'] ?? 'Произошла ошибка',
      statusCode: response.statusCode,
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getClientRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/client/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        await _storage.saveClientTokens(
          data['accessToken'] as String,
          data['refreshToken'] as String,
        );
        return true;
      }

      await _storage.clearClientTokens();
      return false;
    } catch (e) {
      await _storage.clearClientTokens();
      return false;
    }
  }

  // ==================== AUTH ====================

  Future<ClientAuthResponse> login({String? email, String? phone, required String password}) async {
    return _withNetworkErrorHandling(() async {
      final url = '$baseUrl/client/auth/login';
      _log('LOGIN: Attempting client login to $url');

      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(auth: false),
        body: jsonEncode({
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      _log('LOGIN: Response status: ${response.statusCode}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'] ?? body;
        final authResponse = ClientAuthResponse.fromJson(data as Map<String, dynamic>);
        await _storage.saveClientTokens(
            authResponse.accessToken, authResponse.refreshToken);
        await _storage.saveClientUser(authResponse.user);
        return authResponse;
      }

      // For login, 401 means invalid credentials, not expired session
      final errorMessage = body['error']?['message'] ??
          body['message'] ??
          (response.statusCode == 401
              ? 'Неверный email/телефон или пароль'
              : 'Произошла ошибка');
      throw ClientApiException(errorMessage, statusCode: response.statusCode);
    });
  }

  Future<ClientAuthResponse> register({
    String? email,
    String? phone,
    required String password,
    required String name,
  }) async {
    return _withNetworkErrorHandling(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/client/auth/register'),
        headers: await _getHeaders(auth: false),
        body: jsonEncode({
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          'password': password,
          'name': name,
        }),
      ).timeout(const Duration(seconds: 15));

      final authResponse =
          await _handleResponse(response, ClientAuthResponse.fromJson);
      await _storage.saveClientTokens(
          authResponse.accessToken, authResponse.refreshToken);
      await _storage.saveClientUser(authResponse.user);

      return authResponse;
    });
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/client/auth/logout'),
        headers: await _getHeaders(),
      );
    } finally {
      await _storage.clearClientTokens();
    }
  }

  Future<ClientUser> getProfile() async {
    return _withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('$baseUrl/client/auth/me'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response, ClientUser.fromJson);
    });
  }

  // ==================== PORTAL ====================

  Future<List<TenantLink>> getMyTenants() async {
    return _withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('$baseUrl/client/portal/tenants'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return _handleListResponse(response, TenantLink.fromJson);
    });
  }

  Future<TenantLink> linkToTenant(String tenantId, {String? name}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/client/portal/tenants/link'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'tenantId': tenantId,
        if (name != null) 'name': name,
      }),
    );

    return _handleResponse(response, TenantLink.fromJson);
  }

  Future<List<ClientOrderModel>> getTenantModels(String tenantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/client/portal/tenants/$tenantId/models'),
      headers: await _getHeaders(),
    );

    return _handleListResponse(response, ClientOrderModel.fromJson);
  }

  Future<ClientOrdersResponse> getMyOrders({
    String? tenantId,
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    return _withNetworkErrorHandling(() async {
      final params = <String>['page=$page', 'limit=$limit'];
      if (tenantId != null) params.add('tenantId=$tenantId');
      if (status != null) params.add('status=$status');

      final url = '$baseUrl/client/portal/orders?${params.join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response, ClientOrdersResponse.fromJson);
    });
  }

  Future<ClientOrder> getOrder(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/client/portal/orders/$orderId'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response, ClientOrder.fromJson);
  }

  Future<ClientOrder> createOrder({
    required String tenantId,
    required String modelId,
    required int quantity,
    String? dueDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/client/portal/orders'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'tenantId': tenantId,
        'modelId': modelId,
        'quantity': quantity,
        if (dueDate != null) 'dueDate': dueDate,
      }),
    );

    return _handleResponse(response, ClientOrder.fromJson);
  }

  Future<ClientOrder> updateOrder({
    required String orderId,
    String? modelId,
    int? quantity,
    String? dueDate,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/client/portal/orders/$orderId'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (modelId != null) 'modelId': modelId,
        if (quantity != null) 'quantity': quantity,
        if (dueDate != null) 'dueDate': dueDate,
      }),
    );

    return _handleResponse(response, ClientOrder.fromJson);
  }

  Future<void> cancelOrder(String orderId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/client/portal/orders/$orderId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ClientApiException(
        body['message'] ?? 'Failed to cancel order',
        statusCode: response.statusCode,
      );
    }
  }
}
