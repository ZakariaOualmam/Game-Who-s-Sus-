import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/categories.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_localizations.dart';
import '../../models/online_game_phase.dart';
import '../../models/online_player_round_state.dart';
import '../../models/online_round.dart';
import '../../models/room.dart';
import '../../models/room_player.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/online_game_service.dart';
import '../../services/room_service.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/player_card.dart';
import '../../models/player.dart' as game_models;

class OnlineGameScreen extends StatefulWidget {
  const OnlineGameScreen({
    super.key,
    required this.roomId,
    required this.currentPlayer,
  });

  final String roomId;
  final RoomPlayer currentPlayer;

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  Room? _room;
  OnlineRound? _round;
  OnlinePlayerRoundState? _myState;
  List<RoomPlayer> _players = [];
  Map<String, int> _voteTotals = {};
  RoomSubscription? _sub;
  bool _loading = true;
  bool _busy = false;

  bool get _isHost => _room?.hostPlayerId == FirebaseAuthService.instance.currentUid;

  @override
  void initState() {
    super.initState();
    _refreshAll();
    _sub = OnlineGameService.instance.subscribeToGameRoom(
      roomId: widget.roomId,
      onAnyChange: _refreshAll,
    );
  }

  @override
  void dispose() {
    _sub?.unsubscribe();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    try {
      final room = await OnlineGameService.instance.getRoomById(widget.roomId);
      final players = await RoomService.instance.getPlayersInRoom(widget.roomId);
      final round = await OnlineGameService.instance.getActiveRound(widget.roomId);
      OnlinePlayerRoundState? myState;
      Map<String, int> voteTotals = {};

      if (round != null) {
        myState = await OnlineGameService.instance.getMyRoundState(
          roomId: widget.roomId,
          roundId: round.id,
        );
        voteTotals = await OnlineGameService.instance.getVoteTotals(
          roomId: widget.roomId,
          roundId: round.id,
        );
      }

      if (!mounted) return;
      setState(() {
        _room = room;
        _players = players;
        _round = round;
        _myState = myState;
        _voteTotals = voteTotals;
        _loading = false;
      });

      await _runHostAutoTransitions();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _show(error.toString());
    }
  }

