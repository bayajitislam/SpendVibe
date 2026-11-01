import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../purchases/purchase_service.dart';
import 'ad_helper.dart';

/// Singleton service managing AdMob SDK initialization, caching, and display
/// of Interstitial and App Open ads with smart frequency capping.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // -------------------------------------------------------------
  // Interstitial Ad Management
  // -------------------------------------------------------------
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  int _transactionActionCount = 0;

  // -------------------------------------------------------------
  // App Open Ad Management
  // -------------------------------------------------------------
  AppOpenAd? _appOpenAd;
  bool _isAppOpenLoading = false;
  DateTime? _appOpenLoadTime;
  DateTime? _lastAppOpenShowTime;
  bool _isShowingAd = false;

  /// Cooldown between App Open Ads to avoid user annoyance (10 minutes)
  static const Duration _appOpenCooldown = Duration(minutes: 10);

  /// App Open ad expiration threshold as per Google AdMob guidelines (4 hours)
  static const Duration _maxAdAge = Duration(hours: 4);

  /// Initialize MobileAds SDK and preload initial ads
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('[AdService] Google Mobile Ads SDK initialized successfully (TestMode: ${AdHelper.isTestMode}).');

      // Listen for Pro status changes to clear cached ads
      PurchaseService.instance.isProNotifier.addListener(() {
        if (PurchaseService.instance.isPro) {
          debugPrint('[AdService] User is Pro. Disposing all preloaded ads.');
          _interstitialAd?.dispose();
          _interstitialAd = null;
          _appOpenAd?.dispose();
          _appOpenAd = null;
        }
      });

      // Preload initial ads only if not Pro
      if (!PurchaseService.instance.isPro) {
        loadInterstitialAd();
        loadAppOpenAd();
      }
    } catch (e) {
      debugPrint('[AdService] Failed to initialize Google Mobile Ads SDK: $e');
    }
  }

  // =============================================================
  // Interstitial Ad Logic
  // =============================================================

  /// Preload an Interstitial Ad into memory
  void loadInterstitialAd() {
    if (PurchaseService.instance.isPro || !_isInitialized || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }

    final adUnitId = AdHelper.interstitialAdUnitId;
    if (adUnitId.isEmpty) return;

    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('[AdService] Interstitial Ad loaded successfully.');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('[AdService] Interstitial failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Interstitial Ad failed to load: $error');
          _isInterstitialLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Triggered after user adds a transaction.
  /// Shows an interstitial ad once every [everyNTransactions] transactions (default: 3).
  void onTransactionAdded({int everyNTransactions = 3}) {
    if (PurchaseService.instance.isPro) return;

    _transactionActionCount++;
    debugPrint('[AdService] Transaction added count: $_transactionActionCount');

    if (_transactionActionCount >= everyNTransactions) {
      _transactionActionCount = 0;
      showInterstitialAd();
    }
  }

  int get transactionActionCount => _transactionActionCount;
  bool get isInterstitialLoaded => !PurchaseService.instance.isPro && _interstitialAd != null;

  /// Show cached Interstitial Ad if available. Returns true if shown.
  bool showInterstitialAd() {
    if (PurchaseService.instance.isPro) return false;

    if (_interstitialAd != null) {
      _interstitialAd!.show();
      return true;
    } else {
      debugPrint('[AdService] Interstitial Ad was requested but not ready.');
      loadInterstitialAd();
      return false;
    }
  }

  // =============================================================
  // App Open Ad Logic
  // =============================================================

  /// Preload an App Open Ad
  void loadAppOpenAd() {
    if (PurchaseService.instance.isPro || !_isInitialized || _isAppOpenLoading || isAppOpenAdAvailable) {
      return;
    }

    final adUnitId = AdHelper.appOpenAdUnitId;
    if (adUnitId.isEmpty) return;

    _isAppOpenLoading = true;

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          _isAppOpenLoading = false;
          debugPrint('[AdService] App Open Ad loaded successfully.');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _isShowingAd = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              _isShowingAd = false;
              ad.dispose();
              _appOpenAd = null;
              loadAppOpenAd(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('[AdService] App Open Ad failed to show: $error');
              _isShowingAd = false;
              ad.dispose();
              _appOpenAd = null;
              loadAppOpenAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] App Open Ad failed to load: $error');
          _isAppOpenLoading = false;
          _appOpenAd = null;
        },
      ),
    );
  }

  /// Whether a valid, non-expired App Open Ad is currently loaded
  bool get isAppOpenAdAvailable {
    return !PurchaseService.instance.isPro &&
        _appOpenAd != null &&
        _appOpenLoadTime != null &&
        DateTime.now().difference(_appOpenLoadTime!) < _maxAdAge;
  }

  /// Show App Open Ad if available.
  /// Set [ignoreCooldown] to true for manual testing.
  bool showAppOpenAdIfAvailable({bool ignoreCooldown = false}) {
    if (PurchaseService.instance.isPro || !_isInitialized || _isShowingAd) {
      return false;
    }

    // Check cooldown
    if (!ignoreCooldown &&
        _lastAppOpenShowTime != null &&
        DateTime.now().difference(_lastAppOpenShowTime!) < _appOpenCooldown) {
      debugPrint('[AdService] App Open Ad skipped due to active cooldown.');
      return false;
    }

    if (isAppOpenAdAvailable) {
      _lastAppOpenShowTime = DateTime.now();
      _appOpenAd!.show();
      return true;
    } else {
      loadAppOpenAd();
      return false;
    }
  }

  /// Clean up resources
  void dispose() {
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
  }
}
