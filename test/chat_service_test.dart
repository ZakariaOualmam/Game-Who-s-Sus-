import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/models/chat_message.dart';
import 'package:who_sus/services/chat_service.dart';
import 'package:who_sus/services/firebase_auth_service.dart';

import 'helpers/settling_firestore.dart';

MockFirebaseAuth _authFor(String uid) {
  return MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(uid: uid, isAnonymous: true),
  );
}

FirebaseAuthService _authService(MockFirebaseAuth auth) =>
    FirebaseAuthService.forTesting(auth);

void main() {
  group('ChatService.sendMessage', () {
    test('stores a trimmed message under the authenticated sender', () async {
      final f = SettlingFirestore();
      final service = ChatService(
        firestore: f,
        authService: _authService(_authFor('alice')),
      );

      await service.sendMessage(
        roomId: 'room1',
        playerName: 'Alice',
        message: '  Hello everyone!  ',
      );

      final docs = await f
          .collection('rooms')
          .doc('room1')
          .collection('messages')
          .get();
      expect(docs.docs.length, 1);
      final data = docs.docs.first.data();
      expect(data['player_id'], 'alice');
      expect(data['player_name'], 'Alice');
      expect(data['message'], 'Hello everyone!');
      expect(data['type'], ChatMessage.textType);
      expect(data['created_at'], isA<String>());
    });

    test('sender identity always comes from the auth uid, never the caller',
        () async {
      final f = SettlingFirestore();
      final service = ChatService(
        firestore: f,
        authService: _authService(_authFor('alice')),
      );

      // The caller only supplies a display name; player_id must be alice.
      await service.sendMessage(
        roomId: 'room1',
        playerName: 'Fake Bob',
        message: 'Hello',
      );

      final docs = await f
          .collection('rooms')
          .doc('room1')
          .collection('messages')
          .get();
      expect(docs.docs.single.data()['player_id'], 'alice');
    });

    test('rejects empty and whitespace-only messages', () async {
      final f = SettlingFirestore();
      final service = ChatService(
        firestore: f,
        authService: _authService(_authFor('alice')),
      );

      await expectLater(
        service.sendMessage(roomId: 'room1', playerName: 'Alice', message: ''),
        throwsException,
      );
      await expectLater(
        service.sendMessage(
          roomId: 'room1',
          playerName: 'Alice',
          message: '   ',
        ),
        throwsException,
      );
    });

    test('rejects messages longer than the maximum length', () async {
      final f = SettlingFirestore();
      final service = ChatService(
        firestore: f,
        authService: _authService(_authFor('alice')),
      );

      await expectLater(
        service.sendMessage(
          roomId: 'room1',
          playerName: 'Alice',
          message: 'x' * (ChatMessage.maxLength + 1),
        ),
        throwsA(predicate(
          (Object e) => e.toString().contains('${ChatMessage.maxLength}'),
        )),
      );

      final docs = await f
          .collection('rooms')
          .doc('room1')
          .collection('messages')
          .get();
      expect(docs.docs, isEmpty);
    });
  });

  group('ChatService.subscribeToMessages', () {
    test('emits stored messages in chronological order', () async {
      final f = SettlingFirestore();
      final service = ChatService(
        firestore: f,
        authService: _authService(_authFor('alice')),
      );
      final ref = f.collection('rooms').doc('room1').collection('messages');
      await ref.add({
        'room_id': 'room1',
        'player_id': 'alice',
        'player_name': 'Alice',
        'message': 'older',
        'type': 'text',
        'created_at': '2026-01-01T00:00:00.000Z',
      });
      await ref.add({
        'room_id': 'room1',
        'player_id': 'bob',
        'player_name': 'Bob',
        'message': 'newer',
        'type': 'text',
        'created_at': '2026-01-02T00:00:00.000Z',
      });

      final seen = <List<ChatMessage>>[];
      final sub = service.subscribeToMessages('room1').listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(seen, isNotEmpty);
      final messages = seen.last;
      expect(messages.map((m) => m.message).toList(), ['older', 'newer']);
      expect(messages.first.playerName, 'Alice');
      expect(messages.last.playerId, 'bob');
    });

    test('emits new messages in real time after subscribing', () async {
      final f = SettlingFirestore();
      final service = ChatService(
        firestore: f,
        authService: _authService(_authFor('alice')),
      );

      final seen = <List<ChatMessage>>[];
      final sub = service.subscribeToMessages('room1').listen(seen.add);
      await Future<void>.delayed(Duration.zero);

      await service.sendMessage(
        roomId: 'room1',
        playerName: 'Alice',
        message: 'first',
      );
      await service.sendMessage(
        roomId: 'room1',
        playerName: 'Alice',
        message: 'second',
      );
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(seen, isNotEmpty);
      expect(
        seen.last.map((m) => m.message).toList(),
        ['first', 'second'],
      );
    });
  });

  group('ChatService.clearMessages', () {
    test('deletes every message in the room', () async {
      final f = SettlingFirestore();
      final service = ChatService(
        firestore: f,
        authService: _authService(_authFor('alice')),
      );
      await service.sendMessage(
        roomId: 'room1',
        playerName: 'Alice',
        message: 'one',
      );
      await service.sendMessage(
        roomId: 'room1',
        playerName: 'Alice',
        message: 'two',
      );

      await service.clearMessages('room1');

      final docs = await f
          .collection('rooms')
          .doc('room1')
          .collection('messages')
          .get();
      expect(docs.docs, isEmpty);
    });

    test('is a no-op when the room has no messages', () async {
      final f = SettlingFirestore();
      final service = ChatService(
        firestore: f,
        authService: _authService(_authFor('alice')),
      );

      await service.clearMessages('room1');

      final docs = await f
          .collection('rooms')
          .doc('room1')
          .collection('messages')
          .get();
      expect(docs.docs, isEmpty);
    });
  });
}
