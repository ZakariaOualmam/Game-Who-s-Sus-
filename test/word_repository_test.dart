import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wordimposter/data/categories.dart';
import 'package:wordimposter/services/word_repository.dart';

/// Serves the bundled word files straight from disk so repository tests don't
/// depend on the test runner's asset bundle (which only bundles fonts).
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

const supportedLanguages = ['en', 'fr', 'ar', 'ary'];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repo = WordRepository(bundle: _DiskAssetBundle());

  test('loadWords returns the bundled words for a category', () async {
    final words = await repo.loadWords(categories.first);
    expect(words, isNotEmpty);
    expect(words.length, greaterThan(20));
  });

  test('randomWord always picks a word from the category', () async {
    final category = categories.first;
    final all = await repo.loadWords(category);
    for (var i = 0; i < 20; i++) {
      final word = await repo.randomWord(category);
      expect(all, contains(word));
    }
  });

  test('decoyWords excludes the correct word and respects the count',
      () async {
    final category = categories.first;
    final correct = await repo.randomWord(category);
    final decoys = await repo.decoyWords(
      category: category,
      correctWord: correct,
      count: 3,
    );

    expect(decoys, isNotEmpty);
    expect(decoys.length, lessThanOrEqualTo(3));
    expect(decoys, isNot(contains(correct)));
    expect(decoys.toSet().length, decoys.length); // no duplicate decoys
    final all = await repo.loadWords(category);
    for (final decoy in decoys) {
      expect(all, contains(decoy));
    }
  });

  test('Random category resolves to a real word', () async {
    final random = categories.lastWhere((c) => c.isRandom);
    final word = await repo.randomWord(random);
    expect(word.trim(), isNotEmpty);
  });

  test('every language loads its own localized words', () async {
    for (final language in supportedLanguages) {
      final localized = WordRepository(
        locale: Locale(language),
        bundle: _DiskAssetBundle(),
      );
      for (final category in categories.where((c) => !c.isRandom)) {
        final words = await localized.loadWords(category);
        expect(words, isNotEmpty,
            reason: 'No words for $language/${category.id}');
        expect(words, isNot(contains('')),
            reason: 'Empty line leaked into $language/${category.id}');
      }
    }
  });

  test('localized words differ from English for real translations',
      () async {
    final enRepo = WordRepository(bundle: _DiskAssetBundle());
    final frRepo =
        WordRepository(locale: const Locale('fr'), bundle: _DiskAssetBundle());
    final enFood = await enRepo.loadWords(categories.first);
    final frFood = await frRepo.loadWords(categories.first);
    // Food is genuinely translated, so the lists must not be byte-identical.
    expect(frFood, isNot(equals(enFood)));
  });

  test('missing localized asset falls back to English', () async {
    final bundle = _FailingArabicBundle();
    final repo =
        WordRepository(locale: const Locale('ar'), bundle: bundle);
    final words = await repo.loadWords(categories.first);
    expect(words, isNotEmpty);
    // Fallback list matches the English words on disk.
    final expected = await WordRepository(bundle: _DiskAssetBundle())
        .loadWords(categories.first);
    expect(words, expected);
    expect(bundle.fallbackHappened, isTrue);
  });

  test('every language/category word asset is bundled via rootBundle',
      () async {
    // Regression guard: pubspec.yaml must declare every category directory for
    // every language. A missing/incorrect asset declaration silently breaks the
    // running app (rootBundle.loadString throws) while the disk-backed
    // repository tests still pass, leaving the category screen stuck.
    for (final language in supportedLanguages) {
      for (final category in categories.where((c) => !c.isRandom)) {
        final path = 'assets/data/$language/${category.id}/words.txt';
        final content = await rootBundle.loadString(path);
        final words = content
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
        expect(words, isNotEmpty, reason: 'No words bundled for $path');
      }
    }
  });
}

/// A bundle that fails on Arabic assets, forcing the English fallback.
class _FailingArabicBundle extends CachingAssetBundle {
  bool fallbackHappened = false;

  @override
  Future<ByteData> load(String key) async {
    if (key.contains('/ar/')) {
      fallbackHappened = true;
      throw Exception('Simulated missing Arabic asset: $key');
    }
    return _DiskAssetBundle().load(key);
  }
}
