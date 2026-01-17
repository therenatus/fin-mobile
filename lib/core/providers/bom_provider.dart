import 'package:flutter/foundation.dart';
import '../models/bom.dart';
import '../models/order_cost.dart';
import '../models/pricing_settings.dart';
import '../services/api_service.dart';

/// State enum for BOM operations
enum BomState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider for managing BOM (Bill of Materials) and costing
class BomProvider with ChangeNotifier {
  final ApiService _api;

  BomState _state = BomState.initial;
  Bom? _currentBom;
  List<BomVersion> _bomVersions = [];
  PricingSettings? _pricingSettings;
  String? _error;

  // Cache for order costs
  final Map<String, OrderCost> _orderCosts = {};

  BomProvider(this._api);

  // Getters
  BomState get state => _state;
  Bom? get currentBom => _currentBom;
  List<BomVersion> get bomVersions => _bomVersions;
  PricingSettings? get pricingSettings => _pricingSettings;
  String? get error => _error;
  bool get isLoading => _state == BomState.loading;
  bool get hasBom => _currentBom != null;

  // ==================== BOM METHODS ====================

  /// Load active BOM for model
  Future<Bom?> loadModelBom(String modelId) async {
    _state = BomState.loading;
    _error = null;
    notifyListeners();

    try {
      _currentBom = await _api.getModelBom(modelId);
      _state = BomState.loaded;
      notifyListeners();
      return _currentBom;
    } catch (e) {
      debugPrint('[BomProvider] loadModelBom error: $e');
      _error = e.toString();
      _state = BomState.error;
      notifyListeners();
      return null;
    }
  }

  /// Load BOM versions for model
  Future<void> loadBomVersions(String modelId) async {
    try {
      final response = await _api.getBomVersions(modelId);
      _bomVersions = response.versions;
      notifyListeners();
    } catch (e) {
      debugPrint('[BomProvider] loadBomVersions error: $e');
    }
  }

  /// Get BOM by ID
  Future<Bom?> getBom(String bomId) async {
    try {
      return await _api.getBom(bomId);
    } catch (e) {
      debugPrint('[BomProvider] getBom error: $e');
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
      _currentBom = bom;
      notifyListeners();
      return bom;
    } catch (e) {
      debugPrint('[BomProvider] createBom error: $e');
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
      _currentBom = bom;
      notifyListeners();
      return bom;
    } catch (e) {
      debugPrint('[BomProvider] updateBom error: $e');
      rethrow;
    }
  }

  /// Delete BOM
  Future<bool> deleteBom(String bomId) async {
    try {
      await _api.deleteBom(bomId);
      if (_currentBom?.id == bomId) {
        _currentBom = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[BomProvider] deleteBom error: $e');
      return false;
    }
  }

  /// Recalculate BOM costs
  Future<Bom?> recalculateBom(String bomId) async {
    try {
      final bom = await _api.recalculateBom(bomId);
      if (_currentBom?.id == bomId) {
        _currentBom = bom;
        notifyListeners();
      }
      return bom;
    } catch (e) {
      debugPrint('[BomProvider] recalculateBom error: $e');
      rethrow;
    }
  }

  /// Activate a specific BOM version
  Future<Bom?> activateBomVersion(String bomId) async {
    try {
      final bom = await _api.updateBom(bomId, isActive: true);
      _currentBom = bom;
      notifyListeners();
      return bom;
    } catch (e) {
      debugPrint('[BomProvider] activateBomVersion error: $e');
      rethrow;
    }
  }

  // ==================== ORDER COST METHODS ====================

  /// Get order cost (with caching)
  Future<OrderCost?> getOrderCost(String orderId, {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh && _orderCosts.containsKey(orderId)) {
      return _orderCosts[orderId];
    }

    try {
      final cost = await _api.getOrderCost(orderId);
      _orderCosts[orderId] = cost;
      return cost;
    } catch (e) {
      debugPrint('[BomProvider] getOrderCost error: $e');
      return null;
    }
  }

  /// Recalculate order cost
  Future<OrderCost?> recalculateOrderCost(String orderId) async {
    try {
      final cost = await _api.recalculateOrderCost(orderId);
      _orderCosts[orderId] = cost;
      notifyListeners();
      return cost;
    } catch (e) {
      debugPrint('[BomProvider] recalculateOrderCost error: $e');
      rethrow;
    }
  }

  /// Clear order cost cache
  void clearOrderCostCache([String? orderId]) {
    if (orderId != null) {
      _orderCosts.remove(orderId);
    } else {
      _orderCosts.clear();
    }
  }

  // ==================== PRICING SETTINGS METHODS ====================

  /// Load pricing settings
  Future<PricingSettings?> loadPricingSettings() async {
    try {
      _pricingSettings = await _api.getPricingSettings();
      notifyListeners();
      return _pricingSettings;
    } catch (e) {
      debugPrint('[BomProvider] loadPricingSettings error: $e');
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
      _pricingSettings = await _api.updatePricingSettings(
        defaultHourlyRate: defaultHourlyRate,
        overheadPct: overheadPct,
        defaultMarginPct: defaultMarginPct,
        roleRates: roleRates,
      );
      notifyListeners();
      return _pricingSettings;
    } catch (e) {
      debugPrint('[BomProvider] updatePricingSettings error: $e');
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
      debugPrint('[BomProvider] getPriceSuggestion error: $e');
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
      debugPrint('[BomProvider] getProfitabilityReport error: $e');
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
      debugPrint('[BomProvider] getVarianceReport error: $e');
      return null;
    }
  }

  // ==================== HELPERS ====================

  /// Clear current BOM
  void clearCurrentBom() {
    _currentBom = null;
    _bomVersions = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _state = BomState.initial;
    _currentBom = null;
    _bomVersions = [];
    _pricingSettings = null;
    _orderCosts.clear();
    _error = null;
    notifyListeners();
  }
}
