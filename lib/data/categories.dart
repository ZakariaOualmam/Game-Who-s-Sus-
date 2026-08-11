/// A selectable word category. Words live in `assets/data/<id>/words.txt`.
class WordCategory {
  const WordCategory({
    required this.id,
    required this.name,
    required this.emoji,
    this.isRandom = false,
  });

  final String id;
  final String name;
  final String emoji;

  /// If true, the category picks from a random other category at runtime.
  final bool isRandom;

  String get assetPath => 'assets/data/$id/words.txt';
}

/// Registry of all categories. Add new categories here.
const List<WordCategory> categories = [
  WordCategory(id: 'food', name: 'Food', emoji: '🍕'),
  WordCategory(id: 'animals', name: 'Animals', emoji: '🐘'),
  WordCategory(id: 'sports', name: 'Sports', emoji: '⚽'),
  WordCategory(id: 'movies', name: 'Movies', emoji: '🎬'),
  WordCategory(id: 'places', name: 'Places', emoji: '🗺️'),
  WordCategory(id: 'jobs', name: 'Jobs', emoji: '💼'),
  WordCategory(id: 'objects', name: 'Objects', emoji: '📦'),
  WordCategory(id: 'games', name: 'Games', emoji: '🎲'),
  WordCategory(id: 'celebrities', name: 'Celebrities', emoji: '⭐'),
  WordCategory(id: 'random', name: 'Random', emoji: '🎰', isRandom: true),
];
