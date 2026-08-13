class OnlineRound {
  const OnlineRound({
    required this.id,
    required this.roomId,
    required this.roundNumber,
    required this.categoryId,
    required this.languageCode,
    required this.accusedPlayerId,
    required this.imposterPlayerId,
    required this.winnerSide,
    required this.guessedCorrectly,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String roomId;
  final int roundNumber;
  final String categoryId;
  final String languageCode;
  final String? accusedPlayerId;
  final String? imposterPlayerId;
  final String? winnerSide;
  final bool? guessedCorrectly;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory OnlineRound.fromMap(Map<String, dynamic> data, {required String id}) {
    return OnlineRound(
      id: id,
      roomId: data['room_id'] as String,
      roundNumber: data['round_number'] as int,
      categoryId: data['category_id'] as String,
      languageCode: data['language_code'] as String,
      accusedPlayerId: data['accused_player_id'] as String?,
      imposterPlayerId: data['imposter_player_id'] as String?,
      winnerSide: data['winner_side'] as String?,
      guessedCorrectly: data['guessed_correctly'] as bool?,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  /// Serializes the round without its ID (Firestore uses the document ID).
  Map<String, dynamic> toMap() {
    return {
      'room_id': roomId,
      'round_number': roundNumber,
      'category_id': categoryId,
      'language_code': languageCode,
      'accused_player_id': accusedPlayerId,
      'imposter_player_id': imposterPlayerId,
      'winner_side': winnerSide,
      'guessed_correctly': guessedCorrectly,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
