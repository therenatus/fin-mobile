import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bom.dart';
import '../models/order_cost.dart';
import '../models/pricing_settings.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

void _log(String message) {
  debugPrint('[BomNotifier] $message');
}

/// State enum for BOM operations
enum BomLoadingState {
  initial,
  loading,
  loaded,
  error,
}

/// BOM state data
class BomStateData {
  final BomLoadingState loadingState;
  final Bom? currentBom;
  final List<BomVersion> bomVersions;
  final PricingSettings? pricingSettings;
  final String? error;
  final Map<String, OrderCost> orderCosts;

  const BomStateData({
    this.loadingState = BomLoadingState.initial,
    this.currentBom,
    this.bomVersions = const [],
    this.pricingSettings,
    this.error,
    this.orderCosts = const {},
  });

  bool get isLoading => loadingState == BomLoadingState.loading;
  bool get hasBom => currentBom != null;

  BomStateData copyWith({
    BomLoadingState? loadingState,
    Bom? currentBom,
    List<BomVersion>? bomVersions,
    PricingSettings? pricingSettings,
    String? error,
    Map<String, OrderCost>? orderCosts,
    bool clearCurrentBom = false,
    bool clearError = false,
    bool clearPricingSettings = false,
  }) {
    return BomStateData(
      loadingState: loadingState ?? this.loadingState,
      currentBom: clearCurrentBom ? null : (currentBom ?? this.currentBom),
      bomVersions: bomVersions ?? this.bomVersions,
      pricingSettings: clearPricingSettings ? null : (pricingSettings ?? this.pricingSettings),
      error: clearError ? null : (error ?? this.error),
      orderCosts: orderCosts ?? this.orderCosts,
    );
  }
}

/// BOM Notifier for managing BOM (Bill of Materials) and costing
class BomNotifier extends Notifier<BomStateData> {
  @override
  BomStateData build() {
    return const BomStateData();
  }

  ApiService get _api => ref.read(apiServiceProvider);

  // ==================== BOM METHODS ====================

  /// Load active BOM for model
  Future<Bom?> loadModelBom(String modelId) async {
    state = state.copyWith(
      loadingState: BomLoadingState.loading,
      clearError: true,
    );

    try {
      final bom = await _api.getModelBom(modelId);
      state = state.copyWith(
        currentBom: bom,
        loadingState: BomLoadingState.loaded,
      );
      return bom;
    } catch (e) {
      _log('loadModelBom error: $e');
      state = state.copyWith(
        error: e.toString(),
        loadingState: BomLoadingState.error,
      );
      return null;
    }
  }

  /// Load BOM versions for model
  Future<void> loadBomVersions(String modelId) async {
    try {
      final response = await _api.getBomVersions(modelId);
      state = state.copyWith(bomVersions: response.versions);
    } catch (e) {
      _log('loadBomVersions error: $e');
    }
  }

  /// Get BOM by ID
  Future<Bom?> getBom(String bomId) async {
    try {
      return await _api.getBom(bomId);
    } catch (e) {
      _log('getBom error: $e');
      return null;
    }
  }

  /// Create new BOM
  Future<Bom?> createBom({
    required String modelId,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> operations,
    String? notes,
  }) async {
    try {
      final bom = await _api.createBom(
        modelId: modelId,
        items: items,
        operations: operations,
        notes: notes,
      );
      state = state.copyWith(currentBom: bom);
      return bom;
    } catch (e) {
      _log('createBom error: $e');
      rethrow;
    }
  }

  /// Update existing BOM
  Future<Bom?> updateBom(
    String bomId, {
    List<Map<String, dynamic>>? items,
    List<Map<String, dynamic>>? operations,
    String? notes,
    bool? isActive,
  }) async {
    try {
      final bom = await _api.updateBom(
        bomId,
        items: items,
        operations: operations,
        notes: notes,
        isActive: isActive,
      );
      state = state.copyWith(currentBom: bom);
      return bom;
    } catch (e) {
      _log('updateBom error: $e');
      rethrow;
    }
  }

  /// Delete BOM
  Future<bool> deleteBom(String bomId) async {
    try {
      await _api.deleteBom(bomId);
      if (state.currentBom?.id == bomId) {
        state = state.copyWith(clearCurrentBom: true);
      }
      return true;
    } catch (e) {
      _log('deleteBom error: $e');
      return false;
    }
  }

  /// Recalculate BOM costs
  Future<Bom?> recalculateBom(String bomId) async {
    try {
      final bom = await _api.recalculateBom(bomId);
      if (state.currentBom?.id == bomId) {
        state = state.copyWith(currentBom: bom);
      }
      return bom;
    } catch (e) {
      _log('recalculateBom error: $e');
      rethrow;
    }
  }

