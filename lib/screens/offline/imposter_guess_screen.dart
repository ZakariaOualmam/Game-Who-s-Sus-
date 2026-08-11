import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import 'winner_screen.dart';

/// The imposter's one final chance to guess the secret word.
class ImposterGuessScreen extends StatefulWidget {
  const ImposterGuessScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<ImposterGuessScreen> createState() => _ImposterGuessScreenState();
}

class _ImposterGuessScreenState extends State<ImposterGuessScreen> {
  final TextEditingController _controller = TextEditingController();

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final engine = widget.engine;
    engine.submitImposterGuess(_controller.text);
    engine.finishRound();
    Navigator.of(context).pushReplacement(
      appRoute(WinnerScreen(engine: engine)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imposter = widget.engine.imposter!;
    return GameScaffold(
      title: 'FINAL GUESS',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const Text('🤔', textAlign: TextAlign.center, style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            imposter.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(context).copyWith(fontSize: 44),
          ),
          const SizedBox(height: 10),
          Text(
            'You have one chance to guess the word',
            textAlign: TextAlign.center,
            style: AppTypography.caption(context).copyWith(fontSize: 15),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 40,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              counterText: '',
              hintText: 'Your guess',
            ),
            onSubmitted: (_) {
              if (_canSubmit) _submit();
            },
          ),
          const SizedBox(height: 36),
          GameButton(
            label: 'GUESS',
            icon: Icons.send,
            onPressed: _canSubmit ? _submit : null,
          ),
        ],
      ),
    );
  }
}
