import 'package:flutter/foundation.dart';

/// The connection state of the voice chat for the current device.
enum VoiceConnectionState {
  /// Voice is inactive (outside the discussion phase, or the player opted out).
  disabled,

  /// Requesting permission, fetching a token and connecting to the room.
  joining,

  /// Connected to the voice room; audio can flow.
  connected,

  /// The connection was dropped; the transport is trying to reconnect.
  reconnecting,

  /// The connection was lost and could not be restored.
  disconnected,

  /// Microphone permission was denied by the player or the platform.
  permissionDenied,

  /// The voice room could not be joined (config, token or connect error).
  failed,
}

/// Per-player voice state shown in the discussion UI.
enum VoiceParticipantState {
  /// In the voice room with the microphone closed (or not yet publishing).
  muted,

  /// Currently producing audio (LiveKit active-speaker detection).
  speaking,

  /// Joining the voice room.
  connecting,

  /// Reconnecting after a drop.
  reconnecting,

  /// Not connected to the voice room (e.g. opted out or not in voice).
  disconnected,
}

/// A player's voice state in the discussion UI.
@immutable
class VoiceParticipant {
  const VoiceParticipant({
    required this.playerId,
    required this.name,
    this.state = VoiceParticipantState.muted,
  });

  final String playerId;
  final String name;
  final VoiceParticipantState state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceParticipant &&
          other.playerId == playerId &&
          other.name == name &&
          other.state == state;

  @override
  int get hashCode => Object.hash(playerId, name, state);

  @override
  String toString() => 'VoiceParticipant($playerId, $name, $state)';
}

/// Localized failure reasons for the voice chat.
enum VoiceFailure {
  /// Microphone permission was denied or revoked.
  permissionDenied,

  /// The microphone could not be used (no device, hardware error).
  microphoneUnavailable,

  /// Could not connect to the voice server.
  connectionFailed,

  /// The voice backend has not been configured/deployed.
  notConfigured,
}
