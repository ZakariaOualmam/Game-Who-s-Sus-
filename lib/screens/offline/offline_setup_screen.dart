import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_settings.dart';
import '../../models/player.dart';
import '../../services/word_repository.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/player_card.dart';
import 'category_screen.dart';

class OfflineSetupScreen extends StatefulWidget {
  const OfflineSetupScreen({super.key});

  @override
  State<OfflineSetupScreen> createState() => _OfflineSetupScreenState();
}

class _OfflineSetupScreenState extends State<OfflineSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _names = [];

  void _addName() {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (_names.contains(name)) {
      _showMessage(l10n.nameAlreadyAdded);
      return;
    }
    if (_names.length >= GameSettings.maxPlayers) {
      _showMessage(l10n.maximumPlayers(GameSettings.maxPlayers));
      return;
    }
    setState(() => _names.add(name));
    _nameController.clear();
  }

  void _removeName(int index) => setState(() => _names.removeAt(index));

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _continue() {
    final l10n = AppLocalizations.of(context);
    if (_names.length < GameSettings.minPlayers) {
      _showMessage(l10n.addPlayersToStart(
        GameSettings.minPlayers,
        GameSettings.maxPlayers,
      ));
      return;
    }
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final players = [
      for (var i = 0; i < _names.length; i++)
        Player(id: 'p$stamp-$i', name: _names[i]),
    ];
    final locale = Localizations.localeOf(context);
    final engine = GameEngine(
      players: players,
      wordSource: WordRepository.instanceFor(locale),
    );
    Navigator.of(context).push(appRoute(CategoryScreen(engine: engine)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canContinue = _names.length >= GameSettings.minPlayers;
    return GameScaffold(
      title: l10n.playersTitle.toUpperCase(),
      onBack: () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(l10n.addPlayers, style: AppTypography.title(context)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_names.length}/${GameSettings.maxPlayers}',
                  style: AppTypography.caption(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            maxLength: 18,
            decoration: InputDecoration(
              counterText: '',
              hintText: l10n.playerNameHint,
              prefixIcon: const Icon(Icons.person, color: AppColors.textMuted),
            ),
            onSubmitted: (_) => _addName(),
          ),
          const SizedBox(height: 10),
          GameButton(
            label: l10n.addPlayerButton.toUpperCase(),
            icon: Icons.add,
            colors: const [AppColors.surfaceHigh, AppColors.surfaceHigh],
            height: 52,
            fontSize: 16,
            onPressed: _addName,
          ),
          const SizedBox(height: 18),
          if (_names.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                l10n.addPlayersToStart(
                  GameSettings.minPlayers,
                  GameSettings.maxPlayers,
                ),
                textAlign: TextAlign.center,
                style: AppTypography.caption(context),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.0,
              children: [
                for (var i = 0; i < _names.length; i++)
                  PlayerCard(
                    player: Player(id: 'tmp$i', name: _names[i]),
                    trailing: GestureDetector(
                      onTap: () => _removeName(i),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      bottomBar: GameButton(
        label: canContinue
            ? l10n.pickCategoryButton
            : l10n.addPlayersMinButton(GameSettings.minPlayers),
        onPressed: canContinue ? _continue : null,
      ),
    );
  }
}