  Future<void> _runHostAutoTransitions() async {
    if (!_isHost || _round == null || _room == null) return;
    final phase = OnlineGamePhase.fromDb(_room!.gamePhase);

    if (phase == OnlineGamePhase.roleReveal) {
      await OnlineGameService.instance.hostTryAdvanceReveal(_room!.id, _round!.id);
    } else if (phase == OnlineGamePhase.discussion) {
      await OnlineGameService.instance.hostTryAdvanceDiscussion(_room!.id, _round!.id);
    } else if (phase == OnlineGamePhase.voting) {
      await OnlineGameService.instance.hostTryCompleteVoting(_room!.id, _round!.id);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _guarded(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      _show(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading || _room == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final phase = OnlineGamePhase.fromDb(_room!.gamePhase);

    return GameScaffold(
      title: _titleForPhase(l10n, phase),
      canPop: false,
      body: _buildPhaseBody(l10n, phase),
    );
  }

  String _titleForPhase(AppLocalizations l10n, OnlineGamePhase phase) {
    return switch (phase) {
      OnlineGamePhase.category => l10n.categoryTitle.toUpperCase(),
      OnlineGamePhase.roleReveal => l10n.secretRoleTitle.toUpperCase(),
      OnlineGamePhase.discussion => l10n.discussTitle.toUpperCase(),
      OnlineGamePhase.voting => l10n.votingTitle.toUpperCase(),
      OnlineGamePhase.voteResults => l10n.votesTitle.toUpperCase(),
      OnlineGamePhase.imposterReveal => l10n.imposterTitle.toUpperCase(),
      OnlineGamePhase.imposterGuess => l10n.finalChance.toUpperCase(),
      OnlineGamePhase.winner => 'WINNER',
      OnlineGamePhase.scoreboard => l10n.scoresTitle.toUpperCase(),
      _ => 'GAME',
    };
  }

  Widget _buildPhaseBody(AppLocalizations l10n, OnlineGamePhase phase) {
    return switch (phase) {
      OnlineGamePhase.category => _buildCategoryPhase(l10n),
      OnlineGamePhase.roleReveal => _buildRoleRevealPhase(l10n),
      OnlineGamePhase.discussion => _buildDiscussionPhase(l10n),
      OnlineGamePhase.voting => _buildVotingPhase(l10n),
      OnlineGamePhase.voteResults => _buildVoteResultsPhase(l10n),
      OnlineGamePhase.imposterReveal => _buildImposterRevealPhase(l10n),
      OnlineGamePhase.imposterGuess => _buildImposterGuessPhase(l10n),
      OnlineGamePhase.winner => _buildWinnerPhase(l10n),
      OnlineGamePhase.scoreboard => _buildScoreboardPhase(l10n),
      _ => Center(child: Text('Waiting for host...', style: AppTypography.body(context))),
    };
  }

  Widget _buildCategoryPhase(AppLocalizations l10n) {
    if (!_isHost) {
      return Center(
        child: Text('Host is selecting category...', style: AppTypography.body(context)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(l10n.pickWordCategory, style: AppTypography.title(context)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.15,
          children: [
            for (final category in categories)
              GestureDetector(
                onTap: _busy
                    ? null
                    : () => _guarded(() => OnlineGameService.instance.startRoundFromCategory(
                          room: _room!,
                          categoryId: category.id,
                          languageCode: Localizations.localeOf(context).languageCode,
                        )),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceHigh),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(category.emoji, style: const TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(l10n.categoryName(category), style: AppTypography.bodyBold(context)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleRevealPhase(AppLocalizations l10n) {
    final me = _myState;
    if (me == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final card = me.isImposter
        ? Text(
            l10n.youAreTheImposter,
            textAlign: TextAlign.center,
            style: AppTypography.headline(context).copyWith(color: AppColors.danger),
          )
        : Column(
            children: [
              Text(l10n.yourSecretWordIs, style: AppTypography.caption(context)),
              const SizedBox(height: 10),
              Text(me.secretWord ?? '-', style: AppTypography.word(context).copyWith(fontSize: 42)),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 28),
        card,
        const SizedBox(height: 32),
        GameButton(
          label: me.revealReady ? 'READY' : l10n.imReady.toUpperCase(),
          onPressed: me.revealReady
              ? null
              : () => _guarded(() async {
                    await OnlineGameService.instance.setRevealReady(
                      roomId: _room!.id,
                      roundId: _round!.id,
                      ready: true,
                    );
                    await OnlineGameService.instance.hostTryAdvanceReveal(_room!.id, _round!.id);
                  }),
        ),
      ],
    );
  }

  Widget _buildDiscussionPhase(AppLocalizations l10n) {
    final me = _myState;
    if (me == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(l10n.discuss.toUpperCase(), textAlign: TextAlign.center, style: AppTypography.display(context)),
        const SizedBox(height: 10),
        Text(l10n.figureOutWhosImp, textAlign: TextAlign.center, style: AppTypography.caption(context)),
        const SizedBox(height: 34),
        GameButton(
          label: me.discussionReady ? 'READY' : l10n.imReady.toUpperCase(),
          onPressed: me.discussionReady
              ? null
              : () => _guarded(() async {
                    await OnlineGameService.instance.setDiscussionReady(
                      roomId: _room!.id,
                      roundId: _round!.id,
                      ready: true,
                    );
                    await OnlineGameService.instance.hostTryAdvanceDiscussion(_room!.id, _round!.id);
                  }),
        ),
      ],
    );
  }

  Widget _buildVotingPhase(AppLocalizations l10n) {
    final myId = FirebaseAuthService.instance.currentUid;
    final targets = _players.where((p) => p.playerId != myId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(l10n.whoIsTheImposter, textAlign: TextAlign.center, style: AppTypography.title(context)),
        const SizedBox(height: 14),
        for (final target in targets) ...[
          PlayerCard(
            player: game_models.Player(id: target.playerId, name: target.playerName),
            onTap: () => _guarded(() async {
              await OnlineGameService.instance.castVote(
                roomId: _room!.id,
                roundId: _round!.id,
                targetPlayerId: target.playerId,
              );
              await OnlineGameService.instance.hostTryCompleteVoting(_room!.id, _round!.id);
            }),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildVoteResultsPhase(AppLocalizations l10n) {
    final accusedId = _round?.accusedPlayerId;
    final accusedName = _players
        .where((p) => p.playerId == accusedId)
        .map((p) => p.playerName)
        .firstWhere((_) => true, orElse: () => 'No one (tie)');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(l10n.mostSuspected, textAlign: TextAlign.center, style: AppTypography.caption(context)),
        const SizedBox(height: 8),
        Text(accusedName, textAlign: TextAlign.center, style: AppTypography.display(context).copyWith(fontSize: 44)),
        const SizedBox(height: 18),
        for (final p in _players) ...[
          Row(
            children: [
              Expanded(child: Text(p.playerName, style: AppTypography.body(context))),
              Text('${_voteTotals[p.playerId] ?? 0}', style: AppTypography.bodyBold(context)),
            ],
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 24),
        if (_isHost)
          GameButton(
            label: l10n.revealTheImposter.toUpperCase(),
            colors: AppColors.imposterGradient,
            onPressed: () => _guarded(() => OnlineGameService.instance.hostRevealImposter(_room!.id, _round!.id)),
          ),
      ],
    );
  }

  Widget _buildImposterRevealPhase(AppLocalizations l10n) {
    final imposterId = _round?.imposterPlayerId;
    final accusedId = _round?.accusedPlayerId;
    final imposterName = _players
        .where((p) => p.playerId == imposterId)
        .map((p) => p.playerName)
        .firstWhere((_) => true, orElse: () => 'Unknown');
    final caught = accusedId != null && accusedId == imposterId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(l10n.theImposterWas.toUpperCase(), textAlign: TextAlign.center, style: AppTypography.caption(context)),
        const SizedBox(height: 8),
        Text(imposterName, textAlign: TextAlign.center, style: AppTypography.display(context).copyWith(color: AppColors.danger)),
        const SizedBox(height: 16),
        Text(
          caught ? l10n.outcomeCrewCaught : l10n.outcomeFooledEveryone,
          textAlign: TextAlign.center,
          style: AppTypography.bodyBold(context),
        ),
        const SizedBox(height: 28),
        if (_isHost)
          GameButton(
            label: caught ? l10n.finalChance.toUpperCase() : 'SHOW WINNER',
            onPressed: () => _guarded(() async {
              if (caught) {
                await OnlineGameService.instance.advanceToImposterGuess(_room!.id);
              } else {
                await OnlineGameService.instance.finalizeRoundWithGameEngine(
                  roomId: _room!.id,
                  roundId: _round!.id,
                );
              }
            }),
          ),
      ],
    );
  }

  Widget _buildImposterGuessPhase(AppLocalizations l10n) {
    final me = _myState;
    if (me == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isImposter = me.isImposter;
    final hasSubmitted = (me.submittedGuess ?? '').isNotEmpty;

    if (!isImposter) {
      return Center(
        child: Text('Waiting for imposter guess...', style: AppTypography.body(context)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 22),
        Text(l10n.pickSecretWord, textAlign: TextAlign.center, style: AppTypography.title(context)),
        const SizedBox(height: 18),
        for (final option in me.guessOptions ?? <String>[]) ...[
          GameButton(
            label: option,
            onPressed: hasSubmitted
                ? null
                : () => _guarded(() => OnlineGameService.instance.submitImposterGuess(
                      roomId: _room!.id,
                      roundId: _round!.id,
                      guess: option,
                    )),
          ),
          const SizedBox(height: 10),
        ],
        if (hasSubmitted) ...[
          const SizedBox(height: 14),
          Text('Guess submitted.', textAlign: TextAlign.center, style: AppTypography.caption(context)),
        ],
        const SizedBox(height: 20),
        if (_isHost)
          GameButton(
            label: 'FINALIZE ROUND',
            onPressed: () => _guarded(() => OnlineGameService.instance.finalizeRoundWithGameEngine(
                  roomId: _room!.id,
                  roundId: _round!.id,
                )),
          ),
      ],
    );
  }

  Widget _buildWinnerPhase(AppLocalizations l10n) {
    final winnerSide = _round?.winnerSide;
    final guessedCorrectly = _round?.guessedCorrectly ?? false;
    final crewWin = winnerSide == 'crew';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Text(
          crewWin ? l10n.crewWins.toUpperCase() : l10n.imposterWins.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.display(context).copyWith(
            color: crewWin ? AppColors.success : AppColors.danger,
            fontSize: 50,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          guessedCorrectly ? l10n.guessedIt : l10n.didntGuessIt,
          textAlign: TextAlign.center,
          style: AppTypography.caption(context),
        ),
        const SizedBox(height: 30),
        if (_isHost)
          GameButton(
            label: l10n.seeScoreboard.toUpperCase(),
            onPressed: () => _guarded(() => OnlineGameService.instance.advanceToScoreboard(_room!.id)),
          ),
      ],
    );
  }

  Widget _buildScoreboardPhase(AppLocalizations l10n) {
    final sorted = [..._players]..sort((a, b) => b.score.compareTo(a.score));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        for (final p in sorted) ...[
          PlayerCard(
            player: game_models.Player(id: p.playerId, name: p.playerName, score: p.score),
            showScore: true,
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 20),
        if (_isHost)
          GameButton(
            label: 'NEXT ROUND',
            icon: Icons.replay,
            colors: AppColors.crewGradient,
            onPressed: () => _guarded(() => OnlineGameService.instance.startNextRound(_room!.id)),
          ),
      ],
    );
  }
}
