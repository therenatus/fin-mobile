import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

mixin ClientsApiMixin on BaseApiService {
  Future<Map<String, dynamic>?> searchClientUserByEmail(String email) async {
    if (email.isEmpty) return null;

    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/clients/search-user?email=${Uri.encodeComponent(email)}'),
      headers: await getHeaders(),
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
    return getListWithRetry(
      () async => http.get(
        Uri.parse('${BaseApiService.baseUrl}/clients?page=$page&limit=$limit'),
        headers: await getHeaders(),
      ),
      Client.fromJson,
      'clients',
    );
  }

  Future<Client> getClient(String id) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/clients/$id'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Client.fromJson);
  }

  Future<Client> createClient({
    required String name,
    String? email,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/clients'),
      headers: await getHeaders(),
      body: jsonEncode({
        'name': name,
        'contacts': {'email': email, 'phone': phone},
      }),
    );

    return handleResponse(response, Client.fromJson);
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
      Uri.parse('${BaseApiService.baseUrl}/clients/$id'),
      headers: await getHeaders(),
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

    return handleResponse(response, Client.fromJson);
  }

  Future<void> deleteClient(String id) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/clients/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw createException(
        body['message'] ?? 'Failed to delete client',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<OrderModel>> getClientAssignedModels(String clientId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/clients/$clientId/models'),
      headers: await getHeaders(),
    );

    return handleListResponse(response, OrderModel.fromJson, 'models');
  }

  Future<Client> assignModelsToClient(String clientId, List<String> modelIds) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/clients/$clientId/models'),
      headers: await getHeaders(),
      body: jsonEncode({'modelIds': modelIds}),
    );

    return handleResponse(response, Client.fromJson);
  }

  Future<Client> setClientAssignedModels(String clientId, List<String> modelIds) async {
    final response = await http.put(
      Uri.parse('${BaseApiService.baseUrl}/clients/$clientId/models'),
      headers: await getHeaders(),
      body: jsonEncode({'modelIds': modelIds}),
    );

    return handleResponse(response, Client.fromJson);
  }

  Future<Client> unassignModelFromClient(String clientId, String modelId) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/clients/$clientId/models/$modelId'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Client.fromJson);
  }
}
