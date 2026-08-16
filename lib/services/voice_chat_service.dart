import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';

import '../voice/livekit_voice_transport.dart';
import '../voice/voice_config.dart';
import '../voice/voice_participant.dart';
import '../voice/voice_transport.dart';
import 'firebase_auth_service.dart';

/// Orchestrates the realtime voice chat lifecycle for the current player.
///
/// Owns the connection state machine (join / leave / reconnect / permission),
/// push-to-talk, and background safety. It only interacts with [VoiceTransport]
/// and [VoiceTokenProvider], never with a realtime SDK directly, so tests can
/// inject a fake transport.
class VoiceChatService extends ChangeNotifier {
  VoiceChatService({
    VoiceConfig? config,
    VoiceTransport? transport,
    VoiceTokenProvider? tokenProvider,
    FirebaseAuthService? authService,
  })  : _config = config ?? const VoiceConfig(),
        _transport = transport ?? LiveKitVoiceTransport(),
        _tokenProvider = tokenProvider ?? CallableVoiceTokenProvider(),
        _authService = authService ?? FirebaseAuthService.instance {
    WidgetsFlutterBinding.ensureInitialized();
    _lifecycleListener = AppLifecycleListener(onStateChange: _onLifecycleState);
    _statusSub = _transport.statusStream.listen(_onTransportStatus);
    _participantsSub =
        _transport.participantsStream.listen(_onTransportParticipants);
    _errorsSub = _transport.errorsStream.listen(_onTransportError);
  }

  /// The app-wide voice service. Tests replace this with a service built on a
  /// fake transport before pumping a screen.
  static VoiceChatService instance = VoiceChatService();

  final VoiceConfig _config;
  final VoiceTransport _transport;
  final VoiceTokenProvider _tokenProvider;
  final FirebaseAuthService _authService;

  AppLifecycleListener? _lifecycleListener;
  StreamSubscription<VoiceTransportStatus>? _statusSub;
  StreamSubscription<List<VoiceTransportParticipant>>? _participantsSub;
  StreamSubscription<VoiceTransportError>? _errorsSub;

  VoiceConnectionState _state = VoiceConnectionState.disabled;
  VoiceFailure? _failure;
  List<VoiceParticipant> _participants = const [];
  bool _micEnabled = false;
  String? _activeRoomId;
  String? _lastRoomId;
  String? _lastPlayerName;
  String? _optOutRoomId;
  bool _disposed = false;

  VoiceConnectionState get state => _state;
  VoiceFailure? get failure => _failure;
  List<VoiceParticipant> get participants => _participants;
  bool get micEnabled => _micEnabled;
  String? get activeRoomId => _activeRoomId;

  /// True while the microphone can be pushed-to-talk right now.
  bool get isPushToTalkEnabled =>
      _state == VoiceConnectionState.connected && _activeRoomId != null;

  /// True while the service is not fully disabled (used to show the UI).
  bool get isActive => _state != VoiceConnectionState.disabled;

