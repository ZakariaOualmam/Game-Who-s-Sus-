import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordimposter/services/firebase_auth_service.dart';
import 'package:wordimposter/services/room_service.dart';

import 'helpers/settling_firestore.dart';

MockFirebaseAuth _authFor(String uid) {
  return MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(uid: uid, isAnonymous: true),
  );
}

FirebaseAuthService _authService(MockFirebaseAuth auth) =>
    FirebaseAuthService.forTesting(auth);

Matcher _throwsWithMessage(String message) {
  return throwsA(predicate((Object e) => e.toString().contains(message)));
}

/// RoomService variant that yields a fixed sequence of room codes so code
/// collision retries can be tested deterministically.
class _FixedCodeRoomService extends RoomService {
  _FixedCodeRoomService({
    required super.firestore,
    required super.authService,
    required this.codes,
  });

  final List<String> codes;
  int _index = 0;

  @override
  String generateRoomCode() {
    final code = codes[_index % codes.length];
    _index++;
    return code;
  }
}

void main() {
  group('RoomService.generateRoomCode', () {
    test('returns 6-character uppercase code', () {
      final service = RoomService(
        firestore: SettlingFirestore(),
        authService: _authService(_authFor('alice')),
      );
      final code = service.generateRoomCode();

      expect(code.length, 6);
      expect(code, matches(RegExp(r'^[A-Z0-9]+$')));
    });

    test('excludes ambiguous characters', () {
      final service = RoomService(
        firestore: SettlingFirestore(),
        authService: _authService(_authFor('alice')),
      );
      for (var i = 0; i < 100; i++) {
        final code = service.generateRoomCode();
        expect(code, isNot(contains('0')));
        expect(code, isNot(contains('O')));
        expect(code, isNot(contains('I')));
        expect(code, isNot(contains('1')));
      }
    });

    test('generates different codes', () {
      final service = RoomService(
        firestore: SettlingFirestore(),
        authService: _authService(_authFor('alice')),
      );
      final codes = <String>{};
      for (var i = 0; i < 50; i++) {
        codes.add(service.generateRoomCode());
      }
      expect(codes.length, 50);
    });
  });

  group('RoomService.createRoom', () {
    test('creates a lobby room with the host as first player', () async {
      final f = SettlingFirestore();
      final service =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));

      final result = await service.createRoom(playerName: 'Alice');

      expect(result.room.code.length, 6);
      expect(result.room.status, 'lobby');
      expect(result.room.gamePhase, 'lobby');
      expect(result.room.hostPlayerId, 'alice');
      expect(result.hostPlayer.playerId, 'alice');
      expect(result.hostPlayer.isHost, isTrue);

      final roomDoc = await f.collection('rooms').doc(result.room.id).get();
      expect(roomDoc.data()!['player_count'], 1);

      final players =
          await f.collection('rooms').doc(result.room.id).collection('players').get();
      expect(players.docs.length, 1);
    });

    test('throws when player name is empty', () async {
      final service =
          RoomService(firestore: SettlingFirestore(), authService: _authService(_authFor('alice')));

      await expectLater(
        service.createRoom(playerName: '   '),
        _throwsWithMessage('Player name cannot be empty'),
      );
    });

    test('retries with a new code when the first code collides', () async {
      final f = SettlingFirestore();
      final now = DateTime.now().toUtc().toIso8601String();
      await f.collection('rooms_by_code').doc('AAAAAA').set({
        'room_id': 'existing',
        'created_at': now,
      });
      await f.collection('rooms').doc('existing').set({
        'code': 'AAAAAA',
        'host_player_id': 'someone',
        'status': 'lobby',
        'game_phase': 'lobby',
        'max_players': 8,
        'current_round_number': 0,
        'player_count': 1,
        'created_at': now,
        'updated_at': now,
      });

      final service = _FixedCodeRoomService(
        firestore: f,
        authService: _authService(_authFor('alice')),
        codes: const ['AAAAAA', 'BBBBBB'],
      );

      final result = await service.createRoom(playerName: 'Alice');

      expect(result.room.code, 'BBBBBB');
      expect(result.room.id, isNot('existing'));
      expect((await f.collection('rooms_by_code').doc('BBBBBB').get()).exists, isTrue);
    });

    test('throws when already in another active room', () async {
      final f = SettlingFirestore();
      final service =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));

      await service.createRoom(playerName: 'Alice');

      await expectLater(
        service.createRoom(playerName: 'Alice Again'),
        _throwsWithMessage('You are already in another active room'),
      );
    });
  });

  group('RoomService.findRoomByCode', () {
    test('finds a lobby room by code', () async {
      final f = SettlingFirestore();
      final service =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));
      final created = await service.createRoom(playerName: 'Alice');

      final found = await service.findRoomByCode(created.room.code);

      expect(found, isNotNull);
      expect(found!.id, created.room.id);
    });

    test('normalizes lowercase input and returns null for playing rooms', () async {
      final f = SettlingFirestore();
      final service =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));
      final created = await service.createRoom(playerName: 'Alice');

      await f.collection('rooms').doc(created.room.id).update({'status': 'playing'});

      expect(await service.findRoomByCode(created.room.code.toLowerCase()), isNull);
    });
  });

  group('RoomService.joinRoom', () {
    test('adds a player and increments the room count', () async {
      final f = SettlingFirestore();
      final alice =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));
      final bob =
          RoomService(firestore: f, authService: _authService(_authFor('bob')));
      final created = await alice.createRoom(playerName: 'Alice');

      final result = await bob.joinRoom(
        roomCode: created.room.code,
        playerName: 'Bob',
      );

      expect(result.room.id, created.room.id);
      expect(result.player.playerId, 'bob');
      expect(result.player.isHost, isFalse);

      final roomDoc = await f.collection('rooms').doc(created.room.id).get();
      expect(roomDoc.data()!['player_count'], 2);

      final players = await alice.getPlayersInRoom(created.room.id);
      expect(players.map((p) => p.playerId), ['alice', 'bob']);
    });

    test('rejects a full room', () async {
      final f = SettlingFirestore();
      final alice =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));
      final bob =
          RoomService(firestore: f, authService: _authService(_authFor('bob')));
      final created = await alice.createRoom(playerName: 'Alice');

      await f
          .collection('rooms')
          .doc(created.room.id)
          .update({'player_count': 8});

      await expectLater(
        bob.joinRoom(roomCode: created.room.code, playerName: 'Bob'),
        _throwsWithMessage('Room is full'),
      );
    });

    test('rejects a player already in another active room', () async {
      final f = SettlingFirestore();
      final alice =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));
      final bob =
          RoomService(firestore: f, authService: _authService(_authFor('bob')));
      final first = await alice.createRoom(playerName: 'Alice');

      await bob.joinRoom(roomCode: first.room.code, playerName: 'Bob');

      // Alice starts a second room and Bob tries to join it.
      await alice.leaveRoom(roomId: first.room.id, isHost: true);
      final second = await alice.createRoom(playerName: 'Alice');

      await expectLater(
        bob.joinRoom(roomCode: second.room.code, playerName: 'Bob'),
        _throwsWithMessage('You are already in another active room'),
      );
    });

    test('rejects an unknown room code', () async {
      final service =
          RoomService(firestore: SettlingFirestore(), authService: _authService(_authFor('bob')));

      await expectLater(
        service.joinRoom(roomCode: 'ZZZZZZ', playerName: 'Bob'),
        _throwsWithMessage('Room not found'),
      );
    });
  });

  group('RoomService.leaveRoom', () {
    test('removes a non-host player and decrements the count', () async {
      final f = SettlingFirestore();
      final alice =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));
      final bob =
          RoomService(firestore: f, authService: _authService(_authFor('bob')));
      final created = await alice.createRoom(playerName: 'Alice');
      await bob.joinRoom(roomCode: created.room.code, playerName: 'Bob');

      await bob.leaveRoom(roomId: created.room.id, isHost: false);

      final roomDoc = await f.collection('rooms').doc(created.room.id).get();
      expect(roomDoc.data()!['player_count'], 1);
      final players = await alice.getPlayersInRoom(created.room.id);
      expect(players.map((p) => p.playerId), ['alice']);
    });

    test('deletes the room when the last host leaves', () async {
      final f = SettlingFirestore();
      final alice =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));
      final created = await alice.createRoom(playerName: 'Alice');

      await alice.leaveRoom(roomId: created.room.id, isHost: true);

      expect(
        (await f.collection('rooms').doc(created.room.id).get()).exists,
        isFalse,
      );
      expect(
        (await f.collection('rooms_by_code').doc(created.room.code).get()).exists,
        isFalse,
      );
    });

    test('transfers host to the oldest remaining player', () async {
      final f = SettlingFirestore();
      final alice =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));
      final bob =
          RoomService(firestore: f, authService: _authService(_authFor('bob')));
      final cara =
          RoomService(firestore: f, authService: _authService(_authFor('cara')));
      final created = await alice.createRoom(playerName: 'Alice');
      await bob.joinRoom(roomCode: created.room.code, playerName: 'Bob');
      await cara.joinRoom(roomCode: created.room.code, playerName: 'Cara');

      await alice.leaveRoom(roomId: created.room.id, isHost: true);

      final players = await bob.getPlayersInRoom(created.room.id);
      expect(players.length, 2);
      final hosts = players.where((p) => p.isHost).toList();
      expect(hosts.single.playerId, 'bob');

      final roomDoc = await f.collection('rooms').doc(created.room.id).get();
      expect(roomDoc.data()!['host_player_id'], 'bob');
      expect(roomDoc.data()!['player_count'], 2);
    });
  });

  group('RoomService.findMyActiveRoom', () {
    test('returns the active room for a joined player', () async {
      final f = SettlingFirestore();
      final alice =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));
      final bob =
          RoomService(firestore: f, authService: _authService(_authFor('bob')));
      final created = await alice.createRoom(playerName: 'Alice');
      await bob.joinRoom(roomCode: created.room.code, playerName: 'Bob');

      final active = await bob.findMyActiveRoom();

      expect(active, isNotNull);
      expect(active!.room.id, created.room.id);
      expect(active.player.playerId, 'bob');
    });

    test('returns null when the room no longer exists', () async {
      final f = SettlingFirestore();
      final alice =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));
      final bob =
          RoomService(firestore: f, authService: _authService(_authFor('bob')));
      final created = await alice.createRoom(playerName: 'Alice');
      await bob.joinRoom(roomCode: created.room.code, playerName: 'Bob');

      await f.collection('rooms').doc(created.room.id).delete();

      expect(await bob.findMyActiveRoom(), isNull);
    });

    test('returns null when not authenticated', () async {
      final service = RoomService(
        firestore: SettlingFirestore(),
        authService: _authService(MockFirebaseAuth()),
      );
      expect(await service.findMyActiveRoom(), isNull);
    });
  });

  group('RoomService.updateRoomStatus', () {
    test('only the host can change the room status', () async {
      final f = SettlingFirestore();
      final alice =
          RoomService(firestore: f, authService: _authService(_authFor('alice')));
      final bob =
          RoomService(firestore: f, authService: _authService(_authFor('bob')));
      final created = await alice.createRoom(playerName: 'Alice');
      await bob.joinRoom(roomCode: created.room.code, playerName: 'Bob');

      await expectLater(
        bob.updateRoomStatus(roomId: created.room.id, newStatus: 'playing'),
        _throwsWithMessage('Only the host can start this room'),
      );

      await alice.updateRoomStatus(roomId: created.room.id, newStatus: 'playing');
      final roomDoc = await f.collection('rooms').doc(created.room.id).get();
      expect(roomDoc.data()!['status'], 'playing');
    });
  });
}
