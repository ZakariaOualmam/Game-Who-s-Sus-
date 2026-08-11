/// The high-level stage a game round is in.
///
/// Kept on the model so the game engine can drive the UI purely by phase.
enum GamePhase {
  setup,
  category,
  roleReveal,
  discussion,
  voting,
  voteResults,
  imposterReveal,
  imposterGuess,
  winner,
  scoreboard;
}
