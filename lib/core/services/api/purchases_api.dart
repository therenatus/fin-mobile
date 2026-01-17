import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

/// Purchases management API mixin
mixin PurchasesApiMixin on BaseApiService {
  /// Get purchases with pagination and filters
  Future<PurchasesResponse> getPurchases({
    int page = 1,
    int limit = 20,
    String? status,
    String? supplierId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (supplierId != null) 'supplierId': supplierId,
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
    };

    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/purchases').replace(queryParameters: queryParams),
      headers: await getHeaders(),
    );

    return handleResponse(response, PurchasesResponse.fromJson);
  }

  /// Get purchase by ID
  Future<Purchase> getPurchase(String id) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/purchases/$id'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Purchase.fromJson);
  }

  /// Create purchase
  Future<Purchase> createPurchase({
    String? supplierId,
    String? orderDate,
    String? expectedDate,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/purchases'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (supplierId != null) 'supplierId': supplierId,
        if (orderDate != null) 'orderDate': orderDate,
        if (expectedDate != null) 'expectedDate': expectedDate,
        if (notes != null) 'notes': notes,
        'items': items,
      }),
    );

    return handleResponse(response, Purchase.fromJson);
  }

  /// Update purchase (only DRAFT)
  Future<Purchase> updatePurchase(
    String id, {
    String? supplierId,
    String? orderDate,
    String? expectedDate,
    String? notes,
  }) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/purchases/$id'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (supplierId != null) 'supplierId': supplierId,
        if (orderDate != null) 'orderDate': orderDate,
        if (expectedDate != null) 'expectedDate': expectedDate,
        if (notes != null) 'notes': notes,
      }),
    );

    return handleResponse(response, Purchase.fromJson);
  }

  /// Delete purchase (only DRAFT)
  Future<void> deletePurchase(String id) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/purchases/$id'),
      headers: await getHeaders(),
    );

    handleResponse(response, (json) => null);
  }

  /// Change purchase status
  Future<Purchase> changePurchaseStatus(
    String id, {
    required String status,
    String? notes,
  }) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/purchases/$id/status'),
      headers: await getHeaders(),
      body: jsonEncode({
        'status': status,
        if (notes != null) 'notes': notes,
      }),
    );

    return handleResponse(response, Purchase.fromJson);
  }

  /// Receive purchase items
  Future<Map<String, dynamic>> receivePurchaseItems(
    String id, {
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/purchases/$id/receive'),
      headers: await getHeaders(),
      body: jsonEncode({
        'items': items,
      }),
    );

    return handleResponse(response, (json) => json);
  }
}
