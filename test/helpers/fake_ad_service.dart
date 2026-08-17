import 'package:who_sus/services/ad_service.dart';

/// Configurable fake [AdService] for tests.
///
/// Allows tests to simulate every ad lifecycle scenario (loaded, unavailable,
/// failed, dismissed, failed-to-show) without touching real AdMob APIs.
class FakeAdService implements AdService {
  int _roundsCompleted = 0;

  static const int _adFrequency = 2;

  /// When `true`, [showInterstitialIfAvailable] returns `true`.
  bool adReady = false;

  /// When `true`, [preloadInterstitial] sets [adReady] to `false` (simulates
  /// a load failure).
  bool loadShouldFail = false;

  /// When `true`, [showInterstitialIfAvailable] throws (simulates a show
  /// failure), then resets to `false`.
  bool showShouldThrow = false;

  /// How many times [showInterstitialIfAvailable] was called.
  int showCallCount = 0;

  /// How many times [preloadInterstitial] was called.
  int preloadCallCount = 0;

  /// Whether [resetForNewGame] was called.
  bool resetCalled = false;

  /// Whether [dispose] was called.
  bool disposeCalled = false;

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
    resetCalled = true;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────

  @override
  void preloadInterstitial() {
    preloadCallCount++;
    if (loadShouldFail) {
      adReady = false;
    }
  }

  @override
  Future<bool> showInterstitialIfAvailable() async {
    showCallCount++;

    if (showShouldThrow) {
      showShouldThrow = false;
      return false;
    }

    return adReady;
  }

  @override
  void dispose() {
    disposeCalled = true;
  }

  // ── Test helpers ───────────────────────────────────────────────────

  /// Manually set the rounds completed counter (for precise test control).
  void setRoundsCompleted(int count) {
    _roundsCompleted = count;
  }

  /// Read the current rounds completed counter.
  int get roundsCompleted => _roundsCompleted;
}
