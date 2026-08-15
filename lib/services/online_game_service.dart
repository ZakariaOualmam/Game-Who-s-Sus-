import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/categories.dart';
import '../game/game_engine.dart';
import '../models/game_settings.dart';
import '../models/online_game_phase.dart';
import '../models/online_player_round_state.dart';
import '../models/online_round.dart';
import '../models/player.dart';
import '../models/role.dart';
import '../models/room.dart';
import '../models/vote.dart';
import 'firebase_auth_service.dart';
import 'room_service.dart';
import 'word_repository.dart';

/// Service driving an online game round stored in Cloud Firestore.
///
/// Data layout:
/// - `rooms/{roomId}/rounds/{roundId}` round document
/// - `rooms/{roomId}/rounds/{roundId}/player_states/{playerId}` per-player
///   private state (role, secret word, guesses)
/// - `rooms/{roomId}/rounds/{roundId}/votes/{voterId}` votes
/// - `rooms/{roomId}/rounds/{roundId}/vote_totals/{targetPlayerId}` tallies
///
/// All timestamps are stored as UTC ISO-8601 strings.
class OnlineGameService {
  OnlineGameService({
    FirebaseFirestore? firestore,
    FirebaseAuthService? authService,
    RoomService? roomService,
    WordSource Function(Locale locale)? wordSourceProvider,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? FirebaseAuthService.instance,
        _roomService = roomService ?? RoomService.instance,
        _wordSourceProvider = wordSourceProvider ?? WordRepository.instanceFor;

  /// Swappable singleton so tests can inject fakes.
  static OnlineGameService instance = OnlineGameService();

  final FirebaseFirestore _firestore;
  final FirebaseAuthService _authService;
  final RoomService _roomService;
  final WordSource Function(Locale locale) _wordSourceProvider;

  DocumentReference<Map<String, dynamic>> _roomRef(String roomId) =>
      _firestore.collection('rooms').doc(roomId);

  CollectionReference<Map<String, dynamic>> _roundsRef(String roomId) =>
      _roomRef(roomId).collection('rounds');

  DocumentReference<Map<String, dynamic>> _roundRef(
    String roomId,
    String roundId,
  ) =>
      _roundsRef(roomId).doc(roundId);

  Future<Room> getRoomById(String roomId) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    if (!doc.exists) {
      throw Exception('Room not found');
    }
    return Room.fromMap(doc.data()!, id: doc.id);
  }

  Future<OnlineRound?> getActiveRound(String roomId) async {
    final room = await getRoomById(roomId);
    if (room.activeRoundId == null) return null;

    final doc = await _roundRef(roomId, room.activeRoundId!).get();
    if (!doc.exists) return null;
    return OnlineRound.fromMap(doc.data()!, id: doc.id);
  }

  Future<OnlinePlayerRoundState?> getMyRoundState({
    required String roomId,
    required String roundId,
  }) async {
    final uid = _authService.currentUid;
    if (uid == null) return null;

    final doc = await _roundRef(roomId, roundId)
        .collection('player_states')
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return OnlinePlayerRoundState.fromMap(doc.data()!, id: doc.id);
  }

  Future<Map<String, int>> getVoteTotals({
    required String roomId,
    required String roundId,
  }) async {
    final snapshot = await _roundRef(roomId, roundId)
        .collection('vote_totals')
        .get();

    final result = <String, int>{};
    for (final doc in snapshot.docs) {
      result[doc.data()['target_player_id'] as String] =
          doc.data()['vote_count'] as int;
    }
    return result;
  }

  Future<void> beginCategoryPhase(String roomId) async {
    await _updateRoomPhase(
      roomId: roomId,
      phase: OnlineGamePhase.category,
      roomStatus: 'playing',
    );
  }

  Future<void> startRoundFromCategory({
    required Room room,
    required String categoryId,
    required String languageCode,
  }) async {
    final players = await _roomService.getPlayersInRoom(room.id);
    if (players.length < GameSettings.minPlayers) {
      throw Exception(
        'Need at least ${GameSettings.minPlayers} players to start',
      );
    }

    final settings = room.settings;
    final issue = settings.validationIssue(actualPlayerCount: players.length);
    if (issue != null) {
      throw Exception('Invalid game settings: $issue');
    }
    if (players.length != settings.playerCount) {
      throw Exception(
        'Need ${settings.playerCount} players to start '
        '(${players.length} joined)',
      );
    }

    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => throw Exception('Invalid category: $categoryId'),
    );

    final enginePlayers = players
        .map((p) => Player(id: p.playerId, name: p.playerName, score: p.score))
        .toList();

    final wordSource = _wordSourceProvider(Locale(languageCode));
    final engine = GameEngine(
      players: enginePlayers,
      wordSource: wordSource,
      settings: settings,
    );

    await engine.startRound(category);
    final secretWord = engine.secretWord!;

    final decoys = await wordSource.decoyWords(
      category: category,
      correctWord: secretWord,
      count: 3,
    );

    final nextRoundNumber = room.currentRoundNumber + 1;
    final nowIso = DateTime.now().toUtc().toIso8601String();

    final roundRef = _roundsRef(room.id).doc();
    final imposterId = engine.imposter!.id;
    final options = ([secretWord, ...decoys]..shuffle(Random()))
        .take(4)
        .toList();

    final batch = _firestore.batch();
    batch.set(roundRef, {
      'room_id': room.id,
      'round_number': nextRoundNumber,
      'category_id': categoryId,
      'language_code': languageCode,
      'accused_player_id': null,
      'imposter_player_id': null,
      'winner_side': null,
      'guessed_correctly': null,
      'created_at': nowIso,
      'updated_at': nowIso,
    });

    for (final p in engine.players) {
      final isImposter = p.role == Role.imposter;
      batch.set(roundRef.collection('player_states').doc(p.id), {
        'round_id': roundRef.id,
        'room_id': room.id,
        'player_id': p.id,
        'role': isImposter ? 'imposter' : 'crew',
        'secret_word': isImposter ? null : secretWord,
        'guess_options': isImposter ? options : null,
        'reveal_ready': false,
        'discussion_ready': false,
        'submitted_guess': null,
        'created_at': nowIso,
        'updated_at': nowIso,
      });
    }

    batch.update(_roomRef(room.id), {
      'active_round_id': roundRef.id,
      'current_round_number': nextRoundNumber,
      'selected_category_id': categoryId,
      'game_phase': OnlineGamePhase.roleReveal.dbValue,
      'status': 'playing',
      'updated_at': nowIso,
    });

    await batch.commit();

    // Keep imposter private until reveal phase.
    debugPrint(
      'Started round $nextRoundNumber; imposter private for now: $imposterId',
    );
  }

