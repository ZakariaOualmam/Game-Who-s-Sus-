import '../models/online_game_phase.dart';
import '../models/vote.dart';

class OnlinePrivateStateView {
  const OnlinePrivateStateView({
    required this.playerId,
    required this.role,
    required this.secretWord,
    required this.guessOptions,
  });

  final String playerId;
  final String role;
  final String? secretWord;
  final List<String>? guessOptions;
}

class OnlineSyncRules {
  const OnlineSyncRules._();

  static bool canVote({
    required String voterId,
    required String targetId,
  }) {
    return voterId != targetId;
  }

  static List<Vote> upsertVote({
    required List<Vote> existing,
    required Vote next,
  }) {
    final updated = existing.where((v) => v.voterId != next.voterId).toList();
    updated.add(next);
    return updated;
  }

  static bool isVotingComplete({
    required int playerCount,
    required List<Vote> votes,
  }) {
    return votes.length >= playerCount;
  }

  static Map<String, int> voteCounts(List<Vote> votes) {
    final counts = <String, int>{};
    for (final vote in votes) {
      counts[vote.targetId] = (counts[vote.targetId] ?? 0) + 1;
    }
    return counts;
  }

  static String? accusedPlayerId({
    required List<String> playerIds,
    required List<Vote> votes,
  }) {
    if (votes.isEmpty) return null;
    final counts = voteCounts(votes);

    var topVotes = 0;
    for (final id in playerIds) {
      final count = counts[id] ?? 0;
      if (count > topVotes) topVotes = count;
    }

    final top = playerIds.where((id) => (counts[id] ?? 0) == topVotes).toList();
    if (top.length != 1) return null;
    return top.first;
  }

  static OnlinePrivateStateView? visiblePrivateStateFor({
    required String currentPlayerId,
    required List<OnlinePrivateStateView> allStates,
  }) {
    for (final state in allStates) {
      if (state.playerId == currentPlayerId) return state;
    }
    return null;
  }

  static bool shouldResumeSession({
    required String roomStatus,
    required String roomPhase,
  }) {
    final phase = OnlineGamePhase.fromDb(roomPhase);
    if (roomStatus != 'lobby' && roomStatus != 'playing') return false;
    return phase != OnlineGamePhase.lobby || roomStatus == 'lobby';
  }

  static String? nextHostPlayerIdByJoinOrder(List<String> joinedPlayerIds) {
    if (joinedPlayerIds.isEmpty) return null;
    return joinedPlayerIds.first;
  }
}
