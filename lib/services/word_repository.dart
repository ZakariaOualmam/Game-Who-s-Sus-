import 'dart:math';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../data/categories.dart';

/// Abstraction over where secret words come from.
///
/// Implemented by the local [WordRepository] today and by a remote source in
/// online mode later, keeping the game engine decoupled.
abstract class WordSource {
  Future<List<String>> loadWords(WordCategory category);
  Future<String> randomWord(WordCategory category);

  /// Up to [count] plausible alternative words from the same category, used
  /// as decoys for the imposter's multiple-choice guess.
  Future<List<String>> decoyWords({
    required WordCategory category,
    required String correctWord,
    required int count,
  });
}

/// Loads and caches word lists bundled in
/// `assets/data/<language>/<category>/words.txt`.
///
/// Each instance is tied to one [Locale] so words are always played in the
/// language the app is currently showing. The default English instance stays
/// available as [instance] for backward compatibility.
class WordRepository implements WordSource {
  WordRepository({
    Locale? locale,
    List<WordCategory>? allCategories,
    AssetBundle? bundle,
  })  : _languageCode = locale?.languageCode ?? 'en',
        _bundle = bundle ?? rootBundle,
        _randomPool = List.unmodifiable(
          allCategories ?? categories.where((c) => !c.isRandom).toList(),
        );

  /// App-wide shared repository (English).
  static final WordRepository instance = WordRepository();

  /// A repository for a specific language. Reuses the single shared instance
  /// when the language matches, otherwise creates a new cached repository.
  static final Map<String, WordRepository> _byLanguage = {'en': instance};

  static WordRepository instanceFor(Locale locale) {
    final code = locale.languageCode;
    return _byLanguage.putIfAbsent(code, () => WordRepository(locale: locale));
  }

  final String _languageCode;
  final List<WordCategory> _randomPool;
  final AssetBundle _bundle;
  final Map<String, List<String>> _cache = {};

  /// Public getter for the language code this repository serves.
  String get languageCode => _languageCode;

  @override
  Future<List<String>> loadWords(WordCategory category) async {
    if (category.isRandom) {
      // Random is a virtual category: pick a real one at runtime and load
      // words for it in the repository's language.
      final pick = _randomPool[Random().nextInt(_randomPool.length)];
      return _loadWithFallback(pick);
    }
    return _loadWithFallback(category);
  }

  String _pathFor(WordCategory category, {String? languageCode}) =>
      'assets/data/${languageCode ?? _languageCode}/${category.id}/words.txt';

  /// Loads a localized word list, falling back to English when the localized
  /// asset is genuinely missing. The fallback is intentional and logged.
  Future<List<String>> _loadWithFallback(WordCategory category) async {
    final localized = _pathFor(category);
    try {
      return await _load(localized);
    } on Exception catch (error) {
      if (_languageCode == 'en') rethrow;
      debugPrint(
        'WARNING: localized word asset missing for "$_languageCode": '
        '$localized ($error). Falling back to English.',
      );
      return _load(_pathFor(category, languageCode: 'en'));
    }
  }

  Future<List<String>> _load(String path) async {
    final cached = _cache[path];
    if (cached != null) return cached;

    debugPrint('Loading word asset: $path');
    final content = await _bundle.loadString(path);
    final words = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    debugPrint('Loaded ${words.length} words from $path');
    _cache[path] = words;
    return words;
  }

  @override
  Future<String> randomWord(WordCategory category) async {
    final words = await loadWords(category);
    if (words.isEmpty) {
      throw StateError('No words available for category "${category.name}".');
    }
    return words[Random().nextInt(words.length)];
  }

  @override
  Future<List<String>> decoyWords({
    required WordCategory category,
    required String correctWord,
    required int count,
  }) async {
    final words = await loadWords(category);
    final pool = words
        .where((w) => w.toLowerCase() != correctWord.toLowerCase())
        .toList()
      ..shuffle();
    if (pool.length <= count) return pool;
    return pool.take(count).toList();
  }
}
