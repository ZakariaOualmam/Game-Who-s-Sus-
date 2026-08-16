import 'dart:async';

import 'package:who_sus/services/firebase_auth_service.dart';
import 'package:who_sus/services/voice_chat_service.dart';
import 'package:who_sus/voice/voice_config.dart';
import 'package:who_sus/voice/voice_transport.dart';

/// Deterministic token provider that never touches a real backend.
class FakeVoiceTokenProvider implements VoiceTokenProvider {
  FakeVoiceTokenProvider({this.url = 'wss://fake.test'});

  final String url;

  /// When set, [fetch] throws it instead of returning credentials.
  Object? failWith;

  int fetchCount = 0;

  @override
  Future<VoiceJoinCredentials> fetch({required String roomId}) async {
    fetchCount++;
    final error = failWith;
    if (error != null) throw error;
    return VoiceJoinCredentials(url: url, token: 'token-$roomId');
  }
}

/// In-memory [VoiceTransport] for tests. Exposes knobs to simulate permission
/// denial, connect failures, reconnect, speaking events and drops.
class FakeVoiceTransport implements VoiceTransport {
  FakeVoiceTransport({this.permissionGranted = true});

  bool permissionGranted;

  /// When true, [connect] throws.
  bool connectShouldFail = false;

  bool micEnabled = false;
  String? connectedUrl;
  String? connectedPlayerId;
  String? connectedPlayerName;

  final Map<String, VoiceTransportParticipant> _byId = {};
  final List<VoiceTransportError> _emittedErrors = [];

  // sync:true so events are delivered synchronously on add(), making the fake
  // deterministic for tests (no need to wait a microtask after emitting).
  final _statusController =
      StreamController<VoiceTransportStatus>.broadcast(sync: true);
  final _participantsController =
      StreamController<List<VoiceTransportParticipant>>.broadcast(sync: true);
  final _errorsController = StreamController<VoiceTransportError>.broadcast(
    sync: true,
  );

  @override
  Stream<VoiceTransportStatus> get statusStream => _statusController.stream;

  @override
  Stream<List<VoiceTransportParticipant>> get participantsStream =>
      _participantsController.stream;

  @override
  Stream<VoiceTransportError> get errorsStream => _errorsController.stream;

  List<VoiceTransportParticipant> get participants =>
      List.unmodifiable(_byId.values);
  List<VoiceTransportError> get emittedErrors =>
      List.unmodifiable(_emittedErrors);

  @override
  Future<bool> requestMicrophonePermission() async => permissionGranted;

  @override
  Future<void> connect({
    required String url,
    required String token,
    required String playerId,
    required String playerName,
  }) async {
    if (connectShouldFail) {
      _statusController.add(VoiceTransportStatus.disconnected);
      throw StateError('fake connect failure');
    }
    connectedUrl = url;
    connectedPlayerId = playerId;
    connectedPlayerName = playerName;
    _statusController.add(VoiceTransportStatus.connecting);
    _statusController.add(VoiceTransportStatus.connected);
    _upsert(VoiceTransportParticipant(playerId: playerId, name: playerName));
  }

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {
    if (enabled && !permissionGranted) {
      _emitError(const VoiceTransportError(
        VoiceErrorCode.permissionDenied,
        'denied',
      ));
      throw StateError('fake mic denied');
    }
    micEnabled = enabled;
    final selfId = connectedPlayerId;
    if (selfId == null) return;
    final existing = _byId[selfId];
    _upsert(VoiceTransportParticipant(
      playerId: selfId,
      name: existing?.name ?? connectedPlayerName ?? selfId,
      micEnabled: enabled,
      isSpeaking: existing?.isSpeaking ?? false,
    ));
  }

  @override
  Future<void> disconnect() async {
    connectedUrl = null;
    _byId.clear();
    _statusController.add(VoiceTransportStatus.disconnected);
    _participantsController.add(const []);
  }

  @override
  Future<void> dispose() async {
    await _statusController.close();
    await _participantsController.close();
    await _errorsController.close();
  }

  void emitParticipant(VoiceTransportParticipant participant) {
    _upsert(participant);
  }

  void removeParticipant(String playerId) {
    if (_byId.remove(playerId) != null) {
      _participantsController.add(List.unmodifiable(_byId.values));
    }
  }

  void emitError(VoiceTransportError error) {
    _emitError(error);
  }

  void emitStatus(VoiceTransportStatus status) {
    _statusController.add(status);
  }

  void _emitError(VoiceTransportError error) {
    _emittedErrors.add(error);
    _errorsController.add(error);
  }

  void _upsert(VoiceTransportParticipant participant) {
    _byId[participant.playerId] = participant;
    _participantsController.add(List.unmodifiable(_byId.values));
  }
}

/// Builds a [VoiceChatService] wired to fakes, ready to be assigned to
/// [VoiceChatService.instance] or used directly.
VoiceChatService buildFakeVoiceService({
  required FirebaseAuthService authService,
  FakeVoiceTransport? transport,
  FakeVoiceTokenProvider? tokenProvider,
  VoiceConfig? config,
}) {
  return VoiceChatService(
    config: config ?? const VoiceConfig(enabled: true, livekitUrl: 'wss://fake.test'),
    transport: transport ?? FakeVoiceTransport(),
    tokenProvider: tokenProvider ?? FakeVoiceTokenProvider(),
    authService: authService,
  );
}
