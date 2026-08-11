import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
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
                              isCrewWin
                                  ? l10n.crewWins.toUpperCase()
                                  : l10n.imposterWins.toUpperCase(),
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
                            _subtitle(l10n, result),
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
                                  _pointsTitle(l10n, result, isCrewWin),
                                  style: AppTypography.title(context),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _pointsDetail(
                                    l10n,
                                    result,
                                    isCrewWin,
                                    imposterPoints,
                                  ),
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
                                  l10n.theWordWas.toUpperCase(),
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
                                      ? l10n.guessedIt
                                      : l10n.didntGuessIt,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption(context),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GameButton(
                            label: l10n.seeScoreboard.toUpperCase(),
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

  String _subtitle(AppLocalizations l10n, RoundResult result) {
    if (result.crewWins) {
      return result.guessedCorrectly
          ? l10n.subtitleAlmostMadeIt
          : l10n.subtitleCaughtMissed;
    }
    if (result.guessedCorrectly) {
      return l10n.subtitleGuessedWord;
    }
    return l10n.subtitleEscaped;
  }

  String _pointsTitle(
    AppLocalizations l10n,
    RoundResult result,
    bool isCrewWin,
  ) {
    if (isCrewWin) return l10n.pointsCrewPlusOne;
    if (result.guessedCorrectly) return l10n.pointsImposterPlusOne;
    return l10n.pointsImposterPlusTwo;
  }

  String _pointsDetail(
    AppLocalizations l10n,
    RoundResult result,
    bool isCrewWin,
    int imposterPoints,
  ) {
    if (isCrewWin) return l10n.detailCaughtMissed;
    if (result.guessedCorrectly) {
      return l10n.detailDiscoveredGuessed;
    }
    return l10n.detailSurvived;
  }
}
