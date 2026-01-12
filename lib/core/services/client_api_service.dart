import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client_user.dart';
import 'storage_service.dart';
import 'base_api_service.dart';

/// Exception class for ClientApiService
class ClientApiException extends BaseApiException {
  ClientApiException(
    super.message, {
    super.statusCode,
    super.isNetworkError,
  });
}

class ClientApiService extends BaseApiService {
  ClientApiService(StorageService storage) : super(storage);

  // ==================== ABSTRACT METHOD IMPLEMENTATIONS ====================

  @override
  String get logPrefix => '[ClientApiService]';

  @override
  String get authRefreshEndpoint => '/client/auth/refresh';

  @override
  Future<String?> getAccessToken() => storage.getClientAccessToken();

  @override
  Future<String?> getRefreshToken() => storage.getClientRefreshToken();

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) =>
      storage.saveClientTokens(accessToken, refreshToken);

  @override
  Future<void> clearTokens() => storage.clearClientTokens();

  @override
  ClientApiException createException(
    String message, {
    int? statusCode,
    dynamic data,
    bool isNetworkError = false,
  }) =>
      ClientApiException(message, statusCode: statusCode, isNetworkError: isNetworkError);

  // ==================== AUTH ====================

  Future<ClientAuthResponse> login({String? email, String? phone, required String password}) async {
    return performLogin(
      endpoint: '/client/auth/login',
      body: {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'password': password,
      },
      fromJson: ClientAuthResponse.fromJson,
      onSuccess: (response) async {
        await storage.saveClientTokens(response.accessToken, response.refreshToken);
        await storage.saveClientUser(response.user);
      },
      invalidCredentialsMessage: 'Неверный email/телефон или пароль',
    );
  }

  Future<ClientAuthResponse> register({
    String? email,
    String? phone,
    required String password,
    required String name,
  }) async {
    return withNetworkErrorHandling(() async {
      final response = await http.post(
        Uri.parse('${BaseApiService.baseUrl}/client/auth/register'),
        headers: await getHeaders(auth: false),
        body: jsonEncode({
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          'password': password,
          'name': name,
        }),
      ).timeout(const Duration(seconds: 15));

      final authResponse =
          await handleResponse(response, ClientAuthResponse.fromJson);
      await storage.saveClientTokens(
          authResponse.accessToken, authResponse.refreshToken);
      await storage.saveClientUser(authResponse.user);

      return authResponse;
    });
  }

  Future<void> logout() async {
    return performLogout(
      endpoint: '/client/auth/logout',
      onComplete: () => storage.clearClientTokens(),
    );
  }

  Future<ClientUser> getProfile() async {
    return withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/client/auth/me'),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return handleResponse(response, ClientUser.fromJson);
    });
  }

  // ==================== PORTAL ====================

  Future<List<TenantLink>> getMyTenants() async {
    return withNetworkErrorHandling(() async {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/client/portal/tenants'),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return handleListResponse(response, TenantLink.fromJson);
    });
  }

  Future<TenantLink> linkToTenant(String tenantId, {String? name}) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/client/portal/tenants/link'),
      headers: await getHeaders(),
      body: jsonEncode({
        'tenantId': tenantId,
        if (name != null) 'name': name,
      }),
    );

    return handleResponse(response, TenantLink.fromJson);
  }

  Future<List<ClientOrderModel>> getTenantModels(String tenantId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/client/portal/tenants/$tenantId/models'),
      headers: await getHeaders(),
    );

    return handleListResponse(response, ClientOrderModel.fromJson);
  }

  Future<ClientOrdersResponse> getMyOrders({
    String? tenantId,
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    return withNetworkErrorHandling(() async {
      final params = <String>['page=$page', 'limit=$limit'];
      if (tenantId != null) params.add('tenantId=$tenantId');
      if (status != null) params.add('status=$status');

      final url = '${BaseApiService.baseUrl}/client/portal/orders?${params.join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 15));

      return handleResponse(response, ClientOrdersResponse.fromJson);
    });
  }

  Future<ClientOrder> getOrder(String orderId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/client/portal/orders/$orderId'),
      headers: await getHeaders(),
    );

    return handleResponse(response, ClientOrder.fromJson);
  }

  Future<ClientOrder> createOrder({
    required String tenantId,
    required String modelId,
    required int quantity,
    String? dueDate,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/client/portal/orders'),
      headers: await getHeaders(),
      body: jsonEncode({
        'tenantId': tenantId,
        'modelId': modelId,
        'quantity': quantity,
        if (dueDate != null) 'dueDate': dueDate,
      }),
    );

    return handleResponse(response, ClientOrder.fromJson);
  }

  Future<ClientOrder> updateOrder({
    required String orderId,
    String? modelId,
    int? quantity,
    String? dueDate,
  }) async {
    final response = await http.put(
      Uri.parse('${BaseApiService.baseUrl}/client/portal/orders/$orderId'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (modelId != null) 'modelId': modelId,
        if (quantity != null) 'quantity': quantity,
        if (dueDate != null) 'dueDate': dueDate,
      }),
    );

    return handleResponse(response, ClientOrder.fromJson);
  }

  Future<void> cancelOrder(String orderId) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/client/portal/orders/$orderId'),
      headers: await getHeaders(),
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
