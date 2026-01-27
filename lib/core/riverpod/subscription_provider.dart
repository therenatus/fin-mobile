import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/subscription.dart';
import '../services/api_service.dart';
import '../services/purchase_service.dart';
import 'api_provider.dart';

void _log(String message) {
  debugPrint('[SubscriptionNotifier] $message');
}

/// State enum for subscription operations
enum SubscriptionLoadingState {
  initial,
  loading,
  loaded,
  purchasing,
  error,
}

/// Subscription state data
class SubscriptionStateData {
  final SubscriptionLoadingState loadingState;
  final ResourceUsage? usage;
  final List<SubscriptionPlan> plans;
  final String? error;
  final bool isInitialized;

  const SubscriptionStateData({
    this.loadingState = SubscriptionLoadingState.initial,
    this.usage,
    this.plans = const [],
    this.error,
    this.isInitialized = false,
  });

  bool get isLoading => loadingState == SubscriptionLoadingState.loading;
  bool get isPurchasing => loadingState == SubscriptionLoadingState.purchasing;

  /// Current plan name
  String get currentPlanName => usage?.planName ?? 'Free';

  /// Whether user has an active subscription
  bool get hasActiveSubscription => usage?.isActive ?? false;

  /// Whether user is on trial
  bool get isTrial => usage?.isTrial ?? false;

  /// Whether client limit is reached
  bool get isClientLimitReached => usage?.isClientLimitReached ?? false;

  /// Whether employee limit is reached
  bool get isEmployeeLimitReached => usage?.isEmployeeLimitReached ?? false;

  SubscriptionStateData copyWith({
    SubscriptionLoadingState? loadingState,
    ResourceUsage? usage,
    List<SubscriptionPlan>? plans,
    String? error,
    bool? isInitialized,
    bool clearError = false,
    bool clearUsage = false,
  }) {
    return SubscriptionStateData(
      loadingState: loadingState ?? this.loadingState,
      usage: clearUsage ? null : (usage ?? this.usage),
      plans: plans ?? this.plans,
      error: clearError ? null : (error ?? this.error),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Subscription Notifier for managing subscriptions and in-app purchases
class SubscriptionNotifier extends Notifier<SubscriptionStateData> {
  late final PurchaseService _purchaseService;

  @override
  SubscriptionStateData build() {
    _purchaseService = PurchaseService();
    _setupPurchaseCallbacks();

    // Cleanup on dispose
    ref.onDispose(() {
      _purchaseService.dispose();
    });

    return const SubscriptionStateData();
  }

  ApiService get _api => ref.read(apiServiceProvider);

  /// Store products from purchase service
  List<ProductDetails> get storeProducts => _purchaseService.products;

  /// Whether store is available
  bool get isStoreAvailable => _purchaseService.isAvailable;

  /// Setup callbacks for purchase events
  void _setupPurchaseCallbacks() {
    _purchaseService.onPurchaseSuccess = () {
      _log('Purchase successful');
      loadUsage();
      state = state.copyWith(
        loadingState: SubscriptionLoadingState.loaded,
        clearError: true,
      );
    };

    _purchaseService.onPurchaseError = (error) {
      _log('Purchase error: $error');
      state = state.copyWith(
        error: error,
        loadingState: SubscriptionLoadingState.error,
      );
    };

    _purchaseService.onPurchasePending = () {
      _log('Purchase pending');
      state = state.copyWith(
        loadingState: SubscriptionLoadingState.purchasing,
      );
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
      _log('Verification error: $e');
      return false;
    }
  }

  /// Initialize the provider
  Future<void> init() async {
    if (state.isInitialized) return;

    state = state.copyWith(loadingState: SubscriptionLoadingState.loading);

    try {
      // Load plans from backend
      final plans = await _api.getSubscriptionPlans();
      _log('Loaded ${plans.length} plans');

      // Get product IDs for store
      final productIds = plans
          .map((p) => Platform.isAndroid
              ? p.googlePlayProductId
              : p.appStoreProductId)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toList();

      _log('Product IDs: $productIds');

      // Initialize store
      await _purchaseService.init(productIds);

      // Load current usage
      final usage = await _api.getResourceUsage();

      state = state.copyWith(
        plans: plans,
        usage: usage,
        isInitialized: true,
        loadingState: SubscriptionLoadingState.loaded,
      );
    } catch (e) {
      _log('Init error: $e');
      state = state.copyWith(
        error: e.toString(),
        loadingState: SubscriptionLoadingState.error,
      );
    }
  }

  /// Load current usage from backend
  Future<void> loadUsage() async {
    try {
      final usage = await _api.getResourceUsage();
      state = state.copyWith(usage: usage);
    } catch (e) {
      _log('Failed to load usage: $e');
    }
  }

  /// Purchase a subscription plan
  Future<void> purchase(SubscriptionPlan plan) async {
    final productId = Platform.isAndroid
        ? plan.googlePlayProductId
        : plan.appStoreProductId;

    if (productId == null || productId.isEmpty) {
      state = state.copyWith(
        error: 'Продукт недоступен для данной платформы',
        loadingState: SubscriptionLoadingState.error,
      );
      return;
    }

    final product = _purchaseService.getProduct(productId);
    if (product == null) {
      state = state.copyWith(
        error: 'Продукт не найден в магазине',
        loadingState: SubscriptionLoadingState.error,
      );
      return;
    }

    state = state.copyWith(
      loadingState: SubscriptionLoadingState.purchasing,
      clearError: true,
    );

    await _purchaseService.purchaseSubscription(product);
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    state = state.copyWith(
      loadingState: SubscriptionLoadingState.loading,
      clearError: true,
    );

    await _purchaseService.restorePurchases();
    await loadUsage();

    state = state.copyWith(loadingState: SubscriptionLoadingState.loaded);
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
    return '${plan.price.toStringAsFixed(0)} сом/мес';
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state
  void reset() {
    state = const SubscriptionStateData();
  }
}

/// Provider for Subscription state
final subscriptionNotifierProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionStateData>(
  SubscriptionNotifier.new,
);

// ============ Convenience Providers ============

/// Provider for subscription loading state
final subscriptionLoadingStateProvider = Provider<SubscriptionLoadingState>((ref) {
  return ref.watch(subscriptionNotifierProvider).loadingState;
});

/// Provider for resource usage
final resourceUsageProvider = Provider<ResourceUsage?>((ref) {
  return ref.watch(subscriptionNotifierProvider).usage;
});

/// Provider for subscription plans
final subscriptionPlansProvider = Provider<List<SubscriptionPlan>>((ref) {
  return ref.watch(subscriptionNotifierProvider).plans;
});

/// Provider for subscription error
final subscriptionErrorProvider = Provider<String?>((ref) {
  return ref.watch(subscriptionNotifierProvider).error;
});

/// Provider for is subscription loading
final isSubscriptionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionNotifierProvider).isLoading;
});

/// Provider for is purchasing
final isPurchasingProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionNotifierProvider).isPurchasing;
});

/// Provider for current plan name
final currentPlanNameProvider = Provider<String>((ref) {
  return ref.watch(subscriptionNotifierProvider).currentPlanName;
});

/// Provider for has active subscription
final hasActiveSubscriptionProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionNotifierProvider).hasActiveSubscription;
});

/// Provider for is client limit reached
final isClientLimitReachedProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionNotifierProvider).isClientLimitReached;
});

/// Provider for is employee limit reached
final isEmployeeLimitReachedProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionNotifierProvider).isEmployeeLimitReached;
});
