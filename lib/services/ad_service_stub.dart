import 'ad_service.dart';

/// Web / fallback stub – no ads, no imports of google_mobile_ads.
AdService createAdService() => _StubAdService();

class _StubAdService implements AdService {
  int _roundsCompleted = 0;

  static const int _adFrequency = 2;

  @override
  void preloadInterstitial() {}

  @override
  Future<bool> showInterstitialIfAvailable() async => false;

  @override
  bool get shouldShowAd {
    if (_roundsCompleted < 2) return false;
    return _roundsCompleted % _adFrequency == 0;
  }

  @override
  void recordRoundCompleted() => _roundsCompleted++;

  @override
  void resetForNewGame() => _roundsCompleted = 0;

  @override
  void dispose() {}
}
