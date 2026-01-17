import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../base_api_service.dart';

/// Materials and stock management API mixin
mixin MaterialsApiMixin on BaseApiService {
  // ==================== MATERIAL CATEGORIES ====================

  /// Get all material categories as tree
  Future<MaterialCategoriesResponse> getMaterialCategories() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/material-categories'),
      headers: await getHeaders(),
    );

    return handleResponse(response, MaterialCategoriesResponse.fromJson);
  }

  /// Get material category by ID
  Future<MaterialCategory> getMaterialCategory(String id) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/material-categories/$id'),
      headers: await getHeaders(),
    );

    return handleResponse(response, MaterialCategory.fromJson);
  }

  /// Create material category
  Future<MaterialCategory> createMaterialCategory({
    required String name,
    String? description,
    String? parentId,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/material-categories'),
      headers: await getHeaders(),
      body: jsonEncode({
        'name': name,
        if (description != null) 'description': description,
        if (parentId != null) 'parentId': parentId,
      }),
    );

    return handleResponse(response, MaterialCategory.fromJson);
  }

  /// Update material category
  Future<MaterialCategory> updateMaterialCategory(
    String id, {
    String? name,
    String? description,
    String? parentId,
  }) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/material-categories/$id'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (parentId != null) 'parentId': parentId,
      }),
    );

    return handleResponse(response, MaterialCategory.fromJson);
  }

  /// Delete material category
  Future<void> deleteMaterialCategory(String id) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/material-categories/$id'),
      headers: await getHeaders(),
    );

    handleResponse(response, (json) => null);
  }

  // ==================== MATERIALS ====================

  /// Get materials with pagination and filters
  Future<MaterialsResponse> getMaterials({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    String? supplierId,
    bool? lowStock,
    bool? isActive,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null) 'search': search,
      if (categoryId != null) 'categoryId': categoryId,
      if (supplierId != null) 'supplierId': supplierId,
      if (lowStock != null) 'lowStock': lowStock.toString(),
      if (isActive != null) 'isActive': isActive.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/materials').replace(queryParameters: queryParams),
      headers: await getHeaders(),
    );

    return handleResponse(response, MaterialsResponse.fromJson);
  }

  /// Get material by ID
  Future<Material> getMaterial(String id) async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/materials/$id'),
      headers: await getHeaders(),
    );

    return handleResponse(response, Material.fromJson);
  }

  /// Create material
  Future<Material> createMaterial({
    required String sku,
    required String name,
    String? description,
    String? categoryId,
    String? supplierId,
    String unit = 'METER',
    double quantity = 0,
    double? minStockLevel,
    double? costPrice,
    double? sellPrice,
    String? color,
    double? width,
    String? composition,
    String? barcode,
    String? imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/materials'),
      headers: await getHeaders(),
      body: jsonEncode({
        'sku': sku,
        'name': name,
        if (description != null) 'description': description,
        if (categoryId != null) 'categoryId': categoryId,
        if (supplierId != null) 'supplierId': supplierId,
        'unit': unit,
        'quantity': quantity,
        if (minStockLevel != null) 'minStockLevel': minStockLevel,
        if (costPrice != null) 'costPrice': costPrice,
        if (sellPrice != null) 'sellPrice': sellPrice,
        if (color != null) 'color': color,
        if (width != null) 'width': width,
        if (composition != null) 'composition': composition,
        if (barcode != null) 'barcode': barcode,
        if (imageUrl != null) 'imageUrl': imageUrl,
      }),
    );

    return handleResponse(response, Material.fromJson);
  }

  /// Update material
  Future<Material> updateMaterial(
    String id, {
    String? sku,
    String? name,
    String? description,
    String? categoryId,
    String? supplierId,
    String? unit,
    double? minStockLevel,
    double? costPrice,
    double? sellPrice,
    String? color,
    double? width,
    String? composition,
    String? barcode,
    String? imageUrl,
  }) async {
    final response = await http.patch(
      Uri.parse('${BaseApiService.baseUrl}/materials/$id'),
      headers: await getHeaders(),
      body: jsonEncode({
        if (sku != null) 'sku': sku,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (categoryId != null) 'categoryId': categoryId,
        if (supplierId != null) 'supplierId': supplierId,
        if (unit != null) 'unit': unit,
        if (minStockLevel != null) 'minStockLevel': minStockLevel,
        if (costPrice != null) 'costPrice': costPrice,
        if (sellPrice != null) 'sellPrice': sellPrice,
        if (color != null) 'color': color,
        if (width != null) 'width': width,
        if (composition != null) 'composition': composition,
        if (barcode != null) 'barcode': barcode,
        if (imageUrl != null) 'imageUrl': imageUrl,
      }),
    );

    return handleResponse(response, Material.fromJson);
  }

  /// Delete material (soft delete)
  Future<void> deleteMaterial(String id) async {
    final response = await http.delete(
      Uri.parse('${BaseApiService.baseUrl}/materials/$id'),
      headers: await getHeaders(),
    );

    handleResponse(response, (json) => null);
  }

  /// Get material stock movements
  Future<StockMovementsResponse> getMaterialMovements(
    String id, {
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/materials/$id/movements').replace(queryParameters: queryParams),
      headers: await getHeaders(),
    );

    return handleResponse(response, StockMovementsResponse.fromJson);
  }

  /// Adjust material stock
  Future<Material> adjustStock(
    String id, {
    required double quantity,
    required String reason,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/materials/$id/adjust'),
      headers: await getHeaders(),
      body: jsonEncode({
        'quantity': quantity,
        'reason': reason,
      }),
    );

    return handleResponse(response, Material.fromJson);
  }

  /// Reserve material stock
  Future<Material> reserveMaterial(
    String id, {
    required double quantity,
    String? orderId,
    String? reason,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/materials/$id/reserve'),
      headers: await getHeaders(),
      body: jsonEncode({
        'quantity': quantity,
        if (orderId != null) 'orderId': orderId,
        if (reason != null) 'reason': reason,
      }),
    );

    return handleResponse(response, Material.fromJson);
  }

  /// Get materials with low stock
  Future<LowStockResponse> getLowStockMaterials() async {
    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/materials/low-stock'),
      headers: await getHeaders(),
    );

    return handleResponse(response, LowStockResponse.fromJson);
  }

  /// Get material by barcode
  Future<Material?> getMaterialByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/materials/by-barcode/$barcode'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 404) {
        return null;
      }

      return handleResponse(response, Material.fromJson);
    } catch (e) {
      return null;
    }
  }

  // ==================== STOCK MOVEMENTS ====================

  /// Get stock movements with filters
  Future<StockMovementsResponse> getStockMovements({
    int page = 1,
    int limit = 20,
    String? materialId,
    String? type,
    String? orderId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (materialId != null) 'materialId': materialId,
      if (type != null) 'type': type,
      if (orderId != null) 'orderId': orderId,
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
    };

    final response = await http.get(
      Uri.parse('${BaseApiService.baseUrl}/stock-movements').replace(queryParameters: queryParams),
      headers: await getHeaders(),
    );

    return handleResponse(response, StockMovementsResponse.fromJson);
  }

  /// Consume materials for order (batch)
  Future<Map<String, dynamic>> consumeMaterials({
    required String orderId,
    required List<Map<String, dynamic>> items,
    String? reason,
  }) async {
    final response = await http.post(
      Uri.parse('${BaseApiService.baseUrl}/stock-movements/consume'),
      headers: await getHeaders(),
      body: jsonEncode({
        'orderId': orderId,
        'items': items,
        if (reason != null) 'reason': reason,
      }),
    );

    return handleResponse(response, (json) => json);
  }
}
