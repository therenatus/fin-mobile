import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Callback types for purchase events
typedef OnPurchaseSuccess = void Function();
typedef OnPurchaseError = void Function(String error);
typedef OnPurchasePending = void Function();
typedef OnPurchaseVerify = Future<bool> Function(PurchaseDetails purchase);

/// Service for handling In-App Purchases
class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  // Callbacks
  OnPurchaseSuccess? onPurchaseSuccess;
  OnPurchaseError? onPurchaseError;
  OnPurchasePending? onPurchasePending;
  OnPurchaseVerify? onVerifyPurchase;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  /// Initialize the purchase service
  Future<void> init(List<String> productIds) async {
    _isAvailable = await _iap.isAvailable();

    if (!_isAvailable) {
      debugPrint('[PurchaseService] Store not available');
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () {
        debugPrint('[PurchaseService] Purchase stream closed');
      },
      onError: (error) {
        debugPrint('[PurchaseService] Purchase stream error: $error');
      },
    );

    // Load products
    if (productIds.isNotEmpty) {
      await loadProducts(productIds);
    }
  }

  /// Load products from store
  Future<void> loadProducts(List<String> productIds) async {
    if (!_isAvailable) return;

    final response = await _iap.queryProductDetails(productIds.toSet());

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
          '[PurchaseService] Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      debugPrint(
          '[PurchaseService] Query products error: ${response.error!.message}');
    }

    _products = response.productDetails;
    debugPrint('[PurchaseService] Loaded ${_products.length} products');

    // Sort products by price
    _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
  }

  /// Get product by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Purchase a subscription
  Future<bool> purchaseSubscription(ProductDetails product) async {
    if (!_isAvailable) {
      onPurchaseError?.call('Магазин недоступен');
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      // Use buyNonConsumable for subscriptions
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('[PurchaseService] Purchase error: $e');
      onPurchaseError?.call(e.toString());
      return false;
    }
  }

  /// Handle purchase updates from stream
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint(
          '[PurchaseService] Purchase update: ${purchase.productID}, status: ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          onPurchasePending?.call();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final verified = await _verifyPurchase(purchase);
          if (verified) {
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
            onPurchaseSuccess?.call();
          } else {
            onPurchaseError?.call('Верификация покупки не прошла');
          }
          break;

        case PurchaseStatus.error:
          final errorMessage =
              purchase.error?.message ?? 'Ошибка при покупке';
          debugPrint('[PurchaseService] Purchase error: $errorMessage');
          onPurchaseError?.call(errorMessage);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.canceled:
          debugPrint('[PurchaseService] Purchase canceled');
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
      }
    }
  }

  /// Verify purchase with backend
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    if (onVerifyPurchase != null) {
      return await onVerifyPurchase!(purchase);
    }
    // If no verification callback is set, assume valid
    return true;
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      onPurchaseError?.call('Магазин недоступен');
      return;
    }

    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('[PurchaseService] Restore error: $e');
      onPurchaseError?.call('Ошибка восстановления покупок');
    }
  }

  /// Get platform-specific product ID
  String? getPlatformProductId({
    String? googlePlayProductId,
    String? appStoreProductId,
  }) {
    if (Platform.isAndroid) {
      return googlePlayProductId;
    } else if (Platform.isIOS) {
      return appStoreProductId;
    }
    return null;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
