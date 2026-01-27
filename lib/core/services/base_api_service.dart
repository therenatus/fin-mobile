import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'http_logger.dart';

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
  /// Mutex for token refresh - prevents race condition when multiple
  /// requests receive 401 simultaneously
  Completer<bool>? _refreshCompleter;
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
    // Real device — use local IP
    return 'http://10.213.34.148:4000/api/v1';
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
  static void notifySessionExpired() {
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

  // ==================== LOGGED HTTP METHODS ====================

  /// Perform GET request with automatic logging
  @protected
  Future<http.Response> loggedGet(Uri url, {Map<String, String>? headers}) async {
    HttpLogger.logRequest(method: 'GET', url: url, headers: headers);
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.get(url, headers: headers);
      stopwatch.stop();
      HttpLogger.logResponse(
        method: 'GET',
        url: url,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e) {
      stopwatch.stop();
      HttpLogger.logError(method: 'GET', url: url, error: e, duration: stopwatch.elapsed);
      rethrow;
    }
  }

  /// Perform POST request with automatic logging
  @protected
  Future<http.Response> loggedPost(Uri url, {Map<String, String>? headers, dynamic body}) async {
    HttpLogger.logRequest(method: 'POST', url: url, headers: headers, body: body);
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.post(url, headers: headers, body: body);
      stopwatch.stop();
      HttpLogger.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e) {
      stopwatch.stop();
      HttpLogger.logError(method: 'POST', url: url, error: e, duration: stopwatch.elapsed);
      rethrow;
    }
  }

  /// Perform PUT request with automatic logging
  @protected
  Future<http.Response> loggedPut(Uri url, {Map<String, String>? headers, dynamic body}) async {
    HttpLogger.logRequest(method: 'PUT', url: url, headers: headers, body: body);
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.put(url, headers: headers, body: body);
      stopwatch.stop();
      HttpLogger.logResponse(
        method: 'PUT',
        url: url,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e) {
      stopwatch.stop();
      HttpLogger.logError(method: 'PUT', url: url, error: e, duration: stopwatch.elapsed);
      rethrow;
    }
  }

  /// Perform PATCH request with automatic logging
  @protected
  Future<http.Response> loggedPatch(Uri url, {Map<String, String>? headers, dynamic body}) async {
    HttpLogger.logRequest(method: 'PATCH', url: url, headers: headers, body: body);
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.patch(url, headers: headers, body: body);
      stopwatch.stop();
      HttpLogger.logResponse(
        method: 'PATCH',
        url: url,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e) {
      stopwatch.stop();
      HttpLogger.logError(method: 'PATCH', url: url, error: e, duration: stopwatch.elapsed);
      rethrow;
    }
  }

  /// Perform DELETE request with automatic logging
  @protected
  Future<http.Response> loggedDelete(Uri url, {Map<String, String>? headers}) async {
    HttpLogger.logRequest(method: 'DELETE', url: url, headers: headers);
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.delete(url, headers: headers);
      stopwatch.stop();
      HttpLogger.logResponse(
        method: 'DELETE',
        url: url,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e) {
      stopwatch.stop();
      HttpLogger.logError(method: 'DELETE', url: url, error: e, duration: stopwatch.elapsed);
      rethrow;
    }
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
  /// Uses a Completer as mutex to prevent race conditions when multiple
  /// requests trigger refresh simultaneously
  @protected
  Future<bool> refreshToken() async {
    // If refresh is already in progress, wait for its result
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final token = await getRefreshToken();
      if (token == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

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
        _refreshCompleter!.complete(true);
        return true;
      }

      await clearTokens();
      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      await clearTokens();
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
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
        notifySessionExpired();
        throw createException('Сессия истекла. Войдите снова.', statusCode: 401);
      }
      throw createException('Retry', statusCode: 401);
    }

    final rawMessage = body['error']?['message'] ??
        body['message'] ??
        'Произошла ошибка';
    // Handle validation errors which may be a List of messages
    final errorMessage = rawMessage is List
        ? rawMessage.join(', ')
        : rawMessage.toString();
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
        notifySessionExpired();
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

  // ==================== LOGIN HELPER ====================

  /// Common login flow for all API services.
  ///
  /// Handles: network errors, response parsing, error extraction, token saving.
  ///
  /// [endpoint] - API endpoint (e.g., '/auth/login')
  /// [body] - Request body as Map
  /// [fromJson] - Function to parse the auth response
  /// [onSuccess] - Callback to save user data after successful login
  /// [invalidCredentialsMessage] - Message for 401 errors (invalid credentials)
  @protected
  Future<T> performLogin<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>) fromJson,
    required Future<void> Function(T response) onSuccess,
    String invalidCredentialsMessage = 'Неверный email или пароль',
  }) async {
    return withNetworkErrorHandling(() async {
      final url = '$baseUrl$endpoint';
      log('LOGIN: Attempting login to $url');

      final response = await http.post(
        Uri.parse(url),
        headers: await getHeaders(auth: false),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      log('LOGIN: Response status: ${response.statusCode}');

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = responseBody['data'] ?? responseBody;
        final authResponse = fromJson(data as Map<String, dynamic>);
        await onSuccess(authResponse);
        return authResponse;
      }

      // For login, 401 means invalid credentials, not expired session
      final errorMessage = responseBody['error']?['message'] ??
          responseBody['message'] ??
          (response.statusCode == 401
              ? invalidCredentialsMessage
              : 'Произошла ошибка');
      throw createException(errorMessage, statusCode: response.statusCode);
    });
  }

  /// Common logout flow for all API services.
  ///
  /// [endpoint] - API endpoint (e.g., '/auth/logout')
  /// [onComplete] - Callback to clear user data (called in finally)
  @protected
  Future<void> performLogout({
    required String endpoint,
    required Future<void> Function() onComplete,
  }) async {
    try {
      await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(),
      );
    } finally {
      await onComplete();
    }
  }
}
