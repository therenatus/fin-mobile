import 'package:flutter/foundation.dart';
import '../models/material.dart' as mat;
import '../models/stock_movement.dart';
import '../services/api_service.dart';

/// State enum for materials operations
enum MaterialsState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider for managing materials inventory
class MaterialsProvider with ChangeNotifier {
  final ApiService _api;

  MaterialsState _state = MaterialsState.initial;
  List<mat.Material> _materials = [];
  List<mat.MaterialCategory> _categories = [];
  String? _error;

  // Pagination
  int _page = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Filters
  String? _categoryId;
  String _searchQuery = '';
  bool _showLowStockOnly = false;

  // Low stock materials cache
  List<mat.Material> _lowStockMaterials = [];

  MaterialsProvider(this._api);

  // Getters
  MaterialsState get state => _state;
  List<mat.Material> get materials => _materials;
  List<mat.MaterialCategory> get categories => _categories;
  String? get error => _error;
  bool get isLoading => _state == MaterialsState.loading;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  String? get categoryId => _categoryId;
  String get searchQuery => _searchQuery;
  bool get showLowStockOnly => _showLowStockOnly;
  List<mat.Material> get lowStockMaterials => _lowStockMaterials;
  int get lowStockCount => _lowStockMaterials.length;

  /// Load materials with current filters
  Future<void> loadMaterials() async {
    _state = MaterialsState.loading;
    _page = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.getMaterials(
        page: _page,
        limit: 20,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        categoryId: _categoryId,
        lowStock: _showLowStockOnly ? true : null,
        isActive: true,
      );

      _materials = response.materials;
      _totalPages = response.totalPages;
      _hasMore = _page < _totalPages;
      _state = MaterialsState.loaded;
    } catch (e) {
      debugPrint('[MaterialsProvider] loadMaterials error: $e');
      _error = e.toString();
      _state = MaterialsState.error;
    }

    notifyListeners();
  }

  /// Load more materials (pagination)
  Future<void> loadMoreMaterials() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _page++;
      final response = await _api.getMaterials(
        page: _page,
        limit: 20,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        categoryId: _categoryId,
        lowStock: _showLowStockOnly ? true : null,
        isActive: true,
      );

      _materials.addAll(response.materials);
      _totalPages = response.totalPages;
      _hasMore = _page < _totalPages;
    } catch (e) {
      debugPrint('[MaterialsProvider] loadMoreMaterials error: $e');
      _page--;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Refresh materials
  Future<void> refresh() async {
    await loadMaterials();
    await loadLowStockMaterials();
  }

  /// Load categories
  Future<void> loadCategories() async {
    try {
      final response = await _api.getMaterialCategories();
      _categories = response.flat;
      notifyListeners();
    } catch (e) {
      debugPrint('[MaterialsProvider] loadCategories error: $e');
    }
  }

  /// Load low stock materials
  Future<void> loadLowStockMaterials() async {
    try {
      final response = await _api.getLowStockMaterials();
      _lowStockMaterials = response.materials;
      notifyListeners();
    } catch (e) {
      debugPrint('[MaterialsProvider] loadLowStockMaterials error: $e');
    }
  }

  /// Find material by barcode
  Future<mat.Material?> findByBarcode(String barcode) async {
    try {
      return await _api.getMaterialByBarcode(barcode);
    } catch (e) {
      debugPrint('[MaterialsProvider] findByBarcode error: $e');
      return null;
    }
  }

  /// Get material by ID
  Future<mat.Material?> getMaterial(String id) async {
    try {
      return await _api.getMaterial(id);
    } catch (e) {
      debugPrint('[MaterialsProvider] getMaterial error: $e');
      return null;
    }
  }

  /// Get stock movements for material
  Future<StockMovementsResponse?> getStockMovements(
    String materialId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _api.getMaterialMovements(
        materialId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      debugPrint('[MaterialsProvider] getStockMovements error: $e');
      return null;
    }
  }

  /// Adjust stock quantity
  Future<mat.Material?> adjustStock(
    String materialId, {
    required double quantity,
    required String reason,
  }) async {
    try {
      final updated = await _api.adjustStock(
        materialId,
        quantity: quantity,
        reason: reason,
      );

      // Update local list
      final index = _materials.indexWhere((m) => m.id == materialId);
      if (index != -1) {
        _materials[index] = updated;
        notifyListeners();
      }

      // Reload low stock if needed
      await loadLowStockMaterials();

      return updated;
    } catch (e) {
      debugPrint('[MaterialsProvider] adjustStock error: $e');
      rethrow;
    }
  }

  /// Reserve stock
  Future<mat.Material?> reserveStock(
    String materialId, {
    required double quantity,
    String? orderId,
    String? reason,
  }) async {
    try {
      final updated = await _api.reserveMaterial(
        materialId,
        quantity: quantity,
        orderId: orderId,
        reason: reason,
      );

      // Update local list
      final index = _materials.indexWhere((m) => m.id == materialId);
      if (index != -1) {
        _materials[index] = updated;
        notifyListeners();
      }

      return updated;
    } catch (e) {
      debugPrint('[MaterialsProvider] reserveStock error: $e');
      rethrow;
    }
  }

  /// Set category filter
  void setCategory(String? categoryId) {
    if (_categoryId == categoryId) return;
    _categoryId = categoryId;
    loadMaterials();
  }

  /// Set search query
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    loadMaterials();
  }

  /// Set low stock filter
  void setLowStockFilter(bool enabled) {
    if (_showLowStockOnly == enabled) return;
    _showLowStockOnly = enabled;
    loadMaterials();
  }

  /// Clear filters
  void clearFilters() {
    _categoryId = null;
    _searchQuery = '';
    _showLowStockOnly = false;
    loadMaterials();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
