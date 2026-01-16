import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

mixin OrdersApiMixin on BaseApiService {
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

    final uri = Uri.parse('${BaseApiService.baseUrl}/orders').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await getHeaders());

    return handleResponse(response, OrdersResponse.fromJson);
  }

  Future<Order> getOrder(String id) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/orders/$id'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Order.fromJson);
  }

  Future<Order> createOrder({
    required String clientId,
    required String modelId,
    required int quantity,
    String? dueDate,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/orders'),
      headers: await getHeaders(),
      body: jsonEncode({
        'clientId': clientId,
        'modelId': modelId,
        'quantity': quantity,
        if (dueDate != null) 'dueDate': dueDate,
      }),
    );

    return handleResponse(response, Order.fromJson);
  }

  Future<Order> updateOrderStatus(String id, String status) async {
    final response = await http.put(
      Uri.parse('${BaseApiService.baseUrl}/orders/$id/status'),
      headers: await getHeaders(),
      body: jsonEncode({'status': status}),
    );

    return handleResponse(response, Order.fromJson);
  }
}