  /// Activate a specific BOM version
  Future<Bom?> activateBomVersion(String bomId) async {
    try {
      final bom = await _api.updateBom(bomId, isActive: true);
      state = state.copyWith(currentBom: bom);
      return bom;
    } catch (e) {
      _log('activateBomVersion error: $e');
      rethrow;
    }
  }

  // ==================== ORDER COST METHODS ====================

  /// Get order cost (with caching)
  Future<OrderCost?> getOrderCost(String orderId, {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh && state.orderCosts.containsKey(orderId)) {
      return state.orderCosts[orderId];
    }

    try {
      final cost = await _api.getOrderCost(orderId);
      final newCosts = Map<String, OrderCost>.from(state.orderCosts);
      newCosts[orderId] = cost;
      state = state.copyWith(orderCosts: newCosts);
      return cost;
    } catch (e) {
      _log('getOrderCost error: $e');
      return null;
    }
  }

  /// Recalculate order cost
  Future<OrderCost?> recalculateOrderCost(String orderId) async {
    try {
      final cost = await _api.recalculateOrderCost(orderId);
      final newCosts = Map<String, OrderCost>.from(state.orderCosts);
      newCosts[orderId] = cost;
      state = state.copyWith(orderCosts: newCosts);
      return cost;
    } catch (e) {
      _log('recalculateOrderCost error: $e');
      rethrow;
    }
  }

  /// Clear order cost cache
  void clearOrderCostCache([String? orderId]) {
    if (orderId != null) {
      final newCosts = Map<String, OrderCost>.from(state.orderCosts);
      newCosts.remove(orderId);
      state = state.copyWith(orderCosts: newCosts);
    } else {
      state = state.copyWith(orderCosts: {});
    }
  }

  // ==================== PRICING SETTINGS METHODS ====================

  /// Load pricing settings
  Future<PricingSettings?> loadPricingSettings() async {
    try {
      final settings = await _api.getPricingSettings();
      state = state.copyWith(pricingSettings: settings);
      return settings;
    } catch (e) {
      _log('loadPricingSettings error: $e');
      return null;
    }
  }

  /// Update pricing settings
  Future<PricingSettings?> updatePricingSettings({
    double? defaultHourlyRate,
    double? overheadPct,
    double? defaultMarginPct,
    Map<String, double>? roleRates,
  }) async {
    try {
      final settings = await _api.updatePricingSettings(
        defaultHourlyRate: defaultHourlyRate,
        overheadPct: overheadPct,
        defaultMarginPct: defaultMarginPct,
        roleRates: roleRates,
      );
      state = state.copyWith(pricingSettings: settings);
      return settings;
    } catch (e) {
      _log('updatePricingSettings error: $e');
      rethrow;
    }
  }

  // ==================== PRICE SUGGESTION ====================

  /// Get price suggestion for model
  Future<PriceSuggestion?> getPriceSuggestion({
    required String modelId,
    required int quantity,
    double? marginPct,
  }) async {
    try {
      return await _api.getPriceSuggestion(
        modelId: modelId,
        quantity: quantity,
        marginPct: marginPct,
      );
    } catch (e) {
      _log('getPriceSuggestion error: $e');
      return null;
    }
  }

  // ==================== REPORTS ====================

  /// Get profitability report
  Future<ProfitabilityReport?> getProfitabilityReport({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _api.getProfitabilityReport(
        period: period,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _log('getProfitabilityReport error: $e');
      return null;
    }
  }

  /// Get variance report
  Future<VarianceReport?> getVarianceReport({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _api.getVarianceReport(
        period: period,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _log('getVarianceReport error: $e');
      return null;
    }
  }

  // ==================== HELPERS ====================

  /// Clear current BOM
  void clearCurrentBom() {
    state = state.copyWith(
      clearCurrentBom: true,
      bomVersions: [],
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state
  void reset() {
    state = const BomStateData();
  }
}

/// Provider for BOM state
final bomNotifierProvider = NotifierProvider<BomNotifier, BomStateData>(
  BomNotifier.new,
);

// ============ Convenience Providers ============

/// Provider for current BOM
final currentBomProvider = Provider<Bom?>((ref) {
  return ref.watch(bomNotifierProvider).currentBom;
});

/// Provider for BOM loading state
final bomLoadingStateProvider = Provider<BomLoadingState>((ref) {
  return ref.watch(bomNotifierProvider).loadingState;
});

/// Provider for BOM versions
final bomVersionsProvider = Provider<List<BomVersion>>((ref) {
  return ref.watch(bomNotifierProvider).bomVersions;
});

/// Provider for pricing settings
final pricingSettingsProvider = Provider<PricingSettings?>((ref) {
  return ref.watch(bomNotifierProvider).pricingSettings;
});

/// Provider for BOM error
final bomErrorProvider = Provider<String?>((ref) {
  return ref.watch(bomNotifierProvider).error;
});

/// Provider for BOM is loading
final isBomLoadingProvider = Provider<bool>((ref) {
  return ref.watch(bomNotifierProvider).isLoading;
});
