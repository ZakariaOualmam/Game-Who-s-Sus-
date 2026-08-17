import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../game/game_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../models/player.dart';
import '../../screens/home/home_screen.dart';
import '../../services/ad_service.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/player_card.dart';
import 'category_screen.dart';

/// Running scores across rounds, with play-again / home actions.
class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  bool _adInProgress = false;

  @override
  void initState() {
    super.initState();
    final ad = AdService.instance;
    ad.recordRoundCompleted();
    ad.preloadInterstitial();
  }

  Future<void> _playAgain(BuildContext context) async {
    if (_adInProgress) return;
    final ad = AdService.instance;
    final navigator = Navigator.of(context);

    if (ad.shouldShowAd) {
      setState(() => _adInProgress = true);
      final shown = await ad.showInterstitialIfAvailable();
      if (!mounted) return;
      if (shown) {
        setState(() => _adInProgress = false);
      }
    }

    if (!mounted) return;
    widget.engine.resetForNewRound();
    navigator.pushReplacement(
      appRoute(CategoryScreen(engine: widget.engine)),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      appRoute(const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sorted = [...widget.engine.players]
      ..sort((a, b) => b.score.compareTo(a.score));

    return GameScaffold(
      title: l10n.scoresTitle.toUpperCase(),
      onBack: () => _goHome(context),
      canPop: false,
      onPopBlocked: () => _goHome(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          for (var i = 0; i < sorted.length; i++) ...[
            _RankRow(index: i, player: sorted[i]),
            const SizedBox(height: 10),
          ],
        ],
      ),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameButton(
            label: l10n.playAgain.toUpperCase(),
            icon: Icons.replay,
            colors: AppColors.crewGradient,
            onPressed: _adInProgress ? null : () => _playAgain(context),
          ),
          const SizedBox(height: 12),
          GameButton(
            label: l10n.homeButton.toUpperCase(),
            colors: const [AppColors.surfaceHigh, AppColors.surfaceHigh],
            onPressed: _adInProgress ? null : () => _goHome(context),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.index, required this.player});

  final int index;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 34,
          child: Text(
            _rankLabel(index),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PlayerCard(player: player, showScore: true),
        ),
      ],
    );
  }

  String _rankLabel(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '${index + 1}.';
    }
  }
}
