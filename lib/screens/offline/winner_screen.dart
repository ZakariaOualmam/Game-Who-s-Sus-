import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../models/round_result.dart';
import '../../widgets/confetti_burst.dart';
import '../../widgets/game_button.dart';
import 'scoreboard_screen.dart';

/// Announces the round winner, points awarded, with confetti.
class WinnerScreen extends StatefulWidget {
  const WinnerScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) HapticFeedback.mediumImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.engine.lastRound!;
    final isCrewWin = result.crewWins;
    final imposterPoints = result.scoreChanges[result.imposter.id] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: ConfettiBurst(
              colors: isCrewWin
                  ? const [
                      AppColors.success,
                      AppColors.secondary,
                      AppColors.primary,
                      AppColors.warning,
                    ]
                  : const [
                      AppColors.danger,
                      AppColors.warning,
                      AppColors.accent,
                    ],
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          const Text(
                            '🎉',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 72),
                          ),
                          const SizedBox(height: 16),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isCrewWin ? 'CREW WINS!' : 'IMPOSTER WINS!',
                              textAlign: TextAlign.center,
                              style: AppTypography.display(context).copyWith(
                                fontSize: 54,
                                color: isCrewWin
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _subtitle(result),
                            textAlign: TextAlign.center,
                            style: AppTypography.body(context),
                          ),
                          const SizedBox(height: 28),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _pointsTitle(result, isCrewWin),
                                  style: AppTypography.title(context),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _pointsDetail(result, isCrewWin, imposterPoints),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 22,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'THE WORD WAS',
                                  style: AppTypography.caption(context)
                                      .copyWith(letterSpacing: 2),
                                ),
                                const SizedBox(height: 10),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    result.secretWord,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.word(context)
                                        .copyWith(fontSize: 40),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  result.guessedCorrectly
                                      ? 'The imposter guessed it!'
                                      : "The imposter didn't guess it",
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption(context),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GameButton(
                            label: 'SEE SCOREBOARD',
                            icon: Icons.leaderboard,
                            onPressed: () => Navigator.of(context)
                                .pushReplacement(
                                  appRoute(ScoreboardScreen(engine: widget.engine)),
                                ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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

  String _pointsTitle(RoundResult result, bool isCrewWin) {
    if (isCrewWin) return 'Every crew member +1';
    if (result.guessedCorrectly) return 'Imposter +1';
    return 'Imposter +2';
  }

  String _pointsDetail(
    RoundResult result,
    bool isCrewWin,
    int imposterPoints,
  ) {
    if (isCrewWin) return 'Imposter was caught and missed the word';
    if (result.guessedCorrectly) {
      return 'Discovered but guessed the word';
    }
    return 'Survived the vote';
  }
}
