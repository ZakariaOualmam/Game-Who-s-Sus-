import 'dart:math';

import '../data/categories.dart';
import '../models/game_phase.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import '../models/role.dart';
import '../models/round_result.dart';
import '../models/vote.dart';
import '../services/word_repository.dart';

/// Pure game logic, fully decoupled from the UI.
///
/// The same engine drives both offline (pass-the-phone) and online modes:
/// online mode simply syncs the same state through a remote layer.
class GameEngine {
  GameEngine({
    required this.players,
    required this.wordSource,
    this.settings = const GameSettings(),
  });

  final List<Player> players;
  final WordSource wordSource;
  final GameSettings settings;

  GamePhase phase = GamePhase.setup;
  WordCategory? category;
  String? secretWord;
  Player? imposter;

  /// Reveal sequence cursor: each player takes 2 steps (pass + role shown).
  int revealStep = 0;
  final List<Vote> votes = [];
  String? imposterGuess;
  RoundResult? lastRound;

  bool get isRevealComplete => revealStep >= players.length * 2;

  Player playerById(String id) => players.firstWhere((p) => p.id == id);

  /// Starts a new round: picks a secret word, assigns roles, resets state.
  Future<void> startRound(WordCategory selectedCategory) async {
    category = selectedCategory;
    secretWord = await wordSource.randomWord(selectedCategory);
    _assignRoles();
    revealStep = 0;
    votes.clear();
    imposterGuess = null;
    lastRound = null;
    phase = GamePhase.roleReveal;
  }

  void _assignRoles() {
    for (final player in players) {
      player.role = null;
    }
    final shuffled = [...players]..shuffle(Random());
    for (var i = 0; i < shuffled.length; i++) {
      shuffled[i].role = i < settings.imposterCount ? Role.imposter : Role.crew;
    }
    imposter = players.firstWhere((p) => p.isImposter);
  }

  // --- Pass-phone reveal sequence ---

  Player playerAtRevealStep() {
    final index = revealStep ~/ 2;
    return players[index % players.length];
  }

  bool get isRoleShownAtCurrentStep => revealStep.isOdd;

  void nextRevealStep() {
    if (!isRevealComplete) revealStep++;
  }

  // --- Voting ---

  void castVote({required String voterId, required String targetId}) {
    votes.removeWhere((v) => v.voterId == voterId);
    votes.add(Vote(voterId: voterId, targetId: targetId));
  }

  bool get allPlayersVoted => votes.length >= players.length;

  Map<String, int> get voteCounts {
    final counts = <String, int>{};
    for (final vote in votes) {
      counts[vote.targetId] = (counts[vote.targetId] ?? 0) + 1;
    }
    return counts;
  }

  /// The player with the most votes, or null when nothing has been voted.
  Player? get accusedPlayer {
    final counts = voteCounts;
    Player? top;
    var topVotes = 0;
    for (final player in players) {
      final count = counts[player.id] ?? 0;
      if (count > topVotes) {
        topVotes = count;
        top = player;
      }
    }
    return top;
  }

  bool get isImposterCaught => accusedPlayer?.id == imposter?.id;

  // --- Imposter final guess & results ---

  void submitImposterGuess(String guess) {
    imposterGuess = guess.trim();
  }

  bool get guessedCorrectly {
    if (imposterGuess == null || secretWord == null) return false;
    return imposterGuess!.toLowerCase() == secretWord!.toLowerCase();
  }

  /// Computes the round outcome, applies score changes, and returns the result.
  RoundResult finishRound() {
    final imp = imposter!;
    final word = secretWord!;
    final accused = accusedPlayer;
    final caught = accused?.id == imp.id;
    final correct = guessedCorrectly;
    final crewWins = caught && !correct;

    final changes = <String, int>{};
    if (crewWins) {
      for (final player in players) {
        if (player.isCrew) changes[player.id] = 1;
      }
    } else {
      changes[imp.id] = 2;
    }
    for (final entry in changes.entries) {
      playerById(entry.key).score += entry.value;
    }

    final result = RoundResult(
      secretWord: word,
      imposter: imp,
      accusedPlayer: accused,
      votes: List.of(votes),
      imposterGuess: imposterGuess,
      guessedCorrectly: correct,
      crewWins: crewWins,
      scoreChanges: changes,
    );
    lastRound = result;
    phase = GamePhase.winner;
    return result;
  }

  /// Clears round state so another round can be played with the same players.
  void resetForNewRound() {
    for (final player in players) {
      player.role = null;
    }
    category = null;
    secretWord = null;
    imposter = null;
    revealStep = 0;
    votes.clear();
    imposterGuess = null;
    lastRound = null;
    phase = GamePhase.category;
  }
}
