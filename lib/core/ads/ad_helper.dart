import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralized configuration for Google AdMob IDs.
///
/// Automatically uses Google's verified test IDs during debug/profile builds
/// to protect your AdMob account from policy violations and invalid traffic bans.
/// Switches to production IDs seamlessly in release builds.
class AdHelper {
  AdHelper._();

  /// Whether the app is currently running in test mode.
  /// Defaults to `kDebugMode` (true when developing, false in production release).
  static bool get isTestMode => kDebugMode;

  /// AdMob Application ID (Android)
  static const String androidAppId = 'ca-app-pub-2836689955524655~8511785450';

  /// Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (isTestMode) {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; // Google iOS Test Banner
      }
      return 'ca-app-pub-3940256099942544/6300978111'; // Google Android Test Banner
    }

    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return 'ca-app-pub-2836689955524655/1107104972';
  }

  /// Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (isTestMode) {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910'; // Google iOS Test Interstitial
      }
      return 'ca-app-pub-3940256099942544/1033173712'; // Google Android Test Interstitial
    }

    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return 'ca-app-pub-2836689955524655/7362568319';
  }

  /// App Open Ad Unit ID
  static String get appOpenAdUnitId {
    if (isTestMode) {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/5575463023'; // Google iOS Test App Open
      }
      return 'ca-app-pub-3940256099942544/9257395921'; // Google Android Test App Open
    }

    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/5575463023';
    }
    return 'ca-app-pub-2836689955524655/2441414120';
  }

  /// Rewarded Ad Unit ID
  static String get rewardedAdUnitId {
    if (isTestMode) {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313'; // Google iOS Test Rewarded
      }
      return 'ca-app-pub-3940256099942544/5224354917'; // Google Android Test Rewarded
    }

    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return 'ca-app-pub-2836689955524655/1142763999';
  }

  /// Rewarded Interstitial Ad Unit ID
  static String get rewardedInterstitialAdUnitId {
    if (isTestMode) {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/6978759866'; // Google iOS Test Rewarded Interstitial
      }
      return 'ca-app-pub-3940256099942544/5354046379'; // Google Android Test Rewarded Interstitial
    }

    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/6978759866';
    }
    return 'ca-app-pub-2836689955524655/6359431652';
  }

  /// Native Rewarded Ad Unit ID
  static String get nativeRewardedAdUnitId {
    return 'ca-app-pub-2836689955524655/8867668787';
  }

  /// Production IDs map (for auditing / release inspection)
  static const Map<String, String> productionUnitIds = {
    'appId': androidAppId,
    'banner': 'ca-app-pub-2836689955524655/1107104972',
    'interstitial': 'ca-app-pub-2836689955524655/7362568319',
    'appOpen': 'ca-app-pub-2836689955524655/2441414120',
    'rewarded': 'ca-app-pub-2836689955524655/1142763999',
    'rewardedInterstitial': 'ca-app-pub-2836689955524655/6359431652',
    'nativeRewarded': 'ca-app-pub-2836689955524655/8867668787',
  };
}
