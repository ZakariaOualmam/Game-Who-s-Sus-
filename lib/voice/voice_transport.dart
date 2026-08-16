import 'package:flutter/foundation.dart';

/// Connection status reported by a [VoiceTransport].
enum VoiceTransportStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Machine-readable error codes emitted by a [VoiceTransport].
enum VoiceErrorCode {
  /// Microphone permission was denied or revoked at runtime.
  permissionDenied,

  /// The microphone could not be used.
  microphoneUnavailable,

  /// The connection was lost or could not be established.
  connectionFailed,
}

/// An asynchronous error emitted by a [VoiceTransport] during a session.
@immutable
class VoiceTransportError {
  const VoiceTransportError(this.code, [this.message]);

  final VoiceErrorCode code;
  final String? message;

  @override
  String toString() =>
      'VoiceTransportError(${code.name}${message == null ? '' : ': $message'})';
}

/// A participant connected to the voice room, as seen by the transport.
@immutable
class VoiceTransportParticipant {
  const VoiceTransportParticipant({
    required this.playerId,
    required this.name,
    this.micEnabled = false,
    this.isSpeaking = false,
  });

  final String playerId;
  final String name;
  final bool micEnabled;
  final bool isSpeaking;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceTransportParticipant &&
          other.playerId == playerId &&
          other.name == name &&
          other.micEnabled == micEnabled &&
          other.isSpeaking == isSpeaking;

  @override
  int get hashCode => Object.hash(playerId, name, micEnabled, isSpeaking);

  @override
  String toString() =>
      'VoiceTransportParticipant($playerId, $name, mic: $micEnabled, speaking: $isSpeaking)';
}

/// Platform-independent transport for realtime voice.
///
/// The UI and [VoiceChatService] only ever talk to this interface; the real
/// implementation uses LiveKit and tests use a fake, so no realtime SDK code
/// reaches the UI layer.
abstract class VoiceTransport {
  /// Emits the connection status while it changes.
  Stream<VoiceTransportStatus> get statusStream;

  /// Emits the current list of participants whenever it changes.
  Stream<List<VoiceTransportParticipant>> get participantsStream;

  /// Emits asynchronous errors during a session (never on [disconnect] after
  /// an intentional leave).
  Stream<VoiceTransportError> get errorsStream;

  /// Probes for microphone permission. Returns false when denied or when no
  /// microphone is available.
  Future<bool> requestMicrophonePermission();

  /// Connects to the voice room. Throws on failure.
  Future<void> connect({
    required String url,
    required String token,
    required String playerId,
    required String playerName,
  });

  /// Publishes (true) or stops publishing (false) the microphone.
  Future<void> setMicrophoneEnabled(bool enabled);

  /// Leaves the voice room cleanly. Safe to call when not connected.
  Future<void> disconnect();

  /// Releases all resources. The transport must not be used afterwards.
  Future<void> dispose();
}
