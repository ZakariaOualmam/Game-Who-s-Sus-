import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A single selectable language shown in the app's language picker.
class AppLanguage {
  const AppLanguage({
    required this.locale,
    required this.flag,
    required this.nativeName,
  });

  final Locale locale;
  final String flag;

  /// The language's name in its own language (never translated).
  final String nativeName;
}

/// Lightweight app-wide locale state.
///
/// The selected language is persisted locally and restored on startup. When
/// nothing was saved yet, the device language is used if supported, otherwise
/// English is the fallback. The [LocaleController] is a plain ChangeNotifier so
/// the whole app rebuilds with the new [locale] without restarting or losing
/// any in-progress game state.
class LocaleController extends ChangeNotifier {
  LocaleController._();

  /// App-wide shared controller.
  static final LocaleController instance = LocaleController._();

  static const String _prefKey = 'app_locale';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
    Locale('ary'),
  ];

  /// Languages exposed by the in-app picker, in display order.
  static const List<AppLanguage> languages = [
    AppLanguage(locale: Locale('en'), flag: '🇬🇧', nativeName: 'English'),
    AppLanguage(locale: Locale('fr'), flag: '🇫🇷', nativeName: 'Français'),
    AppLanguage(locale: Locale('ar'), flag: '🇲🇦', nativeName: 'العربية'),
    AppLanguage(locale: Locale('ary'), flag: '🇲🇦', nativeName: 'الدارجة'),
  ];

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool isSupported(Locale locale) =>
      supportedLocales.any((l) => l.languageCode == locale.languageCode);

  /// Restores the persisted locale, falling back to the device language when
  /// supported, and to English otherwise. Call once before runApp.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      final locale = Locale(saved);
      if (isSupported(locale)) {
        _setLocale(locale);
        return;
      }
    }
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    final resolved = isSupported(device) ? device : const Locale('en');
    _setLocale(resolved);
  }

  /// Persists and applies a new language immediately.
  Future<void> setLocale(Locale locale) async {
    if (!isSupported(locale) || locale == _locale) return;
    _setLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  void _setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  /// Test-only hook to reset state between tests.
  @visibleForTesting
  void resetForTesting() {
    _locale = const Locale('en');
    notifyListeners();
  }
}
