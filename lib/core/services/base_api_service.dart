import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Base exception class for all API services
class BaseApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final bool isNetworkError;

  BaseApiException(
    this.message, {
    this.statusCode,
    this.data,
    this.isNetworkError = false,
  });

  @override
  String toString() => message;
}

/// Abstract base class for all API services
/// Provides common functionality for network requests, auth, and error handling
abstract class BaseApiService {
  // API URL from build-time configuration
  // Usage: flutter build apk --dart-define=API_URL=https://api.yourdomain.com/api/v1
  static const String _apiUrl =
      String.fromEnvironment('API_URL', defaultValue: '');

  static String get baseUrl {
    // If API_URL is configured via dart-define, use it
    if (_apiUrl.isNotEmpty) {
      return _apiUrl;
    }

    // Fallback for development
    if (kIsWeb) {
      return 'http://localhost:4000/api/v1';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 is the special alias to host machine from Android emulator
      return 'http://10.0.2.2:4000/api/v1';
    }
    // iOS Simulator uses localhost
    return 'http://localhost:4000/api/v1';
  }

  /// Registry of session expiration callbacks by mode (manager, client, employee)
  static final Map<String, VoidCallback> _sessionExpiredCallbacks = {};

  /// Register a callback for session expiration
  static void registerSessionExpiredCallback(String key, VoidCallback callback) {
    _sessionExpiredCallbacks[key] = callback;
  }

  /// Unregister a session expiration callback
  static void unregisterSessionExpiredCallback(String key) {
    _sessionExpiredCallbacks.remove(key);
  }

  /// Notify all registered callbacks about session expiration
  static void _notifySessionExpired() {
    for (final callback in _sessionExpiredCallbacks.values) {
      callback();
    }
  }

  /// @deprecated Use registerSessionExpiredCallback instead
  @Deprecated('Use registerSessionExpiredCallback instead')
  static VoidCallback? onSessionExpired;

  @protected
  final StorageService storage;

  BaseApiService(this.storage);

  // ==================== ABSTRACT METHODS (subclasses implement) ====================

  /// Prefix for debug logging (e.g., '[ApiService]')
  String get logPrefix;

  /// Endpoint for token refresh (e.g., '/auth/refresh')
  String get authRefreshEndpoint;

  /// Get access token from storage
  Future<String?> getAccessToken();

  /// Get refresh token from storage
  Future<String?> getRefreshToken();

  /// Save tokens to storage
  Future<void> saveTokens(String accessToken, String refreshToken);

  /// Clear tokens from storage
  Future<void> clearTokens();

  /// Create service-specific exception
  BaseApiException createException(
    String message, {
    int? statusCode,
    dynamic data,
    bool isNetworkError = false,
  });

  // ==================== SHARED IMPLEMENTATION ====================

  /// Debug logging helper
  @protected
  void log(String message) {
    debugPrint('$logPrefix $message');
  }

  /// Get headers for HTTP requests
  @protected
  Future<Map<String, String>> getHeaders({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Wrap request with network error handling
  @protected
  Future<T> withNetworkErrorHandling<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on SocketException catch (_) {
      throw createException(
        'Не удалось подключиться к серверу. Проверьте интернет-соединение.',
        isNetworkError: true,
      );
    } on TimeoutException catch (_) {
      throw createException(
        'Сервер не отвечает. Попробуйте позже.',
        isNetworkError: true,
      );
    } on HttpException catch (_) {
      throw createException(
        'Ошибка соединения с сервером.',
        isNetworkError: true,
      );
    } on HandshakeException catch (_) {
      throw createException(
        'Ошибка безопасного соединения.',
        isNetworkError: true,
      );
    }
  }

  /// Wrap request with automatic retry after token refresh (max 1 retry)
  @protected
  Future<T> withRetry<T>(Future<T> Function() request, {bool isRetry = false}) async {
    try {
      return await request();
    } on BaseApiException catch (e) {
      if (e.message == 'Retry' && e.statusCode == 401 && !isRetry) {
        // Retry request with refreshed tokens (only once)
        return await withRetry(request, isRetry: true);
      }
      rethrow;
    }
  }

  /// Refresh access token using refresh token
  @protected
  Future<bool> refreshToken() async {
    try {
      final token = await getRefreshToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl$authRefreshEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        await saveTokens(
          data['accessToken'] as String,
          data['refreshToken'] as String,
        );
        return true;
      }

      await clearTokens();
      return false;
    } catch (e) {
      await clearTokens();
      return false;
    }
  }

  /// Handle single object response
  @protected
  Future<T> handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body['success'] == true && body['data'] != null) {
        return fromJson(body['data'] as Map<String, dynamic>);
      }
      if (body['data'] != null) {
        return fromJson(body['data'] as Map<String, dynamic>);
      }
      return fromJson(body);
    }

    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (!refreshed) {
        _notifySessionExpired();
        throw createException('Сессия истекла. Войдите снова.', statusCode: 401);
      }
      throw createException('Retry', statusCode: 401);
    }

    final errorMessage = body['error']?['message'] ??
        body['message'] ??
        'Произошла ошибка';
    throw createException(errorMessage, statusCode: response.statusCode, data: body);
  }

  /// Handle list response with optional key extraction
  @protected
  Future<List<T>> handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson, [
    String? key,
  ]) async {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      List<dynamic> list;

      if (body is List) {
        list = body;
      } else if (body is Map<String, dynamic>) {
        final data = body['data'] ?? body;
        if (data is List) {
          list = data;
        } else if (key != null && data is Map && data[key] != null) {
          list = data[key] as List<dynamic>;
        } else {
          list = [];
        }
      } else {
        list = [];
      }

      return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }

    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (!refreshed) {
        _notifySessionExpired();
        throw createException('Сессия истекла', statusCode: 401);
      }
      throw createException('Retry', statusCode: 401);
    }

    final bodyMap = body is Map<String, dynamic> ? body : <String, dynamic>{};
    throw createException(
      bodyMap['error']?['message'] ?? 'Произошла ошибка',
      statusCode: response.statusCode,
    );
  }

  /// Handle list response with automatic retry on 401 (max 1 retry)
  @protected
  Future<List<T>> getListWithRetry<T>(
    Future<http.Response> Function() request,
    T Function(Map<String, dynamic>) fromJson,
    String key, {
    bool isRetry = false,
  }) async {
    try {
      final response = await request();
      return await handleListResponse(response, fromJson, key);
    } on BaseApiException catch (e) {
      if (e.message == 'Retry' && !isRetry) {
        // Token was refreshed, retry the request (only once)
        return await getListWithRetry(request, fromJson, key, isRetry: true);
      }
      rethrow;
    }
  }
}
