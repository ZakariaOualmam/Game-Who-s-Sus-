import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleController.instance.load();
  runApp(const WordImposterApp());
}

class WordImposterApp extends StatefulWidget {
  const WordImposterApp({super.key});

  @override
  State<WordImposterApp> createState() => _WordImposterAppState();
}

class _WordImposterAppState extends State<WordImposterApp> {
  @override
  void initState() {
    super.initState();
    LocaleController.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleController.instance.locale;
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      locale: locale,
      supportedLocales: LocaleController.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        _AryMaterialLocalizationsDelegate(),
        _AryWidgetsLocalizationsDelegate(),
        _AryCupertinoLocalizationsDelegate(),
      ],
      home: const SplashScreen(),
    );
  }
}

/// Maps the unsupported Darija locale to Arabic for Flutter's global delegates
/// so the whole UI keeps Material/Widgets/Cupertino localizations (and RTL).
class _AryMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _AryMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ary';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(_AryMaterialLocalizationsDelegate old) => false;
}

class _AryWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _AryWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ary';

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(_AryWidgetsLocalizationsDelegate old) => false;
}

class _AryCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _AryCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ary';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(_AryCupertinoLocalizationsDelegate old) => false;
}
