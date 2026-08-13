class OnlinePlayerRoundState {
  const OnlinePlayerRoundState({
    required this.id,
    required this.roundId,
    required this.roomId,
    required this.playerId,
    required this.role,
    required this.secretWord,
    required this.guessOptions,
    required this.revealReady,
    required this.discussionReady,
    required this.submittedGuess,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String roundId;
  final String roomId;
  final String playerId;
  final String role;
  final String? secretWord;
  final List<String>? guessOptions;
  final bool revealReady;
  final bool discussionReady;
  final String? submittedGuess;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isImposter => role == 'imposter';

  factory OnlinePlayerRoundState.fromMap(Map<String, dynamic> data,
      {required String id}) {
    final rawOptions = data['guess_options'];
    return OnlinePlayerRoundState(
      id: id,
      roundId: data['round_id'] as String,
      roomId: data['room_id'] as String,
      playerId: data['player_id'] as String,
      role: data['role'] as String,
      secretWord: data['secret_word'] as String?,
      guessOptions: rawOptions == null
          ? null
          : (rawOptions as List<dynamic>).map((e) => e as String).toList(),
      revealReady: (data['reveal_ready'] as bool?) ?? false,
      discussionReady: (data['discussion_ready'] as bool?) ?? false,
      submittedGuess: data['submitted_guess'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  /// Serializes the state without its ID (Firestore uses the document ID,
  /// which equals the player ID).
  Map<String, dynamic> toMap() {
    return {
      'round_id': roundId,
      'room_id': roomId,
      'player_id': playerId,
      'role': role,
      'secret_word': secretWord,
      'guess_options': guessOptions,
      'reveal_ready': revealReady,
      'discussion_ready': discussionReady,
      'submitted_guess': submittedGuess,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
