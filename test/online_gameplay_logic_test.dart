import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:who_sus/data/categories.dart';
import 'package:who_sus/game/game_engine.dart';
import 'package:who_sus/models/player.dart';
import 'package:who_sus/models/role.dart';
import 'package:who_sus/models/vote.dart';
import 'package:who_sus/services/online_sync_rules.dart';
import 'package:who_sus/services/word_repository.dart';

class _StubWordSource implements WordSource {
  @override
  Future<List<String>> decoyWords({
    required WordCategory category,
    required String correctWord,
    required int count,
  }) async {
    return ['lion', 'tiger', 'bear'].take(count).toList();
  }

  @override
  Future<List<String>> loadWords(WordCategory category) async {
    return ['elephant', 'lion', 'tiger', 'bear'];
  }

  @override
  Future<String> randomWord(WordCategory category) async => 'elephant';
}

void main() {
  group('Online sync rules', () {
    test('self vote prevention and duplicate vote replacement', () {
      expect(
        OnlineSyncRules.canVote(voterId: 'a', targetId: 'a'),
        isFalse,
      );

      final votes = <Vote>[];
      final afterFirst = OnlineSyncRules.upsertVote(
        existing: votes,
        next: Vote(voterId: 'a', targetId: 'b'),
      );
      final afterSecond = OnlineSyncRules.upsertVote(
        existing: afterFirst,
        next: Vote(voterId: 'a', targetId: 'c'),
      );

      expect(afterSecond.length, 1);
      expect(afterSecond.first.targetId, 'c');
    });

    test('vote completion and accused player resolution', () {
      final votes = [
        Vote(voterId: 'a', targetId: 'b'),
        Vote(voterId: 'b', targetId: 'c'),
        Vote(voterId: 'c', targetId: 'b'),
      ];

      expect(
        OnlineSyncRules.isVotingComplete(playerCount: 3, votes: votes),
        isTrue,
      );

      final accused = OnlineSyncRules.accusedPlayerId(
        playerIds: const ['a', 'b', 'c'],
        votes: votes,
      );
      expect(accused, 'b');
    });

    test('role and secret word privacy exposes only current player state', () {
      const states = [
        OnlinePrivateStateView(
          playerId: 'p1',
          role: 'crew',
          secretWord: 'apple',
          guessOptions: null,
        ),
        OnlinePrivateStateView(
          playerId: 'p2',
          role: 'imposter',
          secretWord: null,
          guessOptions: ['apple', 'orange', 'pear', 'grape'],
        ),
      ];

      final p1View = OnlineSyncRules.visiblePrivateStateFor(
        currentPlayerId: 'p1',
        allStates: states,
      );
      final p2View = OnlineSyncRules.visiblePrivateStateFor(
        currentPlayerId: 'p2',
        allStates: states,
      );

      expect(p1View?.playerId, 'p1');
      expect(p1View?.role, 'crew');
      expect(p1View?.secretWord, 'apple');

      expect(p2View?.playerId, 'p2');
      expect(p2View?.role, 'imposter');
      expect(p2View?.secretWord, isNull);
      expect(p2View?.guessOptions?.length, 4);
    });

    test('reconnect routing and deterministic host transfer helper', () {
      expect(
        OnlineSyncRules.shouldResumeSession(roomStatus: 'lobby', roomPhase: 'lobby'),
        isTrue,
      );
      expect(
        OnlineSyncRules.shouldResumeSession(roomStatus: 'playing', roomPhase: 'voting'),
        isTrue,
      );
      expect(
        OnlineSyncRules.shouldResumeSession(roomStatus: 'finished', roomPhase: 'scoreboard'),
        isFalse,
      );

      expect(
        OnlineSyncRules.nextHostPlayerIdByJoinOrder(const ['u2', 'u3']),
        'u2',
      );
      expect(
        OnlineSyncRules.nextHostPlayerIdByJoinOrder(const []),
        isNull,
      );
    });
  });

  group('Online gameplay via GameEngine rules', () {
    test('role assignment uses existing engine rules', () async {
      final engine = GameEngine(
        players: [
          for (var i = 0; i < 5; i++) Player(id: 'p$i', name: 'P$i'),
        ],
        wordSource: _StubWordSource(),
      );

      await engine.startRound(categories.firstWhere((c) => c.id == 'food'));

      final imposters = engine.players.where((p) => p.isImposter).toList();
      expect(imposters.length, 1);
      expect(engine.secretWord, isNotNull);
    });

    test('scoring: caught + correct guess gives imposter +1', () {
      final engine = GameEngine(
        players: [
          Player(id: 'a', name: 'A'),
          Player(id: 'b', name: 'B'),
          Player(id: 'c', name: 'C'),
          Player(id: 'd', name: 'D'),
        ],
        wordSource: _StubWordSource(),
      );

      engine.category = categories.firstWhere((c) => c.id == 'food');
      engine.secretWord = 'elephant';

      engine.players[0].role = Role.imposter;
      engine.players[1].role = Role.crew;
      engine.players[2].role = Role.crew;
      engine.players[3].role = Role.crew;
      engine.imposter = engine.players[0];

      engine.castVote(voterId: 'a', targetId: 'b');
      engine.castVote(voterId: 'b', targetId: 'a');
      engine.castVote(voterId: 'c', targetId: 'a');
      engine.castVote(voterId: 'd', targetId: 'a');
      engine.submitImposterGuess('elephant');

      final result = engine.finishRound();

      expect(result.crewWins, isFalse);
      expect(result.guessedCorrectly, isTrue);
      expect(result.scoreChanges['a'], 1);
      expect(engine.players[0].score, 1);
    });

    test('next round reset preserves scores and clears round data', () {
      final engine = GameEngine(
        players: [
          Player(id: 'a', name: 'A', score: 2),
          Player(id: 'b', name: 'B', score: 1),
        ],
        wordSource: _StubWordSource(),
      );

      engine.secretWord = 'apple';
      engine.imposterGuess = 'apple';
      engine.votes.add(Vote(voterId: 'a', targetId: 'b'));

      engine.resetForNewRound();

      expect(engine.secretWord, isNull);
      expect(engine.votes, isEmpty);
      expect(engine.players[0].score, 2);
      expect(engine.players[1].score, 1);
    });
  });

  group('Word repository language routing', () {
    test('category IDs remain stable internal IDs', () {
      final ids = categories.map((c) => c.id).toSet();
      expect(ids, containsAll(const [
        'food',
        'animals',
        'sports',
        'movies',
        'places',
        'jobs',
        'objects',
        'games',
        'random',
        'celebrities',
      ]));
    });

    test('localized repository instance maps by language code', () {
      final en = WordRepository.instanceFor(const Locale('en'));
      final ar = WordRepository.instanceFor(const Locale('ar'));
      final ary = WordRepository.instanceFor(const Locale('ary'));

      expect(en.languageCode, 'en');
      expect(ar.languageCode, 'ar');
      expect(ary.languageCode, 'ary');
    });
  });
}
