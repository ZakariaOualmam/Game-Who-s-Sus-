import '../data/categories.dart';
import 'app_localizations.dart';

/// Resolves the localized display name for a [WordCategory].
extension CategoryLocalizations on AppLocalizations {
  String categoryName(WordCategory category) {
    if (category.isRandom) return categoryRandom;
    switch (category.id) {
      case 'food':
        return categoryFood;
      case 'animals':
        return categoryAnimals;
      case 'sports':
        return categorySports;
      case 'movies':
        return categoryMovies;
      case 'places':
        return categoryPlaces;
      case 'jobs':
        return categoryJobs;
      case 'objects':
        return categoryObjects;
      case 'games':
        return categoryGames;
      case 'celebrities':
        return categoryCelebrities;
      default:
        return category.name;
    }
  }
}
