import 'dart:math';

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

/// Loads and caches word lists bundled in `assets/data/<category>/words.txt`.
class WordRepository implements WordSource {
  WordRepository({List<WordCategory>? allCategories, AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle,
        _randomPool = List.unmodifiable(
          allCategories ?? categories.where((c) => !c.isRandom).toList(),
        );

  /// App-wide shared repository.
  static final WordRepository instance = WordRepository();

  final List<WordCategory> _randomPool;
  final AssetBundle _bundle;
  final Map<String, List<String>> _cache = {};

  @override
  Future<List<String>> loadWords(WordCategory category) async {
    if (category.isRandom) {
      final pick = _randomPool[Random().nextInt(_randomPool.length)];
      return _load(pick.assetPath);
    }
    return _load(category.assetPath);
  }

  Future<List<String>> _load(String path) async {
    final cached = _cache[path];
    if (cached != null) return cached;

    final content = await _bundle.loadString(path);
    final words = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
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
