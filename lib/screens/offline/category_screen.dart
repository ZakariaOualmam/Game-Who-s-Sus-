import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/categories.dart';
import '../../game/game_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_localizations.dart';
import '../../services/word_repository.dart';
import '../../widgets/game_scaffold.dart';
import 'role_reveal_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _loading = false;

  Future<void> _select(WordCategory category) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      debugPrint('============ CATEGORY SELECTION DEBUG ============');
      debugPrint('Selected category: "${category.id}" (${category.name})');
      debugPrint('Engine wordSource type: ${widget.engine.wordSource.runtimeType}');
      if (widget.engine.wordSource is WordRepository) {
        final repo = widget.engine.wordSource as WordRepository;
        debugPrint('WordRepository language code: ${repo.languageCode}');
      }
      debugPrint('Starting round for category "${category.id}"');
      await widget.engine.startRound(category);
      debugPrint('Round started successfully, secretWord: ${widget.engine.secretWord}');
      debugPrint('==================================================');
    } catch (error, stackTrace) {
      debugPrint('============ CATEGORY SELECTION ERROR ============');
      debugPrint('Failed to start round for category "${category.id}"');
      debugPrint('Error: $error');
      debugPrint('Stack trace:');
      debugPrint(stackTrace.toString());
      debugPrint('==================================================');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotLoadCategories),
            action: SnackBarAction(
              label: l10n.tryAgain.toUpperCase(),
              onPressed: () => _select(category),
            ),
          ),
        );
      return;
    }
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      appRoute(RoleRevealScreen(engine: widget.engine)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GameScaffold(
      title: l10n.categoryTitle.toUpperCase(),
      onBack: () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.pickWordCategory, style: AppTypography.title(context)),
          const SizedBox(height: 20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                for (final category in categories)
                  _CategoryCard(
                    category: category,
                    onTap: () => _select(category),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final WordCategory category;
  final VoidCallback onTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surface, AppColors.surfaceHigh],
            ),
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 42)),
              const SizedBox(height: 10),
              Text(l10n.categoryName(category), style: AppTypography.title(context)),
            ],
          ),
        ),
      ),
    );
  }
}
