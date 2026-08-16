import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/services/firebase_auth_service.dart';
import 'package:who_sus/services/voice_chat_service.dart';
import 'package:who_sus/voice/voice_config.dart';
import 'package:who_sus/voice/voice_participant.dart';
import 'package:who_sus/voice/voice_transport.dart';

import 'helpers/fake_voice.dart';

FirebaseAuthService _auth(String uid) =>
    FirebaseAuthService.forTesting(MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: uid, isAnonymous: true),
    ));

void main() {
  late FakeVoiceTransport transport;
  late FakeVoiceTokenProvider tokenProvider;
  late VoiceChatService service;

  setUp(() {
    transport = FakeVoiceTransport();
    tokenProvider = FakeVoiceTokenProvider();
    service = buildFakeVoiceService(
      authService: _auth('u1'),
      transport: transport,
      tokenProvider: tokenProvider,
    );
    addTearDown(service.dispose);
  });

  group('joinRoom', () {
    test('starts disabled and joins a room', () async {
      expect(service.state, VoiceConnectionState.disabled);
      expect(service.isActive, isFalse);

      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      expect(service.state, VoiceConnectionState.connected);
      expect(service.isPushToTalkEnabled, isTrue);
      expect(service.activeRoomId, 'room-1');
      expect(transport.connectedUrl, 'wss://fake.test');
      expect(transport.connectedPlayerId, 'u1');
      expect(tokenProvider.fetchCount, 1);
      expect(service.participants, hasLength(1));
      expect(service.participants.single.playerId, 'u1');
      expect(service.participants.single.state, VoiceParticipantState.muted);
    });

    test('uses the backend URL when the provider returns one', () async {
      service = buildFakeVoiceService(
        authService: _auth('u1'),
        transport: transport,
        tokenProvider: FakeVoiceTokenProvider(url: 'wss://real.example'),
      );
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      expect(transport.connectedUrl, 'wss://real.example');
    });

    test('is a no-op when already connected to the same room', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      expect(tokenProvider.fetchCount, 1);
    });

    test('fails with notConfigured when voice is disabled', () async {
      service = buildFakeVoiceService(
        authService: _auth('u1'),
        transport: transport,
        tokenProvider: tokenProvider,
        config: const VoiceConfig(enabled: false),
      );

      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      expect(service.state, VoiceConnectionState.failed);
      expect(service.failure, VoiceFailure.notConfigured);
      expect(transport.connectedUrl, isNull);
    });

    test('enters permissionDenied when the microphone is denied', () async {
      transport.permissionGranted = false;

      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      expect(service.state, VoiceConnectionState.permissionDenied);
      expect(service.failure, VoiceFailure.permissionDenied);
      expect(tokenProvider.fetchCount, 0);
    });

    test('fails with notConfigured when the backend is missing', () async {
      tokenProvider.failWith = const VoiceNotConfiguredException();

      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      expect(service.state, VoiceConnectionState.failed);
      expect(service.failure, VoiceFailure.notConfigured);
    });

    test('fails with connectionFailed when the token call fails', () async {
      tokenProvider.failWith = Exception('boom');

      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      expect(service.state, VoiceConnectionState.failed);
      expect(service.failure, VoiceFailure.connectionFailed);
    });

    test('fails with connectionFailed when connect throws', () async {
      transport.connectShouldFail = true;

      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      expect(service.state, VoiceConnectionState.failed);
      expect(service.failure, VoiceFailure.connectionFailed);
    });
  });

  group('push to talk', () {
    test('enables and disables the microphone', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      expect(await service.setMicEnabled(true), isTrue);
      expect(service.micEnabled, isTrue);
      expect(transport.micEnabled, isTrue);

      expect(await service.setMicEnabled(false), isTrue);
      expect(service.micEnabled, isFalse);
      expect(transport.micEnabled, isFalse);
    });

    test('startTalking enables the microphone', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      expect(await service.startTalking(), isTrue);
      expect(service.micEnabled, isTrue);
      expect(transport.micEnabled, isTrue);
    });

    test('stopTalking disables the microphone', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      await service.startTalking();

      expect(await service.stopTalking(), isTrue);
      expect(service.micEnabled, isFalse);
      expect(transport.micEnabled, isFalse);
    });

    test('stopTalking is idempotent when already muted', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      expect(await service.stopTalking(), isTrue);
      expect(await service.stopTalking(), isTrue);
      expect(service.micEnabled, isFalse);
    });

    test('rejects enabling while not connected', () async {
      expect(await service.setMicEnabled(true), isFalse);
      expect(transport.micEnabled, isFalse);
    });

    test('surfaces a microphone failure and keeps the mic off', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      transport.permissionGranted = false;

      expect(await service.setMicEnabled(true), isFalse);
      expect(service.micEnabled, isFalse);
      expect(transport.micEnabled, isFalse);
      expect(service.failure, VoiceFailure.microphoneUnavailable);
    });

    test('startTalking failure keeps the mic off', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      transport.permissionGranted = false;

      expect(await service.startTalking(), isFalse);
      expect(service.micEnabled, isFalse);
      expect(service.failure, VoiceFailure.microphoneUnavailable);
    });

    test('suspendMic force-stops a hot microphone', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      await service.setMicEnabled(true);

      await service.suspendMic();

      expect(service.micEnabled, isFalse);
      expect(transport.micEnabled, isFalse);
    });
  });

  group('reconnect and drops', () {
    test('marks reconnecting and suspends the mic, then restores', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      await service.setMicEnabled(true);

      transport.emitStatus(VoiceTransportStatus.reconnecting);

      expect(service.state, VoiceConnectionState.reconnecting);
      expect(service.micEnabled, isFalse);
      expect(service.isPushToTalkEnabled, isFalse);

      transport.emitStatus(VoiceTransportStatus.connected);

      expect(service.state, VoiceConnectionState.connected);
      expect(service.isPushToTalkEnabled, isTrue);
    });

    test('maps an unexpected drop to disconnected', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      transport.emitStatus(VoiceTransportStatus.disconnected);

      expect(service.state, VoiceConnectionState.disconnected);
      expect(service.failure, VoiceFailure.connectionFailed);
      expect(service.activeRoomId, isNull);
      expect(service.micEnabled, isFalse);
    });

    test('ignores a disconnect event after an intentional leave', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      await service.leaveRoom();
      transport.emitStatus(VoiceTransportStatus.disconnected);
      expect(service.state, VoiceConnectionState.disabled);
    });

    test('maps a connectionFailed error to disconnected', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      transport.emitError(const VoiceTransportError(VoiceErrorCode.connectionFailed));
      expect(service.state, VoiceConnectionState.disconnected);
      expect(service.failure, VoiceFailure.connectionFailed);
    });

    test('maps a runtime permission error to a mic failure', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      transport.emitError(const VoiceTransportError(VoiceErrorCode.permissionDenied));
      expect(service.failure, VoiceFailure.permissionDenied);
    });
  });

  group('leaveRoom and retry', () {
    test('leaves the room and clears state', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      await service.setMicEnabled(true);

      await service.leaveRoom();

      expect(service.state, VoiceConnectionState.disabled);
      expect(service.isActive, isFalse);
      expect(service.activeRoomId, isNull);
      expect(service.micEnabled, isFalse);
      expect(service.participants, isEmpty);
      expect(transport.connectedUrl, isNull);
    });

    test('leaveRoom is safe when never joined', () async {
      await service.leaveRoom();
      expect(service.state, VoiceConnectionState.disabled);
    });

    test('retryJoin rejoins after a failure', () async {
      transport.connectShouldFail = true;
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      expect(service.state, VoiceConnectionState.failed);

      transport.connectShouldFail = false;
      await service.retryJoin();

      expect(service.state, VoiceConnectionState.connected);
      expect(tokenProvider.fetchCount, 2);
    });

    test('retryJoin after permission denial rejoins once granted', () async {
      transport.permissionGranted = false;
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      expect(service.state, VoiceConnectionState.permissionDenied);

      transport.permissionGranted = true;
      await service.retryJoin();

      expect(service.state, VoiceConnectionState.connected);
    });
  });

  group('continue without voice', () {
    test('opts out of the current room', () async {
      transport.permissionGranted = false;
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      expect(service.state, VoiceConnectionState.permissionDenied);

      service.continueWithoutVoice();
      expect(service.state, VoiceConnectionState.disabled);

      // joinRoom for the same room is now a no-op...
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      expect(tokenProvider.fetchCount, 0);

      // ...but allowMicrophone resumes the session.
      transport.permissionGranted = true;
      await service.allowMicrophone();
      expect(service.state, VoiceConnectionState.connected);
      expect(tokenProvider.fetchCount, 1);
    });

    test('is a no-op when already disabled', () async {
      service.continueWithoutVoice();
      expect(service.state, VoiceConnectionState.disabled);
    });
  });

  group('allowMicrophone', () {
    test('re-requests permission after a denial and rejoins', () async {
      transport.permissionGranted = false;
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      expect(service.state, VoiceConnectionState.permissionDenied);

      transport.permissionGranted = true;
      await service.allowMicrophone();

      expect(service.state, VoiceConnectionState.connected);
    });

    test('keeps the denial state when permission is still refused', () async {
      transport.permissionGranted = false;
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      await service.allowMicrophone();

      expect(service.state, VoiceConnectionState.permissionDenied);
    });

    test('re-enables an already-connected microphone', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      transport.permissionGranted = false;
      await service.setMicEnabled(true);
      expect(service.micEnabled, isFalse);

      transport.permissionGranted = true;
      await service.allowMicrophone();

      expect(service.micEnabled, isTrue);
      expect(service.failure, isNull);
    });
  });

  group('participants', () {
    test('maps speaking participants from the transport', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');

      transport.emitParticipant(const VoiceTransportParticipant(
        playerId: 'u2',
        name: 'Bob',
        isSpeaking: true,
      ));

      expect(service.participants, hasLength(2));
      final bob =
          service.participants.firstWhere((p) => p.playerId == 'u2');
      expect(bob.state, VoiceParticipantState.speaking);
      expect(bob.name, 'Bob');
    });

    test('tracks a participant leaving the room', () async {
      await service.joinRoom(roomId: 'room-1', playerName: 'Ada');
      transport.emitParticipant(const VoiceTransportParticipant(
        playerId: 'u2',
        name: 'Bob',
      ));
      expect(service.participants, hasLength(2));

      transport.removeParticipant('u2');

      expect(service.participants, hasLength(1));
      expect(service.participants.single.playerId, 'u1');
    });
  });
}
