import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/haptics.dart';
import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../models/player.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import 'winner_screen.dart';

/// The imposter's one final chance: pick the secret word from multiple choice.
///
/// The phone is passed to the imposter and the options only appear after an
/// explicit "I'M READY" tap, so nobody else can see the answer beforehand.
class ImposterGuessScreen extends StatefulWidget {
  const ImposterGuessScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<ImposterGuessScreen> createState() => _ImposterGuessScreenState();
}

class _ImposterGuessScreenState extends State<ImposterGuessScreen> {
  bool _ready = false;
  List<String>? _options;

  void _onReady() {
    Haptics.lightImpact();
    setState(() => _ready = true);
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final engine = widget.engine;
    final decoys = await engine.wordSource.decoyWords(
      category: engine.category!,
      correctWord: engine.secretWord!,
      count: 3,
    );
    if (!mounted) return;
    setState(() {
      _options = ([engine.secretWord!, ...decoys]..shuffle(Random()));
    });
  }

  void _submit(String guess) {
    final engine = widget.engine;
    engine.submitImposterGuess(guess);
    engine.finishRound();
    Haptics.mediumImpact();
    Navigator.of(context).pushReplacement(
      appRoute(WinnerScreen(engine: engine)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final engine = widget.engine;
    final options = _options;

    return GameScaffold(
      title: l10n.finalChance.toUpperCase(),
      canPop: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          if (!_ready)
            _PassToImposter(imposter: engine.imposter!, onReady: _onReady)
          else ...[
            const Text(
              '🤔',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.pickSecretWord,
              textAlign: TextAlign.center,
              style: AppTypography.headline(context).copyWith(fontSize: 34),
            ),
            const SizedBox(height: 32),
            if (options == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              )
            else
              for (var i = 0; i < options.length; i++) ...[
                GameButton(
                  label: options[i],
                  colors: i % 2 == 0
                      ? const [AppColors.surfaceHigh, AppColors.surfaceHigh]
                      : const [AppColors.surface, AppColors.surfaceHigh],
                  height: 58,
                  fontSize: 18,
                  onPressed: () => _submit(options[i]),
                ),
                const SizedBox(height: 12),
              ],
          ],
        ],
      ),
    );
  }
}

class _PassToImposter extends StatelessWidget {
  const _PassToImposter({required this.imposter, required this.onReady});

  final Player imposter;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 28),
        Text(
          l10n.passPhoneTo,
          textAlign: TextAlign.center,
          style: AppTypography.caption(context).copyWith(fontSize: 16),
        ),
        const SizedBox(height: 18),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            imposter.name,
            textAlign: TextAlign.center,
            style: AppTypography.display(context).copyWith(fontSize: 52),
          ),
        ),
        const SizedBox(height: 34),
        const Text(
          '🕶️',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 56),
        GameButton(
          label: l10n.imReady.toUpperCase(),
          onPressed: onReady,
        ),
      ],
    );
  }
}
