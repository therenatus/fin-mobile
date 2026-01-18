import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/material.dart' as mat;
import '../models/stock_movement.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

void _log(String message) {
  debugPrint('[MaterialsNotifier] $message');
}

/// State enum for materials operations
enum MaterialsLoadingState {
  initial,
  loading,
  loaded,
  error,
}

/// Materials state data
class MaterialsStateData {
  final MaterialsLoadingState loadingState;
  final List<mat.Material> materials;
  final List<mat.MaterialCategory> categories;
  final String? error;

  // Pagination
  final int page;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  // Filters
  final String? categoryId;
  final String searchQuery;
  final bool showLowStockOnly;

  // Low stock materials cache
  final List<mat.Material> lowStockMaterials;

  const MaterialsStateData({
    this.loadingState = MaterialsLoadingState.initial,
    this.materials = const [],
    this.categories = const [],
    this.error,
    this.page = 1,
    this.totalPages = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.categoryId,
    this.searchQuery = '',
    this.showLowStockOnly = false,
    this.lowStockMaterials = const [],
  });

  bool get isLoading => loadingState == MaterialsLoadingState.loading;
  int get lowStockCount => lowStockMaterials.length;

  MaterialsStateData copyWith({
    MaterialsLoadingState? loadingState,
    List<mat.Material>? materials,
    List<mat.MaterialCategory>? categories,
    String? error,
    int? page,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
    String? categoryId,
    String? searchQuery,
    bool? showLowStockOnly,
    List<mat.Material>? lowStockMaterials,
    bool clearError = false,
    bool clearCategoryId = false,
  }) {
    return MaterialsStateData(
      loadingState: loadingState ?? this.loadingState,
      materials: materials ?? this.materials,
      categories: categories ?? this.categories,
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      showLowStockOnly: showLowStockOnly ?? this.showLowStockOnly,
      lowStockMaterials: lowStockMaterials ?? this.lowStockMaterials,
    );
  }
}

/// Materials Notifier for managing materials inventory
class MaterialsNotifier extends Notifier<MaterialsStateData> {
  @override
  MaterialsStateData build() {
    return const MaterialsStateData();
  }

  ApiService get _api => ref.read(apiServiceProvider);

  /// Load materials with current filters
  Future<void> loadMaterials() async {
    state = state.copyWith(
      loadingState: MaterialsLoadingState.loading,
      page: 1,
      hasMore: true,
      clearError: true,
    );

    try {
      final response = await _api.getMaterials(
        page: 1,
        limit: 20,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        categoryId: state.categoryId,
        lowStock: state.showLowStockOnly ? true : null,
        isActive: true,
      );

      state = state.copyWith(
        materials: response.materials,
        totalPages: response.totalPages,
        hasMore: 1 < response.totalPages,
        loadingState: MaterialsLoadingState.loaded,
      );
    } catch (e) {
      _log('loadMaterials error: $e');
      state = state.copyWith(
        error: e.toString(),
        loadingState: MaterialsLoadingState.error,
      );
    }
  }

  /// Load more materials (pagination)
  Future<void> loadMoreMaterials() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.page + 1;
      final response = await _api.getMaterials(
        page: nextPage,
        limit: 20,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        categoryId: state.categoryId,
        lowStock: state.showLowStockOnly ? true : null,
        isActive: true,
      );

      state = state.copyWith(
        materials: [...state.materials, ...response.materials],
        page: nextPage,
        totalPages: response.totalPages,
        hasMore: nextPage < response.totalPages,
        isLoadingMore: false,
      );
    } catch (e) {
      _log('loadMoreMaterials error: $e');
      state = state.copyWith(isLoadingMore: false);
    }
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
      state = state.copyWith(categories: response.flat);
    } catch (e) {
      _log('loadCategories error: $e');
    }
  }

  /// Load low stock materials
  Future<void> loadLowStockMaterials() async {
    try {
      final response = await _api.getLowStockMaterials();
      state = state.copyWith(lowStockMaterials: response.materials);
    } catch (e) {
      _log('loadLowStockMaterials error: $e');
    }
  }

  /// Find material by barcode
  Future<mat.Material?> findByBarcode(String barcode) async {
    try {
      return await _api.getMaterialByBarcode(barcode);
    } catch (e) {
      _log('findByBarcode error: $e');
      return null;
    }
  }

  /// Get material by ID
  Future<mat.Material?> getMaterial(String id) async {
    try {
      return await _api.getMaterial(id);
    } catch (e) {
      _log('getMaterial error: $e');
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
      _log('getStockMovements error: $e');
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
      final materials = List<mat.Material>.from(state.materials);
      final index = materials.indexWhere((m) => m.id == materialId);
      if (index != -1) {
        materials[index] = updated;
        state = state.copyWith(materials: materials);
      }

      // Reload low stock if needed
      await loadLowStockMaterials();

      return updated;
    } catch (e) {
      _log('adjustStock error: $e');
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
      final materials = List<mat.Material>.from(state.materials);
      final index = materials.indexWhere((m) => m.id == materialId);
      if (index != -1) {
        materials[index] = updated;
        state = state.copyWith(materials: materials);
      }

      return updated;
    } catch (e) {
      _log('reserveStock error: $e');
      rethrow;
    }
  }

  /// Set category filter
  void setCategory(String? categoryId) {
    if (state.categoryId == categoryId) return;
    if (categoryId == null) {
      state = state.copyWith(clearCategoryId: true);
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
    loadMaterials();
  }

  /// Set search query
  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    loadMaterials();
  }

  /// Set low stock filter
  void setLowStockFilter(bool enabled) {
    if (state.showLowStockOnly == enabled) return;
    state = state.copyWith(showLowStockOnly: enabled);
    loadMaterials();
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(
      clearCategoryId: true,
      searchQuery: '',
      showLowStockOnly: false,
    );
    loadMaterials();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state
  void reset() {
    state = const MaterialsStateData();
  }
}

/// Provider for Materials state
final materialsNotifierProvider =
    NotifierProvider<MaterialsNotifier, MaterialsStateData>(
  MaterialsNotifier.new,
);

// ============ Convenience Providers ============

/// Provider for materials list
final materialsListProvider = Provider<List<mat.Material>>((ref) {
  return ref.watch(materialsNotifierProvider).materials;
});

/// Provider for materials loading state
final materialsLoadingStateProvider = Provider<MaterialsLoadingState>((ref) {
  return ref.watch(materialsNotifierProvider).loadingState;
});

/// Provider for materials categories
final materialsCategoriesProvider = Provider<List<mat.MaterialCategory>>((ref) {
  return ref.watch(materialsNotifierProvider).categories;
});

/// Provider for low stock materials
final lowStockMaterialsProvider = Provider<List<mat.Material>>((ref) {
  return ref.watch(materialsNotifierProvider).lowStockMaterials;
});

/// Provider for low stock count
final lowStockCountProvider = Provider<int>((ref) {
  return ref.watch(materialsNotifierProvider).lowStockCount;
});

/// Provider for materials error
final materialsErrorProvider = Provider<String?>((ref) {
  return ref.watch(materialsNotifierProvider).error;
});

/// Provider for is materials loading
final isMaterialsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(materialsNotifierProvider).isLoading;
});

/// Provider for has more materials
final hasMoreMaterialsProvider = Provider<bool>((ref) {
  return ref.watch(materialsNotifierProvider).hasMore;
});

/// Provider for is loading more materials
final isLoadingMoreMaterialsProvider = Provider<bool>((ref) {
  return ref.watch(materialsNotifierProvider).isLoadingMore;
});
