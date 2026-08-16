import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';

import 'voice_transport.dart';

/// Options for the LiveKit transport.
class LiveKitVoiceOptions {
  const LiveKitVoiceOptions({this.speechBitrate = 24000});

  /// Opus bitrate used for the speech stream. 24 kbps is ideal for voice.
  final int speechBitrate;
}

/// Real transport backed by LiveKit (a WebRTC SFU).
///
/// The microphone audio is published once to the LiveKit room and the server
/// mixes/downstreams it to every participant, which keeps the uplink tiny even
/// with eight players. Works on Web (JS interop), Android and iOS. LiveKit
/// handles STUN/TURN, ICE restarts and automatic reconnects.
class LiveKitVoiceTransport implements VoiceTransport {
  LiveKitVoiceTransport({
    LiveKitVoiceOptions options = const LiveKitVoiceOptions(),
  }) : _options = options;

  static const AudioCaptureOptions _audioCaptureOptions = AudioCaptureOptions(
    echoCancellation: true,
    noiseSuppression: true,
    autoGainControl: true,
  );

  final LiveKitVoiceOptions _options;

  Room? _room;
  EventsListener<RoomEvent>? _listener;
  StreamController<VoiceTransportStatus>? _statusController;
  StreamController<List<VoiceTransportParticipant>>? _participantsController;
  StreamController<VoiceTransportError>? _errorsController;
  Set<String> _speakerIds = const {};
  bool _disposed = false;

  @override
  Stream<VoiceTransportStatus> get statusStream => (_statusController ??=
          StreamController<VoiceTransportStatus>.broadcast())
      .stream;

  @override
  Stream<List<VoiceTransportParticipant>> get participantsStream =>
      (_participantsController ??=
              StreamController<List<VoiceTransportParticipant>>.broadcast())
          .stream;

  @override
  Stream<VoiceTransportError> get errorsStream => (_errorsController ??=
          StreamController<VoiceTransportError>.broadcast())
      .stream;

  @override
  Future<bool> requestMicrophonePermission() async {
    try {
      final stream =
          await rtc.navigator.mediaDevices.getUserMedia({'audio': true});
      for (final track in stream.getAudioTracks()) {
        await track.stop();
      }
      await stream.dispose();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> connect({
    required String url,
    required String token,
    required String playerId,
    required String playerName,
  }) async {
    assert(!_disposed);
    _emitStatus(VoiceTransportStatus.connecting);
    _room ??= _createRoom();
    _listener ??= _createListener();
    try {
      await _room!.connect(
        url,
        token,
        connectOptions: const ConnectOptions(autoSubscribe: true),
      );
      _emitStatus(VoiceTransportStatus.connected);
    } catch (error, stackTrace) {
      try {
        await _room!.disconnect();
      } catch (_) {
        // The connection may already be torn down.
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Room _createRoom() {
    return Room(
      roomOptions: RoomOptions(
        defaultAudioCaptureOptions: _audioCaptureOptions,
        defaultAudioPublishOptions: AudioPublishOptions(
          encoding: AudioEncoding(maxBitrate: _options.speechBitrate),
        ),
      ),
    );
  }

  EventsListener<RoomEvent> _createListener() {
    final listener = _room!.createListener();
    listener
      ..on<RoomReconnectingEvent>((_) {
        _emitStatus(VoiceTransportStatus.reconnecting);
      })
      ..on<RoomReconnectedEvent>((_) {
        _emitStatus(VoiceTransportStatus.connected);
        _syncParticipants();
      })
      ..on<RoomDisconnectedEvent>((event) {
        final reason = event.reason ?? DisconnectReason.unknown;
        final intentional = reason == DisconnectReason.clientInitiated ||
            reason == DisconnectReason.roomDeleted;
        if (!intentional) {
          _emitError(VoiceTransportError(
            VoiceErrorCode.connectionFailed,
            'Disconnected ($reason)',
          ));
        }
        _speakerIds = const {};
        _emitStatus(VoiceTransportStatus.disconnected);
        _emitParticipants(const []);
      })
      ..on<ParticipantConnectedEvent>((_) => _syncParticipants())
      ..on<ParticipantDisconnectedEvent>((_) => _syncParticipants())
      ..on<ParticipantNameUpdatedEvent>((_) => _syncParticipants())
      ..on<ActiveSpeakersChangedEvent>((event) {
        _speakerIds =
            event.speakers.map((participant) => participant.identity).toSet();
        _emitParticipants(_buildParticipants());
      })
      ..on<TrackMutedEvent>((_) => _syncParticipants())
      ..on<TrackUnmutedEvent>((_) => _syncParticipants());
    return listener;
  }

  void _syncParticipants() {
    _emitParticipants(_buildParticipants());
  }

  List<VoiceTransportParticipant> _buildParticipants() {
    final room = _room;
    if (room == null) return const [];
    final result = <VoiceTransportParticipant>[];
    final local = room.localParticipant;
    if (local != null) {
      result.add(_toParticipant(local));
    }
    for (final participant in room.remoteParticipants.values) {
      result.add(_toParticipant(participant));
    }
    return result;
  }

  VoiceTransportParticipant _toParticipant(Participant participant) {
    return VoiceTransportParticipant(
      playerId: participant.identity,
      name: participant.name,
      micEnabled: participant.isMicrophoneEnabled(),
      isSpeaking: _speakerIds.contains(participant.identity),
    );
  }

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {
    final local = _room?.localParticipant;
    if (local == null) {
      if (enabled) {
        _emitError(const VoiceTransportError(
          VoiceErrorCode.connectionFailed,
          'Not connected to a voice room',
        ));
        throw StateError('Voice is not connected');
      }
      return;
    }
    try {
      await local.setMicrophoneEnabled(
        enabled,
        audioCaptureOptions: _audioCaptureOptions,
      );
    } catch (error) {
      _emitError(VoiceTransportError(
        VoiceErrorCode.microphoneUnavailable,
        error.toString(),
      ));
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    final room = _room;
    if (room == null) {
      _emitStatus(VoiceTransportStatus.disconnected);
      return;
    }
    try {
      await room.disconnect();
    } catch (_) {
      // The room may already be gone.
    }
    _speakerIds = const {};
    _emitStatus(VoiceTransportStatus.disconnected);
    _emitParticipants(const []);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final listener = _listener;
    _listener = null;
    listener?.dispose();
    final room = _room;
    _room = null;
    if (room != null) {
      try {
        await room.disconnect();
      } catch (_) {}
      room.dispose();
    }
    await _statusController?.close();
    await _participantsController?.close();
    await _errorsController?.close();
    _statusController = null;
    _participantsController = null;
    _errorsController = null;
  }

  void _emitStatus(VoiceTransportStatus status) {
    if (_disposed) return;
    final controller = _statusController;
    if (controller != null && !controller.isClosed) {
      controller.add(status);
    }
  }

  void _emitParticipants(List<VoiceTransportParticipant> participants) {
    if (_disposed) return;
    final controller = _participantsController;
    if (controller != null && !controller.isClosed) {
      controller.add(participants);
    }
  }

  void _emitError(VoiceTransportError error) {
    if (_disposed) return;
    final controller = _errorsController;
    if (controller != null && !controller.isClosed) {
      controller.add(error);
    }
  }
}
