import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/data/categories.dart';
import 'package:who_sus/models/game_settings.dart';
import 'package:who_sus/services/firebase_auth_service.dart';
import 'package:who_sus/services/online_game_service.dart';
import 'package:who_sus/services/room_service.dart';
import 'package:who_sus/services/word_repository.dart';

import 'helpers/settling_firestore.dart';

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

MockFirebaseAuth _authFor(String uid) {
  return MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(uid: uid, isAnonymous: true),
  );
}

FirebaseAuthService _authService(MockFirebaseAuth auth) =>
    FirebaseAuthService.forTesting(auth);

class _PlayerContext {
  _PlayerContext(this.uid, this.auth, SettlingFirestore firestore)
      : roomService = RoomService(
          firestore: firestore,
          authService: _authService(auth),
        ),
        gameService = OnlineGameService(
          firestore: firestore,
          authService: _authService(auth),
          roomService: RoomService(
            firestore: firestore,
            authService: _authService(auth),
          ),
          wordSourceProvider: (_) => _StubWordSource(),
        );

  final String uid;
  final MockFirebaseAuth auth;
  final RoomService roomService;
  final OnlineGameService gameService;
}

void main() {
  late SettlingFirestore f;
  late _PlayerContext alice;
  late _PlayerContext bob;
  late _PlayerContext cara;
  late _PlayerContext dave;

  setUp(() {
    f = SettlingFirestore();
    alice = _PlayerContext('alice', _authFor('alice'), f);
    bob = _PlayerContext('bob', _authFor('bob'), f);
    cara = _PlayerContext('cara', _authFor('cara'), f);
    dave = _PlayerContext('dave', _authFor('dave'), f);
  });

  Future<(String roomId, String roundId, String imposterId, String secretWord)>
      setupRound({String categoryId = 'animals'}) async {
    final created = await alice.roomService.createRoom(playerName: 'Alice');
    await bob.roomService.joinRoom(roomCode: created.room.code, playerName: 'Bob');
    await cara.roomService.joinRoom(roomCode: created.room.code, playerName: 'Cara');
    await dave.roomService.joinRoom(roomCode: created.room.code, playerName: 'Dave');

    await alice.gameService.startRoundFromCategory(
      room: created.room,
      categoryId: categoryId,
      languageCode: 'en',
    );

    final room = await alice.gameService.getRoomById(created.room.id);
    final roundId = room.activeRoundId!;

    final states = await f
        .collection('rooms')
        .doc(created.room.id)
        .collection('rounds')
        .doc(roundId)
        .collection('player_states')
        .get();

    final imposter = states.docs.firstWhere((d) => d.data()['role'] == 'imposter');
    final secret = states.docs.firstWhere(
      (d) => d.data()['role'] == 'crew',
    ).data()['secret_word'] as String;

    return (created.room.id, roundId, imposter.id, secret);
  }

  group('OnlineGameService.startRoundFromCategory', () {
    test('creates a round, assigns states, and enters role_reveal phase',
        () async {
      final created = await alice.roomService.createRoom(playerName: 'Alice');
      await bob.roomService.joinRoom(roomCode: created.room.code, playerName: 'Bob');
      await cara.roomService.joinRoom(roomCode: created.room.code, playerName: 'Cara');
      await dave.roomService.joinRoom(roomCode: created.room.code, playerName: 'Dave');

      await alice.gameService.startRoundFromCategory(
        room: created.room,
        categoryId: 'animals',
        languageCode: 'en',
      );

      final room = await alice.gameService.getRoomById(created.room.id);
      expect(room.gamePhase, 'role_reveal');
      expect(room.status, 'playing');
      expect(room.currentRoundNumber, 1);
      expect(room.activeRoundId, isNotNull);
      expect(room.selectedCategoryId, 'animals');

      final states = await f
          .collection('rooms')
          .doc(created.room.id)
          .collection('rounds')
          .doc(room.activeRoundId)
          .collection('player_states')
          .get();
      expect(states.docs.length, 4);
      expect(states.docs.where((d) => d.data()['role'] == 'imposter').length, 1);

      final myState = await alice.gameService.getMyRoundState(
        roomId: created.room.id,
        roundId: room.activeRoundId!,
      );
      expect(myState, isNotNull);
    });

    test('requires at least 4 players', () async {
      final created = await alice.roomService.createRoom(playerName: 'Alice');
      await bob.roomService.joinRoom(roomCode: created.room.code, playerName: 'Bob');

      await expectLater(
        alice.gameService.startRoundFromCategory(
          room: created.room,
          categoryId: 'animals',
          languageCode: 'en',
        ),
        throwsA(predicate((Object e) => e.toString().contains('at least 4'))),
      );
    });

    test('waits until the room fills to the configured player count', () async {
      final created = await alice.roomService.createRoom(playerName: 'Alice');
      await bob.roomService.joinRoom(roomCode: created.room.code, playerName: 'Bob');
      await cara.roomService.joinRoom(roomCode: created.room.code, playerName: 'Cara');
      await dave.roomService.joinRoom(roomCode: created.room.code, playerName: 'Dave');

      await alice.roomService.updateGameSettings(
        roomId: created.room.id,
        settings: const GameSettings(playerCount: 6),
      );

      // The passed room reflects the current Firestore settings, so the
      // service refuses to start a 4-player game for a room that expects 6.
      final fresh = await alice.gameService.getRoomById(created.room.id);
      await expectLater(
        alice.gameService.startRoundFromCategory(
          room: fresh,
          categoryId: 'animals',
          languageCode: 'en',
        ),
        throwsA(predicate((Object e) => e.toString().contains('Need 6'))),
      );
    });

    test('blocks unsupported imposter counts', () async {
      final created = await alice.roomService.createRoom(playerName: 'Alice');
      await bob.roomService.joinRoom(roomCode: created.room.code, playerName: 'Bob');
      await cara.roomService.joinRoom(roomCode: created.room.code, playerName: 'Cara');
      await dave.roomService.joinRoom(roomCode: created.room.code, playerName: 'Dave');

      await alice.roomService.updateGameSettings(
        roomId: created.room.id,
        settings: const GameSettings(playerCount: 4, imposterCount: 2),
      );

      final fresh = await alice.gameService.getRoomById(created.room.id);
      await expectLater(
        alice.gameService.startRoundFromCategory(
          room: fresh,
          categoryId: 'animals',
          languageCode: 'en',
        ),
        throwsA(predicate(
          (Object e) => e.toString().contains('Invalid game settings'),
        )),
      );
    });
  });

  group('OnlineGameService timer-driven host transitions', () {
    Future<(String, String)> advanceToDiscussion() async {
      final (roomId, roundId, _, _) = await setupRound();
      for (final player in [alice, bob, cara, dave]) {
        await player.gameService.setRevealReady(
          roomId: roomId,
          roundId: roundId,
          ready: true,
        );
      }
      await alice.gameService.hostTryAdvanceReveal(roomId, roundId);
      return (roomId, roundId);
    }

    Future<(String, String)> advanceToVoting() async {
      final (roomId, roundId) = await advanceToDiscussion();
      for (final player in [alice, bob, cara, dave]) {
        await player.gameService.setDiscussionReady(
          roomId: roomId,
          roundId: roundId,
          ready: true,
        );
      }
      await alice.gameService.hostTryAdvanceDiscussion(roomId, roundId);
      return (roomId, roundId);
    }

    test('hostEndDiscussion advances even when not everyone is ready',
        () async {
      final (roomId, roundId) = await advanceToDiscussion();

      // No player pressed ready; the timer still ends the phase.
      await alice.gameService.hostEndDiscussion(roomId, roundId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'voting',
      );
    });

    test('hostEndDiscussion is a no-op for non-host players', () async {
      final (roomId, roundId) = await advanceToDiscussion();

      await bob.gameService.hostEndDiscussion(roomId, roundId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'discussion',
      );
    });

    test('hostEndDiscussion is a no-op outside the discussion phase',
        () async {
      final (roomId, roundId, _, _) = await setupRound();

      await alice.gameService.hostEndDiscussion(roomId, roundId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'role_reveal',
      );
    });

    test('hostEndVoting finalizes with partial votes when time runs out',
        () async {
      final (roomId, roundId) = await advanceToVoting();

      // Only one player votes before the timer expires.
      await alice.gameService.castVote(
        roomId: roomId,
        roundId: roundId,
        targetPlayerId: 'bob',
      );

      await alice.gameService.hostEndVoting(roomId, roundId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'vote_results',
      );

      final round = await f
          .collection('rooms')
          .doc(roomId)
          .collection('rounds')
          .doc(roundId)
          .get();
      expect(round.data()!['accused_player_id'], 'bob');

      final totals = await alice.gameService.getVoteTotals(
        roomId: roomId,
        roundId: roundId,
      );
      expect(totals, {'bob': 1});
    });

    test('hostEndVoting with no ballots ends in a tie', () async {
      final (roomId, roundId) = await advanceToVoting();

      await alice.gameService.hostEndVoting(roomId, roundId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'vote_results',
      );

      final round = await f
          .collection('rooms')
          .doc(roomId)
          .collection('rounds')
          .doc(roundId)
          .get();
      expect(round.data()!['accused_player_id'], isNull);
    });

    test('hostEndVoting is idempotent', () async {
      final (roomId, roundId) = await advanceToVoting();

      await alice.gameService.castVote(
        roomId: roomId,
        roundId: roundId,
        targetPlayerId: 'bob',
      );
      await alice.gameService.hostEndVoting(roomId, roundId);
      await alice.gameService.hostEndVoting(roomId, roundId);

      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'vote_results',
      );
      final totals = await alice.gameService.getVoteTotals(
        roomId: roomId,
        roundId: roundId,
      );
      expect(totals, {'bob': 1});
    });

    test('hostEndVoting is a no-op for non-host players', () async {
      final (roomId, roundId) = await advanceToVoting();

      await bob.gameService.hostEndVoting(roomId, roundId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'voting',
      );
    });
  });

  group('OnlineGameService full round', () {
    test('runs reveal -> discussion -> voting -> results -> imposter guess -> winner',
        () async {
      final (roomId, roundId, imposterId, secretWord) = await setupRound();

      // Reveal: everyone becomes ready, host advances to discussion.
      for (final player in [alice, bob, cara, dave]) {
        await player.gameService.setRevealReady(
          roomId: roomId,
          roundId: roundId,
          ready: true,
        );
      }
      await alice.gameService.hostTryAdvanceReveal(roomId, roundId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'discussion',
      );

      // Discussion: everyone becomes ready, host advances to voting.
      for (final player in [alice, bob, cara, dave]) {
        await player.gameService.setDiscussionReady(
          roomId: roomId,
          roundId: roundId,
          ready: true,
        );
      }
      await alice.gameService.hostTryAdvanceDiscussion(roomId, roundId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'voting',
      );

      // Voting: crew members accuse the imposter, the imposter deflects to
      // a crew member (never themselves, whoever got the role).
      for (final player in [alice, bob, cara, dave]) {
        if (player.uid == imposterId) {
          final target = [alice, bob, cara, dave]
              .firstWhere((p) => p.uid != imposterId)
              .uid;
          await player.gameService.castVote(
            roomId: roomId,
            roundId: roundId,
            targetPlayerId: target,
          );
        } else {
          await player.gameService.castVote(
            roomId: roomId,
            roundId: roundId,
            targetPlayerId: imposterId,
          );
        }
      }
      await alice.gameService.hostTryCompleteVoting(roomId, roundId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'vote_results',
      );

      final round = await f
          .collection('rooms')
          .doc(roomId)
          .collection('rounds')
          .doc(roundId)
          .get();
      expect(round.data()!['accused_player_id'], imposterId);

      final totals = await alice.gameService.getVoteTotals(
        roomId: roomId,
        roundId: roundId,
      );
      expect(totals[imposterId], 3);

      // Host reveals the imposter.
      await alice.gameService.hostRevealImposter(roomId, roundId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'imposter_reveal',
      );

      // Imposter was caught: they get a final guess.
      await alice.gameService.advanceToImposterGuess(roomId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'imposter_guess',
      );

      final imposterCtx =
          [alice, bob, cara, dave].firstWhere((p) => p.uid == imposterId);
      await imposterCtx.gameService.submitImposterGuess(
        roomId: roomId,
        roundId: roundId,
        guess: secretWord,
      );

      await alice.gameService.finalizeRoundWithGameEngine(
        roomId: roomId,
        roundId: roundId,
      );
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'winner',
      );

      final finalized = await f
          .collection('rooms')
          .doc(roomId)
          .collection('rounds')
          .doc(roundId)
          .get();
      final data = finalized.data()!;
      // Caught + correct guess: imposter wins the round and gains a point.
      expect(data['winner_side'], 'imposter');
      expect(data['guessed_correctly'], isTrue);
      expect(data['imposter_player_id'], imposterId);

      final imposterPlayer = await f
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc(imposterId)
          .get();
      expect(imposterPlayer.data()!['score'], 1);

      // Scoreboard, then next round returns to category selection.
      await alice.gameService.advanceToScoreboard(roomId);
      expect(
        (await alice.gameService.getRoomById(roomId)).gamePhase,
        'scoreboard',
      );

      await alice.gameService.startNextRound(roomId);
      final afterNext = await alice.gameService.getRoomById(roomId);
      expect(afterNext.gamePhase, 'category');
      expect(afterNext.activeRoundId, isNull);
    });

    test('non-host players cannot finalize a round', () async {
      final (roomId, roundId, imposterId, _) = await setupRound();

      await expectLater(
        bob.gameService.finalizeRoundWithGameEngine(
          roomId: roomId,
          roundId: roundId,
        ),
        throwsA(predicate((Object e) => e.toString().contains('Only host'))),
      );
    });
  });
}
