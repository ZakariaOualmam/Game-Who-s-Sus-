enum OnlineGamePhase {
  lobby,
  category,
  roleReveal,
  discussion,
  voting,
  voteResults,
  imposterReveal,
  imposterGuess,
  winner,
  scoreboard;

  String get dbValue => switch (this) {
        OnlineGamePhase.lobby => 'lobby',
        OnlineGamePhase.category => 'category',
        OnlineGamePhase.roleReveal => 'role_reveal',
        OnlineGamePhase.discussion => 'discussion',
        OnlineGamePhase.voting => 'voting',
        OnlineGamePhase.voteResults => 'vote_results',
        OnlineGamePhase.imposterReveal => 'imposter_reveal',
        OnlineGamePhase.imposterGuess => 'imposter_guess',
        OnlineGamePhase.winner => 'winner',
        OnlineGamePhase.scoreboard => 'scoreboard',
      };

  static OnlineGamePhase fromDb(String value) {
    return switch (value) {
      'lobby' => OnlineGamePhase.lobby,
      'category' => OnlineGamePhase.category,
      'role_reveal' => OnlineGamePhase.roleReveal,
      'discussion' => OnlineGamePhase.discussion,
      'voting' => OnlineGamePhase.voting,
      'vote_results' => OnlineGamePhase.voteResults,
      'imposter_reveal' => OnlineGamePhase.imposterReveal,
      'imposter_guess' => OnlineGamePhase.imposterGuess,
      'winner' => OnlineGamePhase.winner,
      'scoreboard' => OnlineGamePhase.scoreboard,
      _ => OnlineGamePhase.lobby,
    };
  }
}
