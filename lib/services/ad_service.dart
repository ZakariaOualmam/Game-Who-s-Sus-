import 'ad_service_stub.dart'
    if (dart.library.io) 'ad_service_mobile.dart' as platform;

/// Abstract interstitial ad service.
///
/// Handles ad lifecycle (preload / show / dispose) and frequency control.
/// On Web the service is a silent no-op; on mobile it uses Google AdMob.
abstract class AdService {
  /// Creates the platform-appropriate implementation.
  factory AdService() => platform.createAdService();

  /// The app-wide ad service. Tests can replace this with a fake.
  static AdService instance = AdService();

  /// Preload the next interstitial in the background.
  void preloadInterstitial();

  /// Show the interstitial if it is ready and the frequency cap allows it.
  ///
  /// Returns `true` if an ad was actually displayed, `false` otherwise.
  /// Never throws; failures are swallowed.
  Future<bool> showInterstitialIfAvailable();

  /// Whether the frequency cap says an ad should be shown now.
  bool get shouldShowAd;

  /// Record that a round has completed (may increment the internal counter).
  void recordRoundCompleted();

  /// Reset the round counter for a brand-new game session.
  void resetForNewGame();

  /// Release native resources.
  void dispose();
}
