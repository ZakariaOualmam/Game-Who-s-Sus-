import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../models/round_result.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import 'scoreboard_screen.dart';

/// Announces the round winner and points awarded.
class WinnerScreen extends StatelessWidget {
  const WinnerScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  Widget build(BuildContext context) {
    final result = engine.lastRound!;
    final isCrewWin = result.crewWins;
    final crewEarned = result.scoreChanges.values.isEmpty
        ? 0
        : result.scoreChanges.values.first;

    return GameScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Text(
            isCrewWin ? '🏆' : '🕶️',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 20),
          Text(
            isCrewWin ? 'CREW WINS!' : 'IMPOSTER WINS!',
            textAlign: TextAlign.center,
            style: AppTypography.display(context).copyWith(
              fontSize: 54,
              color: isCrewWin ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _subtitle(result),
            textAlign: TextAlign.center,
            style: AppTypography.body(context),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              isCrewWin
                  ? 'Every crew member +$crewEarned'
                  : 'Imposter +${result.scoreChanges[result.imposter.id] ?? 0}',
              textAlign: TextAlign.center,
              style: AppTypography.title(context),
            ),
          ),
          const SizedBox(height: 44),
          GameButton(
            label: 'SEE SCOREBOARD',
            icon: Icons.leaderboard,
            onPressed: () => Navigator.of(context).pushReplacement(
              appRoute(ScoreboardScreen(engine: engine)),
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle(RoundResult result) {
    if (result.crewWins) {
      return result.guessedCorrectly
          ? 'The imposter almost made it… but the crew caught them!'
          : 'The imposter was caught and missed the word!';
    }
    if (result.guessedCorrectly) {
      return 'The imposter guessed the word!';
    }
    return 'The imposter escaped the vote!';
  }
}
