import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';
import '../api_service.dart';

/// Bill of Materials (BOM) management API mixin
mixin BomApiMixin on BaseApiService {
  /// Create BOM for model
  Future<Bom> createBom({
    required String modelId,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> operations,
    String? notes,
    bool isActive = true,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/models/$modelId/bom'),
      headers: await getHeaders(),
      body: jsonEncode({
        'items': items,
        'operations': operations,
        if (notes != null) 'notes': notes,
        'isActive': isActive,
      }),
    );

    return handleResponse(response, Bom.fromJson);
  }

  /// Get active BOM for model
  Future<Bom?> getModelBom(String modelId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/models/$modelId/bom'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'] ?? body;
      if (data == null) return null;
      return Bom.fromJson(data as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      return null;
    }

    throw ApiException(
      'Ошибка загрузки BOM',
      statusCode: response.statusCode,
    );
  }

  /// Get all BOM versions for model
  Future<BomVersionsResponse> getBomVersions(String modelId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/models/$modelId/bom/versions'),
      headers: await getHeaders(),
    );

    return handleResponse(response, BomVersionsResponse.fromJson);
  }

  /// Recalculate active BOM for model
  Future<Bom> recalculateModelBom(String modelId) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/models/$modelId/bom/calculate'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Bom.fromJson);
  }

  /// Get BOM by ID
  Future<Bom> getBom(String bomId) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/bom/$bomId'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Bom.fromJson);
  }

  /// Update BOM
  Future<Bom> updateBom(
    String bomId, {
    List<Map<String, dynamic>>? items,
    List<Map<String, dynamic>>? operations,
    String? notes,
    bool? isActive,
  }) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/bom/$bomId'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (items != null) 'items': items,
        if (operations != null) 'operations': operations,
        if (notes != null) 'notes': notes,
        if (isActive != null) 'isActive': isActive,
      }),
    );

    return handleResponse(response, Bom.fromJson);
  }

  /// Delete BOM
  Future<void> deleteBom(String bomId) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/bom/$bomId'),
      headers: await getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Ошибка удаления BOM',
        statusCode: response.statusCode,
      );
    }
  }

  /// Recalculate BOM by ID
  Future<Bom> recalculateBom(String bomId) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/bom/$bomId/calculate'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Bom.fromJson);
  }
}
