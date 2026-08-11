import 'player.dart';
import 'vote.dart';

/// Immutable outcome of a finished round.
class RoundResult {
  RoundResult({
    required this.secretWord,
    required this.imposter,
    required this.votes,
    required this.imposterGuess,
    required this.guessedCorrectly,
    required this.crewWins,
    required this.scoreChanges,
    this.accusedPlayer,
  });

  final String secretWord;
  final Player imposter;
  final Player? accusedPlayer;
  final List<Vote> votes;
  final String? imposterGuess;
  final bool guessedCorrectly;
  final bool crewWins;

  /// playerId -> points awarded in this round.
  final Map<String, int> scoreChanges;
}
