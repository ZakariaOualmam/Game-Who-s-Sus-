import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_localizations.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_countdown.dart';
import '../../widgets/game_scaffold.dart';
import 'voting_screen.dart';

/// Verbal discussion phase before voting begins. A countdown from the
/// configured discussion time automatically moves the game to voting at zero.
class DiscussionScreen extends StatefulWidget {
  const DiscussionScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  bool _transitioning = false;

  GameEngine get engine => widget.engine;

  void _startVoting() {
    if (_transitioning) return;
    _transitioning = true;
    Navigator.of(context).pushReplacement(
      appRoute(VotingScreen(engine: engine)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = engine.category!;
    return GameScaffold(
      title: l10n.discussTitle.toUpperCase(),
      canPop: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Center(
            child: GameCountdown(
              duration: engine.settings.discussionTime,
              label: l10n.timeLeft,
              onFinished: _startVoting,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '🗣️',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.discuss.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTypography.display(context).copyWith(fontSize: 54),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.figureOutWhosImp,
            textAlign: TextAlign.center,
            style: AppTypography.caption(context).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 28),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '${category.emoji}  ${l10n.categoryName(category)}',
                style: AppTypography.bodyBold(context),
              ),
            ),
          ),
          const SizedBox(height: 44),
          GameButton(
            label: l10n.startVoting.toUpperCase(),
            icon: Icons.how_to_vote,
            onPressed: _startVoting,
          ),
        ],
      ),
    );
  }
}
