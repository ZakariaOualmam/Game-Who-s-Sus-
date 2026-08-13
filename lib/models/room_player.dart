/// Represents a player connected to an online room.
class RoomPlayer {
  const RoomPlayer({
    required this.id,
    required this.roomId,
    required this.playerId,
    required this.playerName,
    required this.isHost,
    required this.score,
    required this.isConnected,
    required this.lastSeen,
    required this.joinedAt,
  });

  final String id;
  final String roomId;
  final String playerId;
  final String playerName;
  final bool isHost;
  final int score;
  final bool isConnected;
  final DateTime lastSeen;
  final DateTime joinedAt;

  factory RoomPlayer.fromMap(Map<String, dynamic> data, {required String id}) {
    return RoomPlayer(
      id: id,
      roomId: data['room_id'] as String,
      playerId: data['player_id'] as String,
      playerName: data['player_name'] as String,
      isHost: (data['is_host'] as bool?) ?? false,
      score: (data['score'] as int?) ?? 0,
      isConnected: (data['is_connected'] as bool?) ?? true,
      lastSeen: DateTime.parse(
        (data['last_seen'] as String?) ??
            DateTime.now().toUtc().toIso8601String(),
      ),
      joinedAt: DateTime.parse(data['joined_at'] as String),
    );
  }

  /// Serializes the player without its ID (Firestore uses the document ID,
  /// which equals the player ID).
  Map<String, dynamic> toMap() {
    return {
      'room_id': roomId,
      'player_id': playerId,
      'player_name': playerName,
      'is_host': isHost,
      'score': score,
      'is_connected': isConnected,
      'last_seen': lastSeen.toIso8601String(),
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  RoomPlayer copyWith({
    String? id,
    String? roomId,
    String? playerId,
    String? playerName,
    bool? isHost,
    int? score,
    bool? isConnected,
    DateTime? lastSeen,
    DateTime? joinedAt,
  }) {
    return RoomPlayer(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      isHost: isHost ?? this.isHost,
      score: score ?? this.score,
      isConnected: isConnected ?? this.isConnected,
      lastSeen: lastSeen ?? this.lastSeen,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
