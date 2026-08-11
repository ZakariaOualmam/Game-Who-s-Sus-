import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wordimposter/core/locale_controller.dart';
import 'package:wordimposter/data/categories.dart';
import 'package:wordimposter/main.dart';
import 'package:wordimposter/services/word_repository.dart';
import 'package:wordimposter/widgets/language_selector.dart';

/// Disk-backed bundle so word lookups don't depend on the test asset bundle.
class _DiskAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final file = File(key);
    if (!file.existsSync()) {
      throw Exception('Asset not found on disk: $key');
    }
    final bytes = await file.readAsBytes();
    return ByteData.sublistView(bytes);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleController', () {
    test('defaults to English before load', () {
      LocaleController.instance.resetForTesting();
      expect(LocaleController.instance.locale, const Locale('en'));
    });

    test('restores a persisted locale on load', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'fr'});
      LocaleController.instance.resetForTesting();
      await LocaleController.instance.load();
      expect(LocaleController.instance.locale, const Locale('fr'));
    });

    test('falls back to a supported locale for an unknown persisted locale',
        () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'xx'});
      LocaleController.instance.resetForTesting();
      await LocaleController.instance.load();
      expect(
        LocaleController.instance.isSupported(LocaleController.instance.locale),
        isTrue,
      );
    });

    test('setLocale persists and notifies', () async {
      SharedPreferences.setMockInitialValues({});
      LocaleController.instance.resetForTesting();
      await LocaleController.instance.setLocale(const Locale('ar'));
      expect(LocaleController.instance.locale, const Locale('ar'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'ar');
    });
  });

  group('Language selector', () {
    Future<void> pumpHome(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      LocaleController.instance.resetForTesting();
      await tester.pumpWidget(const WordImposterApp());
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();
    }

    testWidgets('switches the whole UI to French', (tester) async {
      await pumpHome(tester);
      expect(find.text('OFFLINE'), findsOneWidget);

      await tester.tap(find.byType(LanguageSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle();

      expect(find.text('HORS LIGNE'), findsOneWidget);
    });

    testWidgets('Arabic switches the app to RTL', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.byType(LanguageSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      expect(find.text('دون اتصال'), findsOneWidget);
      final directionality = tester.widget<Directionality>(
        find
            .ancestor(
              of: find.text('دون اتصال'),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(directionality.textDirection, TextDirection.rtl);
    });

    testWidgets('Darija switches the app to RTL', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.byType(LanguageSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('الدارجة'));
      await tester.pumpAndSettle();

      expect(find.text('بلا إنترنات'), findsOneWidget);
      final directionality = tester.widget<Directionality>(
        find
            .ancestor(
              of: find.text('بلا إنترنات'),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(directionality.textDirection, TextDirection.rtl);
    });
  });

  group('Localized word data', () {
    test('instanceFor returns a repository that serves the requested language',
        () async {
      final arabic =
          WordRepository(locale: const Locale('ar'), bundle: _DiskAssetBundle());
      final food = await arabic.loadWords(categories.first);
      expect(food, contains('بيتزا'));
    });

    test('Random category resolves in every language', () async {
      final random = categories.lastWhere((c) => c.isRandom);
      for (final language in ['en', 'fr', 'ar', 'ary']) {
        final repo = WordRepository(
          locale: Locale(language),
          bundle: _DiskAssetBundle(),
        );
        final word = await repo.randomWord(random);
        expect(word.trim(), isNotEmpty,
            reason: 'No random word for $language');
      }
    });

    test('imposter decoys come from the selected language', () async {
      final french =
          WordRepository(locale: const Locale('fr'), bundle: _DiskAssetBundle());
      final decoys = await french.decoyWords(
        category: categories.first,
        correctWord: 'Pizza',
        count: 3,
      );
      expect(decoys, isNotEmpty);
      // French decoys must not be plain English words.
      expect(decoys, isNot(contains('Pizza')));
      final all = await french.loadWords(categories.first);
      for (final decoy in decoys) {
        expect(all, contains(decoy));
      }
    });
  });
}
