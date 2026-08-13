import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/game_settings.dart';
import '../models/online_game_phase.dart';
import '../models/room.dart';
import '../models/room_player.dart';
import 'firebase_auth_service.dart';

/// A disposable group of Firestore stream subscriptions used for realtime
/// room and game updates.
class RoomSubscription {
  RoomSubscription(this._subscriptions);

  final List<StreamSubscription<dynamic>> _subscriptions;

  /// Cancels all underlying stream subscriptions.
  Future<void> unsubscribe() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
  }

  Future<void> cancel() => unsubscribe();
}

/// Thrown internally when a generated room code already exists.
class _RoomCodeTakenException implements Exception {}

/// Service for managing online multiplayer rooms in Cloud Firestore.
///
/// Data layout:
/// - `rooms/{roomId}` the room document
/// - `rooms/{roomId}/players/{playerId}` one document per player
/// - `rooms_by_code/{code}` uniqueness index for room codes
///
/// All timestamps are stored as UTC ISO-8601 strings.
class RoomService {
  RoomService({FirebaseFirestore? firestore, FirebaseAuthService? authService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? FirebaseAuthService.instance;

  /// Swappable singleton so tests can inject fakes.
  static RoomService instance = RoomService();

  final FirebaseFirestore _firestore;
  final FirebaseAuthService _authService;

  CollectionReference<Map<String, dynamic>> get _roomsRef =>
      _firestore.collection('rooms');

  DocumentReference<Map<String, dynamic>> _roomRef(String roomId) =>
      _roomsRef.doc(roomId);

  DocumentReference<Map<String, dynamic>> _codeRef(String code) =>
      _firestore.collection('rooms_by_code').doc(code);

  Future<void> _ensureUserNotInAnotherActiveRoom(String userId) async {
    final snapshot = await _firestore
        .collectionGroup('players')
        .where('player_id', isEqualTo: userId)
        .limit(10)
        .get();

    for (final doc in snapshot.docs) {
      final roomId = doc.data()['room_id'] as String?;
      if (roomId == null) continue;

      final roomDoc = await _firestore.doc('rooms/$roomId').get();
      if (!roomDoc.exists) continue;
      final status = roomDoc.data()?['status'] as String?;
      if (status == 'lobby' || status == 'playing') {
        throw Exception('You are already in another active room');
      }
    }
  }

  /// Generates a unique 6-character uppercase room code (e.g., "A3X9K2").
  /// Uses alphanumeric characters excluding ambiguous ones (0, O, I, 1).
  String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No 0, O, I, 1
    final random = Random();
    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Creates a new room with the current user as host.
  /// Returns the created room and the host player record.
  ///
  /// Throws if not authenticated or if room creation fails.
  Future<({Room room, RoomPlayer hostPlayer})> createRoom({
    required String playerName,
  }) async {
    final uid = await _authService.requireUid();
    if (playerName.trim().isEmpty) {
      throw Exception('Player name cannot be empty');
    }

    await _ensureUserNotInAnotherActiveRoom(uid);

    var attempts = 0;
    const maxAttempts = 10;
    while (attempts < maxAttempts) {
      final code = generateRoomCode();
      try {
        return await _createRoomWithCode(
          code: code,
          uid: uid,
          playerName: playerName.trim(),
        );
      } on _RoomCodeTakenException {
        attempts++;
        debugPrint('Room code collision, retrying ($attempts/$maxAttempts)');
      }
    }

    throw Exception(
      'Failed to generate unique room code after $maxAttempts attempts',
    );
  }

  Future<({Room room, RoomPlayer hostPlayer})> _createRoomWithCode({
    required String code,
    required String uid,
    required String playerName,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final roomRef = _roomsRef.doc();

    await _firestore.runTransaction((txn) async {
      final codeSnap = await txn.get(_codeRef(code));
      if (codeSnap.exists) {
        throw _RoomCodeTakenException();
      }

      txn.set(_codeRef(code), {
        'room_id': roomRef.id,
        'created_at': nowIso,
      });
      txn.set(roomRef, {
        'code': code,
        'host_player_id': uid,
        'status': 'lobby',
        'game_phase': OnlineGamePhase.lobby.dbValue,
        'max_players': GameSettings.maxPlayers,
        'current_round_number': 0,
        'active_round_id': null,
        'selected_category_id': null,
        'player_count': 1,
        'created_at': nowIso,
        'updated_at': nowIso,
      });
      txn.set(roomRef.collection('players').doc(uid), {
        'room_id': roomRef.id,
        'player_id': uid,
        'player_name': playerName,
        'is_host': true,
        'score': 0,
        'is_connected': true,
        'last_seen': nowIso,
        'joined_at': nowIso,
      });
    });

    final room = Room.fromMap(
      {
        'code': code,
        'host_player_id': uid,
        'status': 'lobby',
        'game_phase': OnlineGamePhase.lobby.dbValue,
        'max_players': GameSettings.maxPlayers,
        'current_round_number': 0,
        'active_round_id': null,
        'selected_category_id': null,
        'created_at': nowIso,
        'updated_at': nowIso,
      },
      id: roomRef.id,
    );
    final hostPlayer = RoomPlayer.fromMap(
      {
        'room_id': roomRef.id,
        'player_id': uid,
        'player_name': playerName,
        'is_host': true,
        'score': 0,
        'is_connected': true,
        'last_seen': nowIso,
        'joined_at': nowIso,
      },
      id: uid,
    );
    debugPrint('Created room ${room.code} with ID ${room.id}');
    return (room: room, hostPlayer: hostPlayer);
  }

  /// Finds a room by its 6-character code.
  /// Returns null if the room doesn't exist or is not in the lobby.
  Future<Room?> findRoomByCode(String code) async {
    final snapshot = await _roomsRef
        .where('code', isEqualTo: code.toUpperCase())
        .where('status', isEqualTo: 'lobby')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Room.fromMap(doc.data(), id: doc.id);
  }

  /// Joins an existing room.
  /// Returns the room and the new player record.
  ///
  /// Throws if:
  /// - Not authenticated
  /// - Room doesn't exist
  /// - Room is full
  /// - Room is not in lobby status
  Future<({Room room, RoomPlayer player})> joinRoom({
    required String roomCode,
    required String playerName,
  }) async {
    final uid = await _authService.requireUid();
    if (playerName.trim().isEmpty) {
      throw Exception('Player name cannot be empty');
    }

    await _ensureUserNotInAnotherActiveRoom(uid);

    final room = await findRoomByCode(roomCode);
    if (room == null) {
      throw Exception('Room not found');
    }

    final playerNameTrimmed = playerName.trim();
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final roomRef = _roomRef(room.id);

    await _firestore.runTransaction((txn) async {
      final roomSnap = await txn.get(roomRef);
      final roomData = roomSnap.data();
      if (roomData == null) {
        throw Exception('Room not found');
      }
      if (roomData['status'] != 'lobby') {
        throw Exception('Room is not accepting players');
      }
      final playerCount = (roomData['player_count'] as int?) ?? 1;
      final maxPlayers =
          (roomData['max_players'] as int?) ?? GameSettings.maxPlayers;
      if (playerCount >= maxPlayers) {
        throw Exception('Room is full');
      }

      final playerRef = roomRef.collection('players').doc(uid);
      final playerSnap = await txn.get(playerRef);
      if (playerSnap.exists) {
        throw Exception('You are already in this room');
      }

      txn.set(playerRef, {
        'room_id': room.id,
        'player_id': uid,
        'player_name': playerNameTrimmed,
        'is_host': false,
        'score': 0,
        'is_connected': true,
        'last_seen': nowIso,
        'joined_at': nowIso,
      });
      txn.update(roomRef, {
        'player_count': playerCount + 1,
        'updated_at': nowIso,
      });
    });

    final player = RoomPlayer.fromMap(
      {
        'room_id': room.id,
        'player_id': uid,
        'player_name': playerNameTrimmed,
        'is_host': false,
        'score': 0,
        'is_connected': true,
        'last_seen': nowIso,
        'joined_at': nowIso,
      },
      id: uid,
    );
    debugPrint('Player ${player.playerName} joined room ${room.code}');
    return (room: room, player: player);
  }

  /// Gets all players in a room, ordered by join time.
  Future<List<RoomPlayer>> getPlayersInRoom(String roomId) async {
    final snapshot = await _roomRef(roomId)
        .collection('players')
        .orderBy('joined_at')
        .get();

    return snapshot.docs
        .map((doc) => RoomPlayer.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  /// Finds the current user's most recent active room, if any.
  Future<({Room room, RoomPlayer player})?> findMyActiveRoom() async {
    final uid = _authService.currentUid;
    if (uid == null) return null;

    final snapshot = await _firestore
        .collectionGroup('players')
        .where('player_id', isEqualTo: uid)
        .limit(10)
        .get();

    for (final doc in snapshot.docs) {
      final player = RoomPlayer.fromMap(doc.data(), id: doc.id);
      final roomDoc = await _firestore.doc('rooms/${player.roomId}').get();
      if (!roomDoc.exists) continue;

      final room = Room.fromMap(roomDoc.data()!, id: roomDoc.id);
      if (room.status == 'lobby' || room.status == 'playing') {
        return (room: room, player: player);
      }
    }
    return null;
  }

  /// Removes the current user from a room.
  /// If the leaving player is the host, host is transferred to the oldest
  /// remaining player; the room is deleted when nobody is left.
  Future<void> leaveRoom({
    required String roomId,
    required bool isHost,
  }) async {
    final uid = await _authService.requireUid();
    final roomRef = _roomRef(roomId);
    final nowIso = DateTime.now().toUtc().toIso8601String();

    if (isHost) {
      final playersSnapshot = await roomRef
          .collection('players')
          .orderBy('joined_at')
          .get();
      final remaining =
          playersSnapshot.docs.where((d) => d.id != uid).toList();

      if (remaining.isEmpty) {
        final roomDoc = await roomRef.get();
        final code = roomDoc.data()?['code'] as String?;

        await _firestore.runTransaction((txn) async {
          txn.delete(roomRef);
          if (code != null) {
            txn.delete(_codeRef(code));
          }
        });
        debugPrint('Host left, room $roomId deleted (no remaining players)');
        return;
      }

      final nextHost =
          RoomPlayer.fromMap(remaining.first.data(), id: remaining.first.id);

      await _firestore.runTransaction((txn) async {
        txn.update(roomRef, {
          'host_player_id': nextHost.playerId,
          'updated_at': nowIso,
        });
        txn.update(roomRef.collection('players').doc(uid), {
          'is_host': false,
        });
        txn.delete(roomRef.collection('players').doc(uid));
        txn.update(roomRef.collection('players').doc(nextHost.playerId), {
          'is_host': true,
        });
      });

      // Decrement the counter after removing the player document.
      final roomSnap = await roomRef.get();
      final currentCount =
          (roomSnap.data()?['player_count'] as int?) ?? 2;
      await roomRef.update({
        'player_count': (currentCount - 1).clamp(0, GameSettings.maxPlayers),
        'updated_at': nowIso,
      });

      debugPrint(
        'Host left room $roomId, transferred host to ${nextHost.playerId}',
      );
    } else {
      await _firestore.runTransaction((txn) async {
        txn.delete(roomRef.collection('players').doc(uid));
      });

      final roomSnap = await roomRef.get();
      final currentCount = (roomSnap.data()?['player_count'] as int?) ?? 1;
      await roomRef.update({
        'player_count': (currentCount - 1).clamp(0, GameSettings.maxPlayers),
        'updated_at': nowIso,
      });
      debugPrint('Player left room $roomId');
    }
  }

  /// Subscribes to realtime changes in a room's player list and status.
  ///
  /// Call [RoomSubscription.unsubscribe] when done.
  RoomSubscription subscribeToRoom({
    required String roomId,
    required void Function(RoomPlayer player) onPlayerJoined,
    required void Function(String playerId) onPlayerLeft,
    void Function(String status)? onRoomStatusChanged,
    VoidCallback? onRoomClosed,
  }) {
    final roomRef = _roomRef(roomId);
    final playersRef = roomRef.collection('players').orderBy('joined_at');

    var knownPlayers = <String, RoomPlayer>{};
    var lastStatus = '';
    final subscriptions = <StreamSubscription<dynamic>>[];

    subscriptions.add(playersRef.snapshots().listen(
      (snapshot) {
        final current = <String, RoomPlayer>{
          for (final doc in snapshot.docs)
            doc.id: RoomPlayer.fromMap(doc.data(), id: doc.id),
        };

        for (final entry in current.entries) {
          if (!knownPlayers.containsKey(entry.key)) {
            debugPrint('Realtime: Player ${entry.value.playerName} joined room');
            onPlayerJoined(entry.value);
          }
        }
        for (final oldId in knownPlayers.keys) {
          if (!current.containsKey(oldId)) {
            debugPrint('Realtime: Player $oldId left room');
            onPlayerLeft(oldId);
          }
        }
        knownPlayers = current;
      },
      onError: (Object error) {
        debugPrint('Failed to stream players for room $roomId: $error');
      },
    ));

    subscriptions.add(roomRef.snapshots().listen(
      (snapshot) {
        final data = snapshot.data();
        if (data == null) {
          debugPrint('Realtime: Room $roomId deleted');
          onRoomClosed?.call();
          return;
        }
        final status = data['status'] as String? ?? '';
        if (status != lastStatus) {
          lastStatus = status;
          debugPrint('Realtime: Room $roomId status changed to $status');
          onRoomStatusChanged?.call(status);
        }
      },
      onError: (Object error) {
        debugPrint('Failed to stream room $roomId: $error');
      },
    ));

    return RoomSubscription(subscriptions);
  }

  /// Updates room status (e.g., from 'lobby' to 'playing').
  /// Only the host can update the room status.
  Future<void> updateRoomStatus({
    required String roomId,
    required String newStatus,
  }) async {
    final uid = await _authService.requireUid();
    final roomRef = _roomRef(roomId);

    final roomDoc = await roomRef.get();
    final roomData = roomDoc.data();
    if (roomData == null) {
      throw Exception('Room not found');
    }
    if (roomData['host_player_id'] != uid) {
      throw Exception('Only the host can start this room');
    }

    await roomRef.update({
      'status': newStatus,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    debugPrint('Room $roomId status updated to $newStatus');
  }
}