  Future<void> setRevealReady({
    required String roomId,
    required String roundId,
    required bool ready,
  }) async {
    final uid = await _authService.requireUid();
    await _roundRef(roomId, roundId)
        .collection('player_states')
        .doc(uid)
        .update({
      'reveal_ready': ready,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> setDiscussionReady({
    required String roomId,
    required String roundId,
    required bool ready,
  }) async {
    final uid = await _authService.requireUid();
    await _roundRef(roomId, roundId)
        .collection('player_states')
        .doc(uid)
        .update({
      'discussion_ready': ready,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> hostTryAdvanceReveal(String roomId, String roundId) async {
    final room = await getRoomById(roomId);
    if (!await _isHost(room.id)) return;

    final players = await _roomService.getPlayersInRoom(roomId);
    final readyRows = await _roundRef(roomId, roundId)
        .collection('player_states')
        .where('reveal_ready', isEqualTo: true)
        .get();

    if (readyRows.docs.length >= players.length) {
      await _updateRoomPhase(roomId: roomId, phase: OnlineGamePhase.discussion);
    }
  }

  Future<void> hostTryAdvanceDiscussion(String roomId, String roundId) async {
    final room = await getRoomById(roomId);
    if (!await _isHost(room.id)) return;

    final players = await _roomService.getPlayersInRoom(roomId);
    final readyRows = await _roundRef(roomId, roundId)
        .collection('player_states')
        .where('discussion_ready', isEqualTo: true)
        .get();

    if (readyRows.docs.length >= players.length) {
      await _updateRoomPhase(roomId: roomId, phase: OnlineGamePhase.voting);
    }
  }

  Future<void> castVote({
    required String roomId,
    required String roundId,
    required String targetPlayerId,
  }) async {
    final uid = await _authService.requireUid();
    if (uid == targetPlayerId) {
      throw Exception('Cannot vote for yourself');
    }

    await _roundRef(roomId, roundId).collection('votes').doc(uid).set({
      'room_id': roomId,
      'round_id': roundId,
      'voter_player_id': uid,
      'target_player_id': targetPlayerId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> hostTryCompleteVoting(String roomId, String roundId) async {
    final room = await getRoomById(roomId);
    if (!await _isHost(room.id)) return;

    final players = await _roomService.getPlayersInRoom(roomId);
    final votes = await _roundRef(roomId, roundId).collection('votes').get();
    if (votes.docs.length < players.length) return;

    final counts = <String, int>{};
    for (final doc in votes.docs) {
      final targetId = doc.data()['target_player_id'] as String;
      counts[targetId] = (counts[targetId] ?? 0) + 1;
    }

    var top = 0;
    for (final value in counts.values) {
      if (value > top) top = value;
    }
    final topPlayers = counts.entries.where((e) => e.value == top).toList();
    final accusedPlayerId = topPlayers.length == 1 ? topPlayers.first.key : null;

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final batch = _firestore.batch();

    final totalsSnapshot = await _roundRef(roomId, roundId)
        .collection('vote_totals')
        .get();
    for (final doc in totalsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    counts.forEach((targetId, voteCount) {
      batch.set(_roundRef(roomId, roundId).collection('vote_totals').doc(targetId), {
        'room_id': roomId,
        'round_id': roundId,
        'target_player_id': targetId,
        'vote_count': voteCount,
      });
    });

    batch.update(_roundRef(roomId, roundId), {
      'accused_player_id': accusedPlayerId,
      'updated_at': nowIso,
    });
    batch.update(_roomRef(roomId), {
      'game_phase': OnlineGamePhase.voteResults.dbValue,
      'updated_at': nowIso,
    });

    await batch.commit();
  }

  Future<void> hostRevealImposter(String roomId, String roundId) async {
    final room = await getRoomById(roomId);
    if (!await _isHost(room.id)) return;

    final states = await _roundRef(roomId, roundId)
        .collection('player_states')
        .where('role', isEqualTo: 'imposter')
        .limit(1)
        .get();
    if (states.docs.isEmpty) {
      throw Exception('Imposter state not found');
    }
    final imposterPlayerId = states.docs.first.id;

    final nowIso = DateTime.now().toUtc().toIso8601String();
    await _firestore.runTransaction((txn) async {
      txn.update(_roundRef(roomId, roundId), {
        'imposter_player_id': imposterPlayerId,
        'updated_at': nowIso,
      });
      txn.update(_roomRef(roomId), {
        'game_phase': OnlineGamePhase.imposterReveal.dbValue,
        'updated_at': nowIso,
      });
    });
  }

  Future<void> advanceToImposterGuess(String roomId) async {
    await _updateRoomPhase(roomId: roomId, phase: OnlineGamePhase.imposterGuess);
  }

  Future<void> submitImposterGuess({
    required String roomId,
    required String roundId,
    required String guess,
  }) async {
    final uid = await _authService.requireUid();
    await _roundRef(roomId, roundId)
        .collection('player_states')
        .doc(uid)
        .update({
      'submitted_guess': guess.trim(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> finalizeRoundWithGameEngine({
    required String roomId,
    required String roundId,
  }) async {
    final room = await getRoomById(roomId);
    if (!await _isHost(room.id)) {
      throw Exception('Only host can finalize round');
    }

    final players = await _roomService.getPlayersInRoom(roomId);
    final states = await _roundRef(roomId, roundId)
        .collection('player_states')
        .get();
    final roundDoc = await _roundRef(roomId, roundId).get();
    if (!roundDoc.exists) {
      throw Exception('Round not found');
    }
    final round = OnlineRound.fromMap(roundDoc.data()!, id: roundDoc.id);
    final votes = await _roundRef(roomId, roundId).collection('votes').get();

    final playerMap = {
      for (final p in players)
        p.playerId: Player(id: p.playerId, name: p.playerName, score: p.score),
    };

    final enginePlayers = playerMap.values.toList();
    final engine = GameEngine(
      players: enginePlayers,
      wordSource: _wordSourceProvider(Locale(round.languageCode)),
      settings: room.settings,
    );

    final category = categories.firstWhere((c) => c.id == round.categoryId);
    engine.category = category;

    for (final doc in states.docs) {
      final data = doc.data();
      final playerId = data['player_id'] as String;
      final role = data['role'] as String;
      final secretWord = data['secret_word'] as String?;
      final submittedGuess = data['submitted_guess'] as String?;

      final player = playerMap[playerId]!;
      player.role = role == 'imposter' ? Role.imposter : Role.crew;
      if (role == 'imposter' &&
          submittedGuess != null &&
          submittedGuess.isNotEmpty) {
        engine.submitImposterGuess(submittedGuess);
      }
      if (engine.secretWord == null && secretWord != null) {
        engine.secretWord = secretWord;
      }
    }

    final imposter = engine.players.firstWhere((p) => p.isImposter);
    engine.imposter = imposter;

    for (final doc in votes.docs) {
      engine.votes.add(
        Vote(
          voterId: doc.data()['voter_player_id'] as String,
          targetId: doc.data()['target_player_id'] as String,
        ),
      );
    }

    if (engine.secretWord == null) {
      throw Exception('Round secret word missing; cannot finalize');
    }

    final result = engine.finishRound();
    final nowIso = DateTime.now().toUtc().toIso8601String();

    final batch = _firestore.batch();
    for (final p in engine.players) {
      batch.update(_roomRef(roomId).collection('players').doc(p.id), {
        'score': p.score,
        'updated_at': nowIso,
      });
    }

    batch.update(_roundRef(roomId, roundId), {
      'winner_side': result.crewWins ? 'crew' : 'imposter',
      'guessed_correctly': result.guessedCorrectly,
      'imposter_player_id': result.imposter.id,
      'updated_at': nowIso,
    });
    batch.update(_roomRef(roomId), {
      'game_phase': OnlineGamePhase.winner.dbValue,
      'updated_at': nowIso,
    });

    await batch.commit();
  }

  Future<void> advanceToScoreboard(String roomId) async {
    await _updateRoomPhase(roomId: roomId, phase: OnlineGamePhase.scoreboard);
  }

  Future<void> startNextRound(String roomId) async {
    final room = await getRoomById(roomId);
    if (!await _isHost(room.id)) {
      throw Exception('Only host can start next round');
    }

    await _roomRef(roomId).update({
      'game_phase': OnlineGamePhase.category.dbValue,
      'active_round_id': null,
      'selected_category_id': null,
      'status': 'playing',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> _updateRoomPhase({
    required String roomId,
    required OnlineGamePhase phase,
    String? roomStatus,
  }) async {
    final payload = <String, dynamic>{
      'game_phase': phase.dbValue,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (roomStatus != null) {
      payload['status'] = roomStatus;
    }
    await _roomRef(roomId).update(payload);
  }

  Future<bool> _isHost(String roomId) async {
    final uid = _authService.currentUid;
    if (uid == null) return false;
    final room = await getRoomById(roomId);
    return room.hostPlayerId == uid;
  }

  /// Subscribes to all Firestore data that can change during a game round.
  /// Call [RoomSubscription.unsubscribe] when done.
  RoomSubscription subscribeToGameRoom({
    required String roomId,
    required VoidCallback onAnyChange,
  }) {
    final roomRef = _roomRef(roomId);
    final subscriptions = <StreamSubscription<dynamic>>[];
    final roundSubscriptions = <StreamSubscription<dynamic>>[];

    void onError(Object error, StackTrace stack) {
      debugPrint('Failed to stream game room $roomId: $error');
    }

    // Follows the room's active round and subscribes to its subcollections.
    // Collection-group queries cannot be authorized to a single room, so the
    // round's subcollections are watched through scoped queries instead.
    String? activeRoundId;
    void listenRound(String? roundId) {
      if (roundId == activeRoundId) return;
      for (final sub in roundSubscriptions) {
        sub.cancel();
      }
      roundSubscriptions.clear();
      activeRoundId = roundId;
      if (roundId == null) return;

      final roundRef = _roundRef(roomId, roundId);
      for (final collection in ['player_states', 'votes', 'vote_totals']) {
        final sub = roundRef
            .collection(collection)
            .snapshots()
            .listen(
              (_) => onAnyChange(),
              onError: onError,
            );
        roundSubscriptions.add(sub);
        subscriptions.add(sub);
      }
    }

    subscriptions.add(roomRef.snapshots().listen(
      (snapshot) {
        listenRound(snapshot.data()?['active_round_id'] as String?);
        onAnyChange();
      },
      onError: onError,
    ));
    subscriptions.add(
      _roundsRef(roomId).snapshots().listen(
            (_) => onAnyChange(),
            onError: onError,
          ),
    );

    return RoomSubscription(subscriptions);
  }
}
