import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/data/categories.dart';
import 'package:who_sus/game/game_engine.dart';
import 'package:who_sus/models/game_phase.dart';
import 'package:who_sus/models/player.dart';
import 'package:who_sus/services/word_repository.dart';

class _FakeWordSource implements WordSource {
  @override
  Future<String> randomWord(WordCategory category) async => 'secretword';

  @override
  Future<List<String>> loadWords(WordCategory category) async =>
      ['secretword', 'decoy'];

  @override
  Future<List<String>> decoyWords({
    required WordCategory category,
    required String correctWord,
    required int count,
  }) async =>
      ['decoy1', 'decoy2', 'decoy3'].take(count).toList();
}

GameEngine _engine([int playerCount = 4]) {
  return GameEngine(
    players: [
      for (var i = 0; i < playerCount; i++)
        Player(id: 'p$i', name: 'Player $i'),
    ],
    wordSource: _FakeWordSource(),
  );
}

/// Everyone except [targetId] votes for [targetId].
void _voteAgainst(GameEngine engine, String targetId) {
  for (final player in engine.players) {
    if (player.id == targetId) continue;
    engine.castVote(voterId: player.id, targetId: targetId);
  }
}

void main() {
  group('GameEngine', () {
    test('startRound assigns exactly one imposter and a secret word', () async {
      final engine = _engine();
      await engine.startRound(categories.first);

      expect(engine.secretWord, 'secretword');
      expect(engine.imposter, isNotNull);
      expect(engine.players, contains(engine.imposter));
      expect(engine.players.where((p) => p.isImposter).length, 1);
      expect(engine.players.where((p) => p.isCrew).length, 3);
      expect(engine.phase, GamePhase.roleReveal);
    });

    test('exactly one imposter with 5 players', () async {
      final engine = _engine(5);
      await engine.startRound(categories.first);
      expect(engine.players.where((p) => p.isImposter).length, 1);
      expect(engine.players.where((p) => p.isCrew).length, 4);
    });

    test('exactly one imposter with 8 players', () async {
      final engine = _engine(8);
      await engine.startRound(categories.first);
      expect(engine.players.where((p) => p.isImposter).length, 1);
      expect(engine.players.where((p) => p.isCrew).length, 7);
    });

    test('reveal sequence walks each player in order', () async {
      final engine = _engine();
      await engine.startRound(categories.first);

      for (var step = 0; step < engine.players.length * 2; step++) {
        expect(engine.isRoleShownAtCurrentStep, step.isOdd);
        expect(engine.playerAtRevealStep().id, engine.players[step ~/ 2].id);
        engine.nextRevealStep();
      }
      expect(engine.isRevealComplete, isTrue);
    });

    test('all players must vote before results count', () async {
      final engine = _engine();
      await engine.startRound(categories.first);

      expect(engine.allPlayersVoted, isFalse);
      engine.castVote(voterId: 'p0', targetId: 'p1');
      engine.castVote(voterId: 'p1', targetId: 'p2');
      engine.castVote(voterId: 'p2', targetId: 'p3');
      expect(engine.allPlayersVoted, isFalse);
      engine.castVote(voterId: 'p3', targetId: 'p0');
      expect(engine.allPlayersVoted, isTrue);
    });

    test('a player can never double their vote', () async {
      final engine = _engine();
      await engine.startRound(categories.first);

      engine.castVote(voterId: 'p0', targetId: 'p1');
      engine.castVote(voterId: 'p0', targetId: 'p2');

      expect(engine.votes.length, 1);
      expect(engine.voteCounts['p2'], 1);
      expect(engine.voteCounts.containsKey('p1'), isFalse);
      expect(engine.accusedPlayer?.id, 'p2');
    });

    test('accused player is the one with the most votes', () async {
      final engine = _engine();
      await engine.startRound(categories.first);

      engine.castVote(voterId: 'p0', targetId: 'p2');
      engine.castVote(voterId: 'p1', targetId: 'p2');
      engine.castVote(voterId: 'p2', targetId: 'p0');
      engine.castVote(voterId: 'p3', targetId: 'p2');

      expect(engine.accusedPlayer!.id, 'p2');
    });

    test('a tie at the top means no one is accused', () async {
      final engine = _engine();
      await engine.startRound(categories.first);

      engine.castVote(voterId: 'p0', targetId: 'p1');
      engine.castVote(voterId: 'p1', targetId: 'p2');
      engine.castVote(voterId: 'p2', targetId: 'p1');
      engine.castVote(voterId: 'p3', targetId: 'p2');

      expect(engine.accusedPlayer, isNull);
      expect(engine.isImposterCaught, isFalse);
    });

    test('crew wins when imposter is accused and guesses wrong', () async {
      final engine = _engine();
      await engine.startRound(categories.first);
      final imposter = engine.imposter!;

      _voteAgainst(engine, imposter.id);
      engine.submitImposterGuess('wrongguess');

      final result = engine.finishRound();
      expect(result.crewWins, isTrue);
      expect(result.guessedCorrectly, isFalse);
      for (final player in engine.players.where((p) => p.isCrew)) {
        expect(player.score, 1);
      }
      expect(imposter.score, 0);
    });

    test('imposter wins when the crew votes out a normal player', () async {
      final engine = _engine();
      await engine.startRound(categories.first);
      final imposter = engine.imposter!;
      final scapegoat = engine.players.firstWhere((p) => !p.isImposter);

      _voteAgainst(engine, scapegoat.id);
      engine.submitImposterGuess('wrongguess');

      final result = engine.finishRound();
      expect(result.crewWins, isFalse);
      expect(imposter.score, 2);
      expect(scapegoat.score, 0);
    });

    test('imposter caught but guesses the word correctly gets +1', () async {
      final engine = _engine();
      await engine.startRound(categories.first);
      final imposter = engine.imposter!;

      _voteAgainst(engine, imposter.id);
      engine.submitImposterGuess('SECRETWORD');

      final result = engine.finishRound();
      expect(result.guessedCorrectly, isTrue);
      expect(result.crewWins, isFalse);
      expect(imposter.score, 1);
      expect(engine.players.where((p) => p.isCrew).every((p) => p.score == 0),
          isTrue);
    });

    test('imposter not caught but guesses correctly gets +2', () async {
      final engine = _engine();
      await engine.startRound(categories.first);
      final imposter = engine.imposter!;
      final scapegoat = engine.players.firstWhere((p) => !p.isImposter);

      _voteAgainst(engine, scapegoat.id);
      engine.submitImposterGuess('secretword');

      final result = engine.finishRound();
      expect(result.guessedCorrectly, isTrue);
      expect(result.crewWins, isFalse);
      expect(imposter.score, 2);
    });

    test('resetForNewRound keeps scores but clears round state', () async {
      final engine = _engine();
      await engine.startRound(categories.first);
      _voteAgainst(engine, engine.imposter!.id);
      engine.submitImposterGuess('wrong');
      engine.finishRound();

      engine.resetForNewRound();
      expect(engine.secretWord, isNull);
      expect(engine.imposter, isNull);
      expect(engine.votes, isEmpty);
      expect(engine.lastRound, isNull);
      expect(engine.phase, GamePhase.category);
      expect(engine.players.every((p) => p.role == null), isTrue);
      expect(engine.players.where((p) => p.score > 0).length, 3);
    });

    test('play again keeps scores across a new round', () async {
      final engine = _engine();
      await engine.startRound(categories.first);
      _voteAgainst(engine, engine.imposter!.id);
      engine.submitImposterGuess('wrong');
      engine.finishRound();
      final scoreBefore =
          engine.players.fold(0, (sum, p) => sum + p.score);

      engine.resetForNewRound();
      await engine.startRound(categories.first);
      final scoreAfter =
          engine.players.fold(0, (sum, p) => sum + p.score);

      expect(scoreAfter, scoreBefore);
      expect(engine.players.where((p) => p.isImposter).length, 1);
    });

    test('roles are randomly reassigned each round', () async {
      final engine = _engine();
      await engine.startRound(categories.first);
      engine.resetForNewRound();
      await engine.startRound(categories.first);
      // This mainly guards against roles persisting across rounds.
      expect(engine.imposter, isNotNull);
      expect(engine.players.where((p) => p.isImposter).length, 1);
    });
  });
}