  /// Joins the voice room for [roomId] as [playerName].
  ///
  /// Safe to call repeatedly: when already connected to the same room, or when
  /// the player opted out of voice for this room, this is a no-op.
  Future<void> joinRoom({
    required String roomId,
    required String playerName,
  }) async {
    if (_disposed) return;
    if (_optOutRoomId == roomId && _state == VoiceConnectionState.disabled) {
      return;
    }
    if (_activeRoomId == roomId &&
        (_state == VoiceConnectionState.connected ||
            _state == VoiceConnectionState.joining ||
            _state == VoiceConnectionState.reconnecting)) {
      return;
    }

    _lastRoomId = roomId;
    _lastPlayerName = playerName;
    _update(state: VoiceConnectionState.joining, clearFailure: true);

    if (!_config.enabled) {
      _update(
        state: VoiceConnectionState.failed,
        failure: VoiceFailure.notConfigured,
      );
      return;
    }

    final permission = await _transport.requestMicrophonePermission();
    if (!permission) {
      _update(
        state: VoiceConnectionState.permissionDenied,
        failure: VoiceFailure.permissionDenied,
      );
      return;
    }

    try {
      final credentials = await _tokenProvider.fetch(roomId: roomId);
      final uid = await _uidForIdentity();
      await _transport.connect(
        url: credentials.url.isEmpty ? _config.livekitUrl : credentials.url,
        token: credentials.token,
        playerId: uid,
        playerName: playerName,
      );
      _activeRoomId = roomId;
      _update(state: VoiceConnectionState.connected);
    } on VoiceNotConfiguredException {
      _update(
        state: VoiceConnectionState.failed,
        failure: VoiceFailure.notConfigured,
      );
    } on FirebaseFunctionsException catch (error) {
      _update(
        state: VoiceConnectionState.failed,
        failure: _isFunctionMissing(error)
            ? VoiceFailure.notConfigured
            : VoiceFailure.connectionFailed,
      );
    } catch (_) {
      _update(
        state: VoiceConnectionState.failed,
        failure: VoiceFailure.connectionFailed,
      );
    }
  }

  /// Leaves the voice room and releases the microphone. Safe to call
  /// repeatedly.
  Future<void> leaveRoom() async {
    if (_disposed) return;
    if (_state == VoiceConnectionState.disabled && _activeRoomId == null) {
      return;
    }
    _optOutRoomId = null;
    _activeRoomId = null;
    await _suspendMic();
    try {
      await _transport.disconnect();
    } catch (_) {}
    _participants = const [];
    _update(state: VoiceConnectionState.disabled, clearFailure: true);
  }

  /// Semantic alias for `setMicEnabled(true)`.
  ///
  /// Called by the push-to-talk button when the player presses or holds.
  Future<bool> startTalking() => setMicEnabled(true);

  /// Semantic alias for `setMicEnabled(false)`.
  ///
  /// Idempotent: safe to call multiple times or when already muted.
  Future<bool> stopTalking() => setMicEnabled(false);

  /// Enables or disables the microphone (push-to-talk).
  ///
  /// Returns false when the request could not be satisfied (e.g. not
  /// connected, or the microphone became unavailable).
  Future<bool> setMicEnabled(bool enabled) async {
    if (_disposed) return false;
    if (enabled && !isPushToTalkEnabled) return false;
    if (_micEnabled == enabled) return true;
    try {
      await _transport.setMicrophoneEnabled(enabled);
      _micEnabled = enabled;
      notifyListeners();
      return true;
    } catch (_) {
      _micEnabled = false;
      _update(failure: VoiceFailure.microphoneUnavailable);
      return false;
    }
  }

  /// Force the microphone off. Used by the UI, phase transitions and the app
  /// lifecycle so the mic can never stay hot by accident.
  Future<void> suspendMic() => _suspendMic();

  Future<void> _suspendMic() async {
    if (!_micEnabled) return;
    _micEnabled = false;
    notifyListeners();
    try {
      await _transport.setMicrophoneEnabled(false);
    } catch (_) {}
  }

  /// Retries joining the last room (used by the retry button).
  Future<void> retryJoin() async {
    final roomId = _lastRoomId;
    final playerName = _lastPlayerName;
    if (roomId == null || playerName == null) return;
    _optOutRoomId = null;
    await joinRoom(roomId: roomId, playerName: playerName);
  }

  /// The player chose to continue without voice for this room.
  void continueWithoutVoice() {
    if (_state == VoiceConnectionState.disabled) return;
    if (_activeRoomId == null && _lastRoomId != null) {
      _optOutRoomId = _lastRoomId;
    }
    _suspendMic();
    _participants = const [];
    _update(state: VoiceConnectionState.disabled, clearFailure: true);
  }

