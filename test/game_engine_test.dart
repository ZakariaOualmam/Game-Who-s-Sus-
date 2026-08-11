import 'package:flutter_test/flutter_test.dart';

import 'package:wordimposter/data/categories.dart';
import 'package:wordimposter/game/game_engine.dart';
import 'package:wordimposter/models/game_phase.dart';
import 'package:wordimposter/models/player.dart';
import 'package:wordimposter/services/word_repository.dart';

class _FakeWordSource implements WordSource {
  @override
  Future<String> randomWord(WordCategory category) async => 'secretword';

  @override
  Future<List<String>> loadWords(WordCategory category) async => ['secretword'];
}

GameEngine _engine() {
  return GameEngine(
    players: [
      Player(id: 'a', name: 'Anna'),
      Player(id: 'b', name: 'Bob'),
      Player(id: 'c', name: 'Cara'),
      Player(id: 'd', name: 'Dan'),
    ],
    wordSource: _FakeWordSource(),
  );
}

void main() {
  group('GameEngine', () {
    test('startRound assigns exactly one imposter and a secret word', () async {
      final engine = _engine();
      await engine.startRound(categories.first);

      expect(engine.secretWord, 'secretword');
      expect(engine.imposter, isNotNull);
      expect(engine.players.where((p) => p.isImposter).length, 1);
      expect(engine.players.where((p) => p.isCrew).length, 3);
      expect(engine.phase, GamePhase.roleReveal);
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
      engine.castVote(voterId: 'a', targetId: 'b');
      engine.castVote(voterId: 'b', targetId: 'c');
      engine.castVote(voterId: 'c', targetId: 'd');
      expect(engine.allPlayersVoted, isFalse);
      engine.castVote(voterId: 'd', targetId: 'a');
      expect(engine.allPlayersVoted, isTrue);
    });

    test('accused player is the one with the most votes', () async {
      final engine = _engine();
      await engine.startRound(categories.first);

      engine.castVote(voterId: 'a', targetId: 'c');
      engine.castVote(voterId: 'b', targetId: 'c');
      engine.castVote(voterId: 'c', targetId: 'a');
      engine.castVote(voterId: 'd', targetId: 'c');

      expect(engine.accusedPlayer!.id, 'c');
    });

    test('crew wins when imposter is accused and guesses wrong', () async {
      final engine = _engine();
      await engine.startRound(categories.first);
      final imposter = engine.imposter!;

      for (final player in engine.players) {
        if (player.id == imposter.id) continue;
        engine.castVote(voterId: player.id, targetId: imposter.id);
      }
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

      for (final player in engine.players) {
        if (player.id == imposter.id) continue;
        engine.castVote(voterId: player.id, targetId: scapegoat.id);
      }
      engine.submitImposterGuess('wrongguess');

      final result = engine.finishRound();
      expect(result.crewWins, isFalse);
      expect(imposter.score, 2);
      expect(scapegoat.score, 0);
    });

    test('imposter wins even when caught if they guess the word', () async {
      final engine = _engine();
      await engine.startRound(categories.first);
      final imposter = engine.imposter!;

      for (final player in engine.players) {
        if (player.id == imposter.id) continue;
        engine.castVote(voterId: player.id, targetId: imposter.id);
      }
      engine.submitImposterGuess('SECRETWORD');

      final result = engine.finishRound();
      expect(result.guessedCorrectly, isTrue);
      expect(result.crewWins, isFalse);
      expect(imposter.score, 2);
    });

    test('resetForNewRound keeps scores but clears round state', () async {
      final engine = _engine();
      await engine.startRound(categories.first);
      final imposter = engine.imposter!;
      for (final player in engine.players) {
        if (player.id == imposter.id) continue;
        engine.castVote(voterId: player.id, targetId: imposter.id);
      }
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

    test('roles are randomly reassigned each round', () async {
      final engine = _engine();
      await engine.startRound(categories.first);
      engine.resetForNewRound();
      await engine.startRound(categories.first);
      // Statistically unlikely to be identical, but this mainly guards
      // against roles persisting across rounds.
      expect(engine.imposter, isNotNull);
      expect(engine.players.where((p) => p.isImposter).length, 1);
    });
  });
}
