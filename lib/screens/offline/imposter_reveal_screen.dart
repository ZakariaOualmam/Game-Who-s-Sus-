import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import 'imposter_guess_screen.dart';

/// Dramatic reveal of who the imposter was and the secret word.
class ImposterRevealScreen extends StatelessWidget {
  const ImposterRevealScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  Widget build(BuildContext context) {
    final imposter = engine.imposter!;
    final caught = engine.isImposterCaught;

    return GameScaffold(
      title: 'IMPOSTER',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Text('😱', textAlign: TextAlign.center, style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'THE IMPOSTER WAS',
            textAlign: TextAlign.center,
            style: AppTypography.caption(context).copyWith(letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            imposter.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(context)
                .copyWith(fontSize: 52, color: AppColors.danger),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  'THE WORD WAS',
                  style: AppTypography.caption(context).copyWith(letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                Text(
                  engine.secretWord!,
                  textAlign: TextAlign.center,
                  style: AppTypography.word(context).copyWith(fontSize: 44),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            caught
                ? 'The crew caught the imposter!'
                : 'The imposter got away!',
            textAlign: TextAlign.center,
            style: AppTypography.bodyBold(context),
          ),
          const SizedBox(height: 36),
          GameButton(
            label: "IMPOSTER, TAKE YOUR GUESS",
            icon: Icons.emoji_objects,
            colors: AppColors.imposterGradient,
            onPressed: () => Navigator.of(context).pushReplacement(
              appRoute(ImposterGuessScreen(engine: engine)),
            ),
          ),
        ],
      ),
    );
  }
}
