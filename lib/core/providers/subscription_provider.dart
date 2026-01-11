import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/subscription.dart';
import '../services/api_service.dart';
import '../services/purchase_service.dart';

/// State enum for subscription operations
enum SubscriptionState {
  initial,
  loading,
  loaded,
  purchasing,
  error,
}

/// Provider for managing subscriptions and in-app purchases
class SubscriptionProvider with ChangeNotifier {
  final ApiService _api;
  late final PurchaseService _purchaseService;

  SubscriptionState _state = SubscriptionState.initial;
  ResourceUsage? _usage;
  List<SubscriptionPlan> _plans = [];
  String? _error;
  bool _isInitialized = false;

  SubscriptionProvider(this._api) {
    _purchaseService = PurchaseService();
    _setupPurchaseCallbacks();
  }

  // Getters
  SubscriptionState get state => _state;
  ResourceUsage? get usage => _usage;
  List<SubscriptionPlan> get plans => _plans;
  List<ProductDetails> get storeProducts => _purchaseService.products;
  String? get error => _error;
  bool get isLoading => _state == SubscriptionState.loading;
  bool get isPurchasing => _state == SubscriptionState.purchasing;
  bool get isStoreAvailable => _purchaseService.isAvailable;
  bool get isInitialized => _isInitialized;

  /// Current plan name
  String get currentPlanName => _usage?.planName ?? 'Free';

  /// Whether user has an active subscription
  bool get hasActiveSubscription => _usage?.isActive ?? false;

  /// Whether user is on trial
  bool get isTrial => _usage?.isTrial ?? false;

  /// Whether client limit is reached
  bool get isClientLimitReached => _usage?.isClientLimitReached ?? false;

  /// Whether employee limit is reached
  bool get isEmployeeLimitReached => _usage?.isEmployeeLimitReached ?? false;

  /// Setup callbacks for purchase events
  void _setupPurchaseCallbacks() {
    _purchaseService.onPurchaseSuccess = () {
      debugPrint('[SubscriptionProvider] Purchase successful');
      loadUsage();
      _state = SubscriptionState.loaded;
      _error = null;
      notifyListeners();
    };

    _purchaseService.onPurchaseError = (error) {
      debugPrint('[SubscriptionProvider] Purchase error: $error');
      _error = error;
      _state = SubscriptionState.error;
      notifyListeners();
    };

    _purchaseService.onPurchasePending = () {
      debugPrint('[SubscriptionProvider] Purchase pending');
      _state = SubscriptionState.purchasing;
      notifyListeners();
    };

    _purchaseService.onVerifyPurchase = _verifyPurchase;
  }

  /// Verify purchase with backend
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      if (Platform.isAndroid) {
        await _api.verifyGooglePlayPurchase(
          productId: purchase.productID,
          purchaseToken: purchase.verificationData.serverVerificationData,
        );
      } else if (Platform.isIOS) {
        await _api.verifyAppStorePurchase(
          receiptData: purchase.verificationData.serverVerificationData,
        );
      }
      return true;
    } catch (e) {
      debugPrint('[SubscriptionProvider] Verification error: $e');
      return false;
    }
  }

  /// Initialize the provider
  Future<void> init() async {
    if (_isInitialized) return;

    _state = SubscriptionState.loading;
    notifyListeners();

    try {
      // Load plans from backend
      _plans = await _api.getSubscriptionPlans();
      debugPrint('[SubscriptionProvider] Loaded ${_plans.length} plans');

      // Get product IDs for store
      final productIds = _plans
          .map((p) => Platform.isAndroid
              ? p.googlePlayProductId
              : p.appStoreProductId)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toList();

      debugPrint('[SubscriptionProvider] Product IDs: $productIds');

      // Initialize store
      await _purchaseService.init(productIds);

      // Load current usage
      await loadUsage();

      _isInitialized = true;
      _state = SubscriptionState.loaded;
    } catch (e) {
      debugPrint('[SubscriptionProvider] Init error: $e');
      _error = e.toString();
      _state = SubscriptionState.error;
    }

    notifyListeners();
  }

  /// Load current usage from backend
  Future<void> loadUsage() async {
    try {
      _usage = await _api.getResourceUsage();
      notifyListeners();
    } catch (e) {
      debugPrint('[SubscriptionProvider] Failed to load usage: $e');
    }
  }

  /// Purchase a subscription plan
  Future<void> purchase(SubscriptionPlan plan) async {
    final productId = Platform.isAndroid
        ? plan.googlePlayProductId
        : plan.appStoreProductId;

    if (productId == null || productId.isEmpty) {
      _error = 'Продукт недоступен для данной платформы';
      _state = SubscriptionState.error;
      notifyListeners();
      return;
    }

    final product = _purchaseService.getProduct(productId);
    if (product == null) {
      _error = 'Продукт не найден в магазине';
      _state = SubscriptionState.error;
      notifyListeners();
      return;
    }

    _state = SubscriptionState.purchasing;
    _error = null;
    notifyListeners();

    await _purchaseService.purchaseSubscription(product);
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    _state = SubscriptionState.loading;
    _error = null;
    notifyListeners();

    await _purchaseService.restorePurchases();
    await loadUsage();

    _state = SubscriptionState.loaded;
    notifyListeners();
  }

  /// Get store product for a plan
  ProductDetails? getStoreProduct(SubscriptionPlan plan) {
    final productId = Platform.isAndroid
        ? plan.googlePlayProductId
        : plan.appStoreProductId;

    if (productId == null || productId.isEmpty) return null;
    return _purchaseService.getProduct(productId);
  }

  /// Get formatted price for a plan
  String getPlanPrice(SubscriptionPlan plan) {
    final product = getStoreProduct(plan);
    if (product != null) {
      return product.price;
    }
    // Fallback to plan price
    return '${plan.price.toStringAsFixed(0)} ₽/мес';
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}
