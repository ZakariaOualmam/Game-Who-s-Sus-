import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../models/player.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import 'discussion_screen.dart';

/// Pass-the-phone role reveal. Each player sees either the secret word or that
/// they are the imposter. A neutral cover frame hides the previous player's
/// secret before the next player takes the phone.
class RoleRevealScreen extends StatefulWidget {
  const RoleRevealScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  bool _covering = false;
  Timer? _coverTimer;

  GameEngine get engine => widget.engine;

  void _onReady() {
    HapticFeedback.lightImpact();
    setState(() => engine.nextRevealStep());
  }

  void _onDone() {
    final isLast = engine.revealStep == engine.players.length * 2 - 1;
    HapticFeedback.lightImpact();
    setState(() => engine.nextRevealStep());

    if (engine.isRevealComplete) {
      Navigator.of(context).pushReplacement(
        appRoute(DiscussionScreen(engine: engine)),
      );
      return;
    }

    if (!isLast) {
      // Blank the screen before the next player picks up the phone.
      setState(() => _covering = true);
      _coverTimer?.cancel();
      _coverTimer = Timer(const Duration(milliseconds: 260), () {
        if (mounted) setState(() => _covering = false);
      });
    }
  }

  @override
  void dispose() {
    _coverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = engine.playerAtRevealStep();
    final showingRole = engine.isRoleShownAtCurrentStep;
    final isLast = engine.revealStep == engine.players.length * 2 - 1;

    return GameScaffold(
      title: l10n.secretRoleTitle.toUpperCase(),
      canPop: false,
      body: _covering
          ? _PassCover(l10n: l10n)
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: showingRole
                  ? _RoleView(
                      key: ValueKey('role-$isLast'),
                      player: player,
                      word: engine.secretWord!,
                      isImposter: player.isImposter,
                      isLast: isLast,
                      onDone: _onDone,
                    )
                  : _PassView(
                      key: ValueKey('pass-${engine.revealStep}'),
                      player: player,
                      onReady: _onReady,
                    ),
            ),
    );
  }
}

class _PassCover extends StatelessWidget {
  const _PassCover({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 90),
        const Text(
          '📱',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 60),
        ),
        const SizedBox(height: 28),
        Text(
          l10n.passThePhone.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.display(context).copyWith(fontSize: 44),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.noPeeking,
          textAlign: TextAlign.center,
          style: AppTypography.caption(context),
        ),
      ],
    );
  }
}

class _PassView extends StatelessWidget {
  const _PassView({super.key, required this.player, required this.onReady});

  final Player player;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _AnimatedReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          Text(
            l10n.passPhoneTo,
            textAlign: TextAlign.center,
            style: AppTypography.caption(context).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              player.name,
              textAlign: TextAlign.center,
              style: AppTypography.display(context).copyWith(fontSize: 52),
            ),
          ),
          const SizedBox(height: 34),
          const Text(
            '📱',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 56),
          GameButton(
            label: l10n.imReady.toUpperCase(),
            onPressed: onReady,
          ),
        ],
      ),
    );
  }
}

class _RoleView extends StatelessWidget {
  const _RoleView({
    super.key,
    required this.player,
    required this.word,
    required this.isImposter,
    required this.isLast,
    required this.onDone,
  });

  final Player player;
  final String word;
  final bool isImposter;
  final bool isLast;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _AnimatedReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            player.name,
            textAlign: TextAlign.center,
            style: AppTypography.caption(context).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 20),
          if (isImposter)
            const _ImposterCard()
          else
            _WordCard(word: word),
          const SizedBox(height: 44),
          GameButton(
            label: isLast
                ? l10n.startDiscussion.toUpperCase()
                : l10n.passThePhone.toUpperCase(),
            colors: isImposter
                ? AppColors.imposterGradient
                : AppColors.primaryGradient,
            onPressed: onDone,
          ),
        ],
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceHigh],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            l10n.yourSecretWordIs,
            style: AppTypography.caption(context).copyWith(letterSpacing: 3),
          ),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              word,
              textAlign: TextAlign.center,
              style: AppTypography.word(context).copyWith(fontSize: 46),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.dontSayTheWord,
            textAlign: TextAlign.center,
            style: AppTypography.caption(context),
          ),
        ],
      ),
    );
  }
}

class _ImposterCard extends StatelessWidget {
  const _ImposterCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1220), Color(0xFF1A0A14)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Text('🕶️', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 14),
          Text(
            l10n.youAreTheImposter,
            textAlign: TextAlign.center,
            style: AppTypography.headline(context).copyWith(
              color: AppColors.danger,
              fontSize: 40,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.blendInDontGetCaught,
            textAlign: TextAlign.center,
            style: AppTypography.caption(context),
          ),
        ],
      ),
    );
  }
}

class _AnimatedReveal extends StatelessWidget {
  const _AnimatedReveal({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) => Opacity(
        opacity: value,
        child: Transform.scale(
          scale: 0.94 + 0.06 * value,
          child: animatedChild,
        ),
      ),
      child: child,
    );
  }
}
