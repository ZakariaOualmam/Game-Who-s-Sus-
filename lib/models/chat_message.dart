/// A single chat message from a player during the online discussion phase.
///
/// Stored under `rooms/{roomId}/messages/{messageId}`. The sender identity
/// (`player_id`) is always the authenticated user's UID, never a
/// client-supplied value. Timestamps follow the project convention: UTC
/// ISO-8601 strings, which sort lexicographically for chronological order.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.playerId,
    required this.playerName,
    required this.message,
    required this.createdAt,
    this.type = textType,
  });

  /// All chat documents are plain text; the rules only allow this type.
  static const String textType = 'text';

  /// Maximum length of a chat message enforced by the UI and the rules.
  static const int maxLength = 200;

  final String id;
  final String roomId;

  /// The authenticated UID of the sender.
  final String playerId;

  /// Display name of the sender at the time of sending.
  final String playerName;
  final String message;
  final String type;
  final DateTime createdAt;

  factory ChatMessage.fromMap(Map<String, dynamic> data, {required String id}) {
    return ChatMessage(
      id: id,
      roomId: data['room_id'] as String,
      playerId: data['player_id'] as String,
      playerName: data['player_name'] as String,
      message: data['message'] as String,
      type: (data['type'] as String?) ?? textType,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  /// Serializes the message without its ID (Firestore uses the document ID).
  Map<String, dynamic> toMap() {
    return {
      'room_id': roomId,
      'player_id': playerId,
      'player_name': playerName,
      'message': message,
      'type': type,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
