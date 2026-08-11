import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import 'imposter_guess_screen.dart';

/// Dramatic reveal of who the imposter was and the secret word.
class ImposterRevealScreen extends StatefulWidget {
  const ImposterRevealScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<ImposterRevealScreen> createState() => _ImposterRevealScreenState();
}

class _ImposterRevealScreenState extends State<ImposterRevealScreen> {
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
    final engine = widget.engine;
    final imposter = engine.imposter!;
    final caught = engine.isImposterCaught;
    final isTie = engine.accusedPlayer == null;

    return GameScaffold(
      title: l10n.imposterTitle.toUpperCase(),
      canPop: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Text(
            '😱',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.theImposterWas.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTypography.caption(context).copyWith(letterSpacing: 2),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: child,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                imposter.name,
                textAlign: TextAlign.center,
                style: AppTypography.display(context)
                    .copyWith(fontSize: 52, color: AppColors.danger),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _outcomeText(l10n, caught: caught, isTie: isTie),
            textAlign: TextAlign.center,
            style: AppTypography.bodyBold(context),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_objects, color: AppColors.warning),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    l10n.finalGuessHint,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyBold(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          GameButton(
            label: l10n.finalChance.toUpperCase(),
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

  String _outcomeText(
    AppLocalizations l10n, {
    required bool caught,
    required bool isTie,
  }) {
    if (caught) return l10n.outcomeCrewCaught;
    if (isTie) return l10n.outcomeTieGotAway;
    return l10n.outcomeFooledEveryone;
  }
}
