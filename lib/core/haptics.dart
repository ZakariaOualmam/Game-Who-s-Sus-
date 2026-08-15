import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Web-safe haptic feedback.
///
/// Desktop browsers have no vibration hardware and mobile browsers only allow
/// `navigator.vibrate` inside a user gesture, so haptics fired outside a tap
/// (e.g. the post-frame reveal/winner impacts) are silently blocked. Chrome
/// logs each block as an "[Intervention] Blocked call to navigator.vibrate"
/// warning, so these calls are skipped entirely on web. Android and iOS
/// behaviour is unchanged.
abstract final class Haptics {
  /// Whether haptics are currently supported. Exposed as a hook so tests can
  /// exercise both the web (unsupported) and native (supported) paths.
  @visibleForTesting
  static bool Function() isSupported = () => !kIsWeb;

  /// Light impact, e.g. a button press.
  static Future<void> lightImpact() =>
      isSupported() ? HapticFeedback.lightImpact() : Future<void>.value();

  /// Medium impact, e.g. a reveal or round end.
  static Future<void> mediumImpact() =>
      isSupported() ? HapticFeedback.mediumImpact() : Future<void>.value();

  /// Selection click, e.g. picking an option.
  static Future<void> selectionClick() =>
      isSupported() ? HapticFeedback.selectionClick() : Future<void>.value();
}
