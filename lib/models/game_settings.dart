import 'dart:math';

/// Tunables for a game session.
class GameSettings {
  const GameSettings({
    this.playerCount = minPlayers,
    this.imposterCount = 1,
    this.discussionTime = const Duration(minutes: 1),
    this.votingTime = const Duration(minutes: 1),
    this.anonymousVoting = false,
    this.imposterClue = false,
  });

  static const int minPlayers = 4;
  static const int maxPlayers = 8;

  /// Crew members a game must always have (imposterCount is capped by this).
  static const int minCrewMembers = 3;

  /// Maximum number of imposters the game rules support.
  static const int maxImposters = 2;

  /// Number of imposters gameplay currently supports end-to-end.
  ///
  /// The engine can assign more than one imposter, but the reveal, guess and
  /// online sync layers all assume a single imposter, so values above this are
  /// blocked before a game starts.
  static const int supportedImposters = 1;

  static const List<Duration> discussionTimeOptions = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 1, seconds: 30),
    Duration(minutes: 2),
  ];

  static const List<Duration> votingTimeOptions = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 1, seconds: 30),
  ];

  /// The number of players the game is set up for.
  final int playerCount;

  /// Number of imposters per round.
  final int imposterCount;

  /// Discussion phase duration.
  final Duration discussionTime;

  /// Voting phase duration.
  final Duration votingTime;

  /// When true, who voted for whom is hidden from other players.
  final bool anonymousVoting;

  /// When true, crew members receive a hint about the imposter.
  final bool imposterClue;

  /// The most imposters a game with [playerCount] players can host while
  /// keeping at least [minCrewMembers] crew members.
  static int maxImpostersFor(int playerCount) {
    final byPlayerCount = playerCount - minCrewMembers;
    if (byPlayerCount <= 0) return 0;
    return min(maxImposters, byPlayerCount);
  }

  /// Returns a copy whose [playerCount] reflects the actual number of players
  /// in the game (used when the player count is derived, e.g. offline).
  GameSettings forPlayerCount(int count) => copyWith(playerCount: count);

  /// Returns an issue describing why this configuration cannot start a game
  /// with [actualPlayerCount] players, or null when it can.
  GameSettingsIssue? validationIssue({required int actualPlayerCount}) {
    if (actualPlayerCount < minPlayers || actualPlayerCount > maxPlayers) {
      return GameSettingsIssue.invalidPlayerCount;
    }
    if (imposterCount < 1 ||
        imposterCount > maxImpostersFor(actualPlayerCount)) {
      return GameSettingsIssue.tooManyImposters;
    }
    if (imposterCount > supportedImposters) {
      return GameSettingsIssue.unsupportedImposterCount;
    }
    return null;
  }

  GameSettings copyWith({
    int? playerCount,
    int? imposterCount,
    Duration? discussionTime,
    Duration? votingTime,
    bool? anonymousVoting,
    bool? imposterClue,
  }) {
    return GameSettings(
      playerCount: playerCount ?? this.playerCount,
      imposterCount: imposterCount ?? this.imposterCount,
      discussionTime: discussionTime ?? this.discussionTime,
      votingTime: votingTime ?? this.votingTime,
      anonymousVoting: anonymousVoting ?? this.anonymousVoting,
      imposterClue: imposterClue ?? this.imposterClue,
    );
  }

  /// Builds settings from a Firestore map. Returns defaults for missing data
  /// so rooms created before settings existed still work.
  factory GameSettings.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const GameSettings();
    return GameSettings(
      playerCount: (data['player_count'] as int?) ?? minPlayers,
      imposterCount: (data['imposter_count'] as int?) ?? 1,
      discussionTime: Duration(seconds: data['discussion_time'] as int? ?? 60),
      votingTime: Duration(seconds: data['voting_time'] as int? ?? 60),
      anonymousVoting: (data['anonymous_voting'] as bool?) ?? false,
      imposterClue: (data['imposter_clue'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'player_count': playerCount,
      'imposter_count': imposterCount,
      'discussion_time': discussionTime.inSeconds,
      'voting_time': votingTime.inSeconds,
      'anonymous_voting': anonymousVoting,
      'imposter_clue': imposterClue,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is GameSettings &&
        other.playerCount == playerCount &&
        other.imposterCount == imposterCount &&
        other.discussionTime == discussionTime &&
        other.votingTime == votingTime &&
        other.anonymousVoting == anonymousVoting &&
        other.imposterClue == imposterClue;
  }

  @override
  int get hashCode => Object.hash(
        playerCount,
        imposterCount,
        discussionTime,
        votingTime,
        anonymousVoting,
        imposterClue,
      );
}

/// Reasons a [GameSettings] configuration cannot start a game.
enum GameSettingsIssue {
  /// The player count is outside the supported range.
  invalidPlayerCount,

  /// More imposters requested than the player count allows.
  tooManyImposters,

  /// The requested imposter count is not supported by gameplay yet.
  unsupportedImposterCount,
}
