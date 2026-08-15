import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/core/haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final defaultIsSupported = Haptics.isSupported;
  final messenger = TestDefaultBinaryMessengerBinding.instance;
  final log = <MethodCall>[];

  setUp(() {
    log.clear();
    messenger.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        log.add(call);
        return null;
      },
    );
  });

  tearDown(() {
    messenger.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
    Haptics.isSupported = defaultIsSupported;
  });

  Future<void> expectPlatformVibrate(String type) async {
    expect(log, hasLength(1));
    expect(log.single.method, 'HapticFeedback.vibrate');
    expect(log.single.arguments, type);
  }

  group('Haptics on native platforms', () {
    test('lightImpact delegates to the platform channel', () async {
      Haptics.isSupported = () => true;
      await Haptics.lightImpact();
      await expectPlatformVibrate('HapticFeedbackType.lightImpact');
    });

    test('mediumImpact delegates to the platform channel', () async {
      Haptics.isSupported = () => true;
      await Haptics.mediumImpact();
      await expectPlatformVibrate('HapticFeedbackType.mediumImpact');
    });

    test('selectionClick delegates to the platform channel', () async {
      Haptics.isSupported = () => true;
      await Haptics.selectionClick();
      await expectPlatformVibrate('HapticFeedbackType.selectionClick');
    });
  });

  group('Haptics on web', () {
    test('skips every platform call', () async {
      Haptics.isSupported = () => false;
      await Haptics.lightImpact();
      await Haptics.mediumImpact();
      await Haptics.selectionClick();
      expect(log, isEmpty);
    });
  });
}
