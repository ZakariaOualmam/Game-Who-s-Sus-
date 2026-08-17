import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Thrown when the voice backend has not been configured or deployed.
class VoiceNotConfiguredException implements Exception {
  const VoiceNotConfiguredException();

  @override
  String toString() =>
      'VoiceNotConfiguredException: LiveKit is not configured.';
}

/// Runtime configuration for the voice chat feature.
@immutable
class VoiceConfig {
  const VoiceConfig({
    this.enabled = false,
    this.livekitUrl = '',
  });

  /// When false, voice chat is disabled entirely.
  final bool enabled;

  /// Fallback LiveKit server URL used only when the token provider does not
  /// return one. In production the backend returns the server URL, so this
  /// can stay empty.
  final String livekitUrl;
}

/// Credentials returned by the backend needed to join a voice room.
@immutable
class VoiceJoinCredentials {
  const VoiceJoinCredentials({required this.url, required this.token});

  final String url;
  final String token;
}

/// Fetches a short-lived, room-scoped LiveKit join token from the backend.
///
/// Tokens are minted only server-side so no LiveKit secret ever reaches the
/// app. Implementations are injected so tests can provide fake credentials.
abstract class VoiceTokenProvider {
  Future<VoiceJoinCredentials> fetch({required String roomId});
}

/// Default provider that calls the Firebase Cloud Function `getVoiceToken`.
///
/// The function validates that the caller is a member of
/// `rooms/{roomId}/players/{uid}` and returns `{ url, token }`.
class CallableVoiceTokenProvider implements VoiceTokenProvider {
  CallableVoiceTokenProvider({
    FirebaseFunctions? functions,
    this.functionName = 'getVoiceToken',
  }) : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;
  final String functionName;

  @override
  Future<VoiceJoinCredentials> fetch({required String roomId}) async {
    final result =
        await _functions.httpsCallable(functionName).call<Map<String, dynamic>>(
              {'roomId': roomId},
            );

    final data = result.data;
    final url = data['url'] as String?;
    final token = data['token'] as String?;
    if (url == null || url.isEmpty || token == null || token.isEmpty) {
      throw const VoiceNotConfiguredException();
    }
    return VoiceJoinCredentials(url: url, token: token);
  }
}
