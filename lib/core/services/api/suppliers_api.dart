import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

/// Suppliers management API mixin
mixin SuppliersApiMixin on BaseApiService {
  /// Get suppliers with pagination and filters
  Future<SuppliersResponse> getSuppliers({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null) 'search': search,
      if (isActive != null) 'isActive': isActive.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/suppliers').replace(queryParameters: queryParams),
      headers: await getHeaders(),
    );

    return handleResponse(response, SuppliersResponse.fromJson);
  }

  /// Get supplier by ID
  Future<Supplier> getSupplier(String id) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/suppliers/$id'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Supplier.fromJson);
  }

  /// Create supplier
  Future<Supplier> createSupplier({
    required String name,
    String? contactName,
    String? phone,
    String? email,
    String? address,
    String? inn,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/suppliers'),
      headers: await getHeaders(),
      body: jsonEncode({
        'name': name,
        if (contactName != null) 'contactName': contactName,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (inn != null) 'inn': inn,
        if (notes != null) 'notes': notes,
      }),
    );

    return handleResponse(response, Supplier.fromJson);
  }

  /// Update supplier
  Future<Supplier> updateSupplier(
    String id, {
    String? name,
    String? contactName,
    String? phone,
    String? email,
    String? address,
    String? inn,
    String? notes,
  }) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/suppliers/$id'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (contactName != null) 'contactName': contactName,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (inn != null) 'inn': inn,
        if (notes != null) 'notes': notes,
      }),
    );

    return handleResponse(response, Supplier.fromJson);
  }

  /// Delete supplier (soft delete)
  Future<void> deleteSupplier(String id) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/suppliers/$id'),
      headers: await getHeaders(),
    );

    handleResponse(response, (json) => null);
  }
}