  /// Re-requests microphone permission after a denial or loss and resumes.
  Future<void> allowMicrophone() async {
    final granted = await _transport.requestMicrophonePermission();
    if (!granted) {
      _update(failure: VoiceFailure.permissionDenied);
      return;
    }
    switch (_state) {
      case VoiceConnectionState.permissionDenied:
      case VoiceConnectionState.failed:
      case VoiceConnectionState.disconnected:
      case VoiceConnectionState.disabled:
        await retryJoin();
        break;
      case VoiceConnectionState.connected:
        _update(clearFailure: true);
        await setMicEnabled(true);
        break;
      default:
        break;
    }
  }

  Future<String> _uidForIdentity() async {
    final uid = _authService.currentUid;
    if (uid != null && uid.isNotEmpty) return uid;
    return _authService.requireUid();
  }

  static bool _isFunctionMissing(FirebaseFunctionsException error) {
    final code = error.code.toLowerCase();
    return code.contains('not_found') ||
        code.contains('not-found') ||
        code.contains('404');
  }

  void _onLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _suspendMic();
        break;
      default:
        break;
    }
  }

  void _onTransportStatus(VoiceTransportStatus status) {
    switch (status) {
      case VoiceTransportStatus.connecting:
        if (_state == VoiceConnectionState.disabled ||
            _state == VoiceConnectionState.disconnected) {
          _update(state: VoiceConnectionState.joining);
        }
        break;
      case VoiceTransportStatus.connected:
        if (_state == VoiceConnectionState.joining ||
            _state == VoiceConnectionState.reconnecting) {
          _update(state: VoiceConnectionState.connected);
        }
        break;
      case VoiceTransportStatus.reconnecting:
        _suspendMic();
        if (_state == VoiceConnectionState.connected) {
          _update(state: VoiceConnectionState.reconnecting);
        }
        break;
      case VoiceTransportStatus.disconnected:
        if (_state == VoiceConnectionState.connected ||
            _state == VoiceConnectionState.reconnecting ||
            _state == VoiceConnectionState.joining) {
          // Unexpected loss (the transport could not reconnect).
          _suspendMic();
          _activeRoomId = null;
          _update(
            state: VoiceConnectionState.disconnected,
            failure: VoiceFailure.connectionFailed,
          );
        }
        break;
    }
  }

  void _onTransportParticipants(
    List<VoiceTransportParticipant> participants,
  ) {
    _participants = participants
        .map((p) => VoiceParticipant(
              playerId: p.playerId,
              name: p.name,
              state: p.isSpeaking
                  ? VoiceParticipantState.speaking
                  : VoiceParticipantState.muted,
            ))
        .toList();
    notifyListeners();
  }

  void _onTransportError(VoiceTransportError error) {
    switch (error.code) {
      case VoiceErrorCode.permissionDenied:
        _suspendMic();
        _update(failure: VoiceFailure.permissionDenied);
        break;
      case VoiceErrorCode.microphoneUnavailable:
        _suspendMic();
        _update(failure: VoiceFailure.microphoneUnavailable);
        break;
      case VoiceErrorCode.connectionFailed:
        if (_state == VoiceConnectionState.failed ||
            _state == VoiceConnectionState.disconnected ||
            _state == VoiceConnectionState.disabled) {
          break;
        }
        _suspendMic();
        _activeRoomId = null;
        _update(
          state: VoiceConnectionState.disconnected,
          failure: VoiceFailure.connectionFailed,
        );
        break;
    }
  }

  void _update({
    VoiceConnectionState? state,
    VoiceFailure? failure,
    bool clearFailure = false,
  }) {
    var changed = false;
    if (state != null && state != _state) {
      _state = state;
      changed = true;
    }
    if (clearFailure && _failure != null) {
      _failure = null;
      changed = true;
    } else if (failure != null && failure != _failure) {
      _failure = failure;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    _statusSub?.cancel();
    _participantsSub?.cancel();
    _errorsSub?.cancel();
    _statusSub = null;
    _participantsSub = null;
    _errorsSub = null;
    _transport.dispose();
    super.dispose();
  }
}
