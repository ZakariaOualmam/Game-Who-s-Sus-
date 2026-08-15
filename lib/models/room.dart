import 'game_settings.dart';

/// Represents an online multiplayer room in the lobby phase.
class Room {
  const Room({
    required this.id,
    required this.code,
    required this.hostPlayerId,
    required this.status,
    required this.gamePhase,
    required this.maxPlayers,
    required this.currentRoundNumber,
    required this.activeRoundId,
    required this.selectedCategoryId,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String code;
  final String hostPlayerId;
  final String status; // 'lobby', 'playing', 'finished'
  final String gamePhase;
  final int maxPlayers;
  final GameSettings settings;
  final int currentRoundNumber;
  final String? activeRoundId;
  final String? selectedCategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Builds a [Room] from a Firestore document snapshot.
  /// The document ID is passed separately since Firestore does not store it
  /// inside the document data.
  factory Room.fromMap(Map<String, dynamic> data, {required String id}) {
    return Room(
      id: id,
      code: data['code'] as String,
      hostPlayerId: data['host_player_id'] as String,
      status: data['status'] as String,
      gamePhase: (data['game_phase'] as String?) ?? 'lobby',
      maxPlayers: (data['max_players'] as int?) ?? GameSettings.maxPlayers,
      currentRoundNumber: (data['current_round_number'] as int?) ?? 0,
      activeRoundId: data['active_round_id'] as String?,
      selectedCategoryId: data['selected_category_id'] as String?,
      settings: GameSettings.fromMap(data['settings'] as Map<String, dynamic>?),
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  /// Serializes the room without its ID (Firestore uses the document ID).
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'host_player_id': hostPlayerId,
      'status': status,
      'game_phase': gamePhase,
      'max_players': maxPlayers,
      'current_round_number': currentRoundNumber,
      'active_round_id': activeRoundId,
      'selected_category_id': selectedCategoryId,
      'settings': settings.toMap(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Room copyWith({
    String? id,
    String? code,
    String? hostPlayerId,
    String? status,
    String? gamePhase,
    int? maxPlayers,
    int? currentRoundNumber,
    String? activeRoundId,
    String? selectedCategoryId,
    GameSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      code: code ?? this.code,
      hostPlayerId: hostPlayerId ?? this.hostPlayerId,
      status: status ?? this.status,
      gamePhase: gamePhase ?? this.gamePhase,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentRoundNumber: currentRoundNumber ?? this.currentRoundNumber,
      activeRoundId: activeRoundId ?? this.activeRoundId,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
