import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_service.dart';

/// Production AdMob IDs.
const String _prodAppId = 'ca-app-pub-3989726270562500~6761003941';
const String _prodInterstitialUnit = 'ca-app-pub-3989726270562500/2845859997';

/// Google test ad units for debug / profile builds.
const String _testAppId = 'ca-app-pub-3940256099942544~3347511713';
const String _testInterstitialUnit = 'ca-app-pub-3940256099942544/1033173712';

String get _appId => kReleaseMode ? _prodAppId : _testAppId;
String get _interstitialUnit => kReleaseMode ? _prodInterstitialUnit : _testInterstitialUnit;

/// Returns the AdMob App ID for the current build mode.
///
/// Used by platform launchers (AndroidManifest / Info.plist) at runtime.
String get admobAppId => _appId;

/// Returns the interstitial ad unit ID for the current build mode.
String get interstitialAdUnitId => _interstitialUnit;

/// Real AdMob interstitial implementation for Android and iOS.
AdService createAdService() => _MobileAdService();

class _MobileAdService implements AdService {
  int _roundsCompleted = 0;
  bool _disposed = false;
  bool _initialized = false;

  static const int _adFrequency = 2;

  InterstitialAd? _interstitial;
  bool _isLoading = false;

  // ── Frequency control ──────────────────────────────────────────────

  @override
  bool get shouldShowAd {
    if (_roundsCompleted < 2) return false;
    return _roundsCompleted % _adFrequency == 0;
  }

  @override
  void recordRoundCompleted() => _roundsCompleted++;

  @override
  void resetForNewGame() {
    _roundsCompleted = 0;
    _interstitial?.dispose();
    _interstitial = null;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────

  @override
  void preloadInterstitial() {
    if (_disposed || _isLoading || _interstitial != null) return;

    if (!_initialized) {
      _initialized = true;
      MobileAds.instance.initialize().then((_) => _loadAd());
    } else {
      _loadAd();
    }
  }

  void _loadAd() {
    if (_disposed || _isLoading || _interstitial != null) return;
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: _interstitialUnit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          if (_disposed) {
            ad.dispose();
            return;
          }
          _interstitial = ad;
          _setFullScreenCallback(ad);
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _interstitial = null;
        },
      ),
    );
  }

  void _setFullScreenCallback(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!_disposed) _interstitial = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!_disposed) _interstitial = null;
      },
      onAdShowedFullScreenContent: (_) {},
    );
  }

  @override
  Future<bool> showInterstitialIfAvailable() async {
    if (_disposed) return false;

    final ad = _interstitial;
    if (ad == null) return false;

    _interstitial = null;
    try {
      await ad.show();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _interstitial?.dispose();
    _interstitial = null;
  }
}
