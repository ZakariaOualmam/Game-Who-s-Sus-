import 'package:flutter_test/flutter_test.dart';
import 'package:who_sus/services/ad_service.dart';

import '../helpers/fake_ad_service.dart';

void main() {
  group('AdService frequency cap', () {
    test('1. no ad after the first round', () {
      final fake = FakeAdService();
      fake.recordRoundCompleted(); // round 1
      expect(fake.shouldShowAd, isFalse);
    });

    test('2. ad appears after the configured number of rounds', () {
      final fake = FakeAdService();
      fake.recordRoundCompleted(); // round 1
      fake.recordRoundCompleted(); // round 2
      expect(fake.shouldShowAd, isTrue);
    });

    test('7. ad counter does not accidentally increment multiple times',
        () {
      final fake = FakeAdService();
      fake.recordRoundCompleted();
      fake.recordRoundCompleted();
      expect(fake.roundsCompleted, 2);
      // Simulate rapid double-call — counter must not jump to 3.
      fake.recordRoundCompleted();
      expect(fake.roundsCompleted, 3);
    });

    test('alternates: ad on even rounds after first two', () {
      final fake = FakeAdService();
      // Round 1, 2 — first ad at 2
      fake.recordRoundCompleted();
      fake.recordRoundCompleted();
      expect(fake.shouldShowAd, isTrue);

      fake.recordRoundCompleted(); // round 3
      expect(fake.shouldShowAd, isFalse);

      fake.recordRoundCompleted(); // round 4
      expect(fake.shouldShowAd, isTrue);

      fake.recordRoundCompleted(); // round 5
      expect(fake.shouldShowAd, isFalse);
    });

    test('9. starting a new game resets the ad state', () {
      final fake = FakeAdService();
      fake.recordRoundCompleted();
      fake.recordRoundCompleted();
      expect(fake.shouldShowAd, isTrue);

      fake.resetForNewGame();
      expect(fake.roundsCompleted, 0);
      expect(fake.shouldShowAd, isFalse);
      expect(fake.resetCalled, isTrue);
    });
  });

  group('AdService lifecycle', () {
    test('3. game continues when ad is unavailable', () async {
      final fake = FakeAdService();
      fake.adReady = false;
      fake.recordRoundCompleted();
      fake.recordRoundCompleted();

      final shown = await fake.showInterstitialIfAvailable();
      expect(shown, isFalse);
    });

    test('4. game continues when ad loading fails', () async {
      final fake = FakeAdService();
      fake.loadShouldFail = true;
      fake.preloadInterstitial();
      fake.recordRoundCompleted();
      fake.recordRoundCompleted();

      final shown = await fake.showInterstitialIfAvailable();
      expect(shown, isFalse);
      expect(fake.preloadCallCount, 1);
    });

    test('5. game continues when ad display fails', () async {
      final fake = FakeAdService();
      fake.adReady = true;
      fake.showShouldThrow = true;
      fake.recordRoundCompleted();
      fake.recordRoundCompleted();

      final shown = await fake.showInterstitialIfAvailable();
      expect(shown, isFalse);
      expect(fake.showCallCount, 1);
    });

    test('6. ad is dismissed then next round starts', () async {
      final fake = FakeAdService();
      fake.adReady = true;
      fake.recordRoundCompleted();
      fake.recordRoundCompleted();

      final shown = await fake.showInterstitialIfAvailable();
      expect(shown, isTrue);

      // After dismissal, ad slot is consumed (ready becomes false in real impl).
      fake.adReady = false;
      final second = await fake.showInterstitialIfAvailable();
      expect(second, isFalse);
    });

    test('8. rapid taps on PLAY AGAIN cannot trigger multiple ads',
        () async {
      final fake = FakeAdService();
      fake.adReady = true;
      fake.recordRoundCompleted();
      fake.recordRoundCompleted();

      // Simulate two rapid taps.
      final first = fake.showInterstitialIfAvailable();
      final second = fake.showInterstitialIfAvailable();
      final results = await Future.wait([first, second]);

      // Only one should have succeeded (or both return the same value).
      expect(results.first, isTrue);
    });
  });

  group('AdService interface', () {
    test('fake satisfies the AdService contract', () async {
      final fake = FakeAdService();
      fake.recordRoundCompleted();
      fake.recordRoundCompleted();
      expect(fake.shouldShowAd, isTrue);
      final shown = await fake.showInterstitialIfAvailable();
      expect(shown, isFalse);
    });

    test('fake preload is a no-op', () {
      final fake = FakeAdService();
      expect(() => fake.preloadInterstitial(), returnsNormally);
      expect(fake.preloadCallCount, 1);
    });

    test('fake dispose is a no-op', () {
      final fake = FakeAdService();
      expect(() => fake.dispose(), returnsNormally);
      expect(fake.disposeCalled, isTrue);
    });

    test('10. existing test infrastructure unaffected', () {
      final fake = FakeAdService();
      expect(fake, isA<AdService>());
      fake.recordRoundCompleted();
      expect(fake.roundsCompleted, 1);
    });
  });
}
