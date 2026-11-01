import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service managing Google Play Billing and App Store in-app purchases,
/// subscriptions, restore flows, and user Pro entitlement state.
class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  InAppPurchase? _iapInstance;
  InAppPurchase get _iap => _iapInstance ??= InAppPurchase.instance;

  @visibleForTesting
  void setIapForTesting(InAppPurchase iap) {
    _iapInstance = iap;
  }

  // -------------------------------------------------------------
  // Product Identifiers (SKUs)
  // -------------------------------------------------------------
  static const String monthlySubscriptionId = 'spendvibe_pro_monthly';
  static const String lifetimeProductId = 'spendvibe_pro_lifetime';

  static const Set<String> allProductIds = {
    monthlySubscriptionId,
    lifetimeProductId,
  };

  static const String _prefIsProKey = 'key_spendvibe_is_pro_active';

  // -------------------------------------------------------------
  // Reactive State Notifiers
  // -------------------------------------------------------------
  final ValueNotifier<bool> isProNotifier = ValueNotifier<bool>(false);
  bool get isPro => isProNotifier.value;

  final ValueNotifier<bool> isLoadingProductsNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPurchaseInProgressNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<List<ProductDetails>> productsNotifier = ValueNotifier<List<ProductDetails>>([]);
  final ValueNotifier<String?> purchaseErrorNotifier = ValueNotifier<String?>(null);

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isInitialized = false;

  /// Initialize PurchaseService, load cached Pro state, and listen to purchase stream.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Load cached Pro state from SharedPreferences (offline-first support)
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPro = prefs.getBool(_prefIsProKey) ?? false;
      isProNotifier.value = cachedPro;
      debugPrint('[PurchaseService] Initial Pro status from cache: $cachedPro');
    } catch (e) {
      debugPrint('[PurchaseService] Failed to read cached Pro status: $e');
    }

    // 2. Listen to the purchase stream from Google Play Billing / App Store
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        debugPrint('[PurchaseService] Purchase stream error: $error');
        purchaseErrorNotifier.value = error.toString();
        isPurchaseInProgressNotifier.value = false;
      },
    );

    // 3. Preload available products if store is available
    await queryProducts();
  }

  /// Query Google Play / App Store for product information (pricing, description, currency)
  Future<void> queryProducts() async {
    try {
      isLoadingProductsNotifier.value = true;
      final bool isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        debugPrint('[PurchaseService] In-App Purchase store is not available.');
        isLoadingProductsNotifier.value = false;
        return;
      }

      final ProductDetailsResponse response = await _iap.queryProductDetails(allProductIds);
      if (response.error != null) {
        debugPrint('[PurchaseService] queryProductDetails error: ${response.error}');
        purchaseErrorNotifier.value = response.error!.message;
      }

      productsNotifier.value = response.productDetails;
      debugPrint('[PurchaseService] Loaded ${response.productDetails.length} products from store.');
    } catch (e) {
      debugPrint('[PurchaseService] Exception during queryProductDetails: $e');
    } finally {
      isLoadingProductsNotifier.value = false;
    }
  }

  /// Initiate a purchase for a selected product (Subscription or Non-Consumable Lifetime)
  Future<bool> buyProduct(ProductDetails product) async {
    try {
      isPurchaseInProgressNotifier.value = true;
      purchaseErrorNotifier.value = null;

      final bool isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        purchaseErrorNotifier.value = 'In-App Purchase store is not available on this device.';
        isPurchaseInProgressNotifier.value = false;
        return false;
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      // Both auto-renewing subscriptions and lifetime one-time products are non-consumable
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('[PurchaseService] buyProduct exception: $e');
      purchaseErrorNotifier.value = e.toString();
      isPurchaseInProgressNotifier.value = false;
      return false;
    }
  }

  /// Restore existing purchases (Mandatory for Google Play / App Store compliance)
  Future<void> restorePurchases() async {
    try {
      isPurchaseInProgressNotifier.value = true;
      purchaseErrorNotifier.value = null;

      final bool isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        purchaseErrorNotifier.value = 'In-App Purchase store is not available on this device.';
        isPurchaseInProgressNotifier.value = false;
        return;
      }

      await _iap.restorePurchases();
      debugPrint('[PurchaseService] restorePurchases requested successfully.');
    } catch (e) {
      debugPrint('[PurchaseService] restorePurchases exception: $e');
      purchaseErrorNotifier.value = e.toString();
    } finally {
      isPurchaseInProgressNotifier.value = false;
    }
  }

  /// Handle incoming purchase updates from the platform stream
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('[PurchaseService] Purchase update: ${purchaseDetails.productID} -> ${purchaseDetails.status}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          isPurchaseInProgressNotifier.value = true;
          break;

        case PurchaseStatus.error:
          isPurchaseInProgressNotifier.value = false;
          purchaseErrorNotifier.value = purchaseDetails.error?.message ?? 'Purchase failed.';
          debugPrint('[PurchaseService] Purchase error: ${purchaseDetails.error}');
          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          isPurchaseInProgressNotifier.value = false;
          if (allProductIds.contains(purchaseDetails.productID)) {
            await _setProStatus(true);
            debugPrint('[PurchaseService] Pro status unlocked for product: ${purchaseDetails.productID}');
          }
          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }
          break;

        case PurchaseStatus.canceled:
          isPurchaseInProgressNotifier.value = false;
          break;
      }
    }
  }

  /// Update and persist Pro entitlement state
  Future<void> _setProStatus(bool active) async {
    isProNotifier.value = active;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefIsProKey, active);
    } catch (e) {
      debugPrint('[PurchaseService] Failed to cache Pro status: $e');
    }
  }

  /// Developer / Debug helper to toggle Pro status during testing
  Future<void> debugSetProStatus(bool active) async {
    if (kDebugMode) {
      await _setProStatus(active);
      debugPrint('[PurchaseService] [DEBUG] Pro status manually set to $active');
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
  }
}
