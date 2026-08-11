import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../models/player.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import 'discussion_screen.dart';

/// Pass-the-phone role reveal. Each player sees either the secret word or
/// that they are the imposter.
class RoleRevealScreen extends StatefulWidget {
  const RoleRevealScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  GameEngine get engine => widget.engine;

  void _handleNext() {
    setState(() => engine.nextRevealStep());
    if (engine.isRevealComplete) {
      Navigator.of(context).pushReplacement(
        appRoute(DiscussionScreen(engine: engine)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = engine.playerAtRevealStep();
    final showingRole = engine.isRoleShownAtCurrentStep;
    final isLast = engine.revealStep == engine.players.length * 2 - 1;

    return GameScaffold(
      title: 'SECRET ROLE',
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: showingRole
            ? _RoleView(
                key: ValueKey('role-$isLast'),
                player: player,
                word: engine.secretWord!,
                isImposter: player.isImposter,
                isLast: isLast,
                onDone: _handleNext,
              )
            : _PassView(
                key: ValueKey('pass-${engine.revealStep}'),
                player: player,
                onReady: _handleNext,
              ),
      ),
    );
  }
}

class _PassView extends StatelessWidget {
  const _PassView({super.key, required this.player, required this.onReady});

  final Player player;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),
        Text(
          'Pass the phone to',
          textAlign: TextAlign.center,
          style: AppTypography.caption(context).copyWith(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Text(
          player.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.display(context).copyWith(fontSize: 52),
        ),
        const SizedBox(height: 36),
        const Text('📱', textAlign: TextAlign.center, style: TextStyle(fontSize: 80)),
        const SizedBox(height: 60),
        GameButton(
          label: "I'M READY",
          onPressed: onReady,
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          player.name,
          textAlign: TextAlign.center,
          style: AppTypography.caption(context).copyWith(fontSize: 16),
        ),
        const SizedBox(height: 24),
        if (isImposter)
          _ImposterCard()
        else
          _WordCard(word: word),
        const SizedBox(height: 48),
        GameButton(
          label: isLast ? 'START THE DISCUSSION' : 'NEXT PLAYER',
          colors: isImposter
              ? AppColors.imposterGradient
              : AppColors.primaryGradient,
          onPressed: onDone,
        ),
      ],
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
            'THE WORD IS',
            style: AppTypography.caption(context).copyWith(letterSpacing: 3),
          ),
          const SizedBox(height: 18),
          Text(
            word,
            textAlign: TextAlign.center,
            style: AppTypography.word(context).copyWith(fontSize: 48),
          ),
          const SizedBox(height: 18),
          Text(
            'Don\u2019t say the word',
            textAlign: TextAlign.center,
            style: AppTypography.caption(context),
          ),
        ],
      ),
    );
  }
}

class _ImposterCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
          const Text('🕶️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'YOU ARE THE\nIMPOSTER',
            textAlign: TextAlign.center,
            style: AppTypography.headline(context).copyWith(
              color: AppColors.danger,
              fontSize: 40,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Blend in. Don\u2019t get caught.',
            textAlign: TextAlign.center,
            style: AppTypography.caption(context),
          ),
        ],
      ),
    );
  }
}
