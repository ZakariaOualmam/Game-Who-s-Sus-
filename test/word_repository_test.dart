import 'dart:io';

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
}
