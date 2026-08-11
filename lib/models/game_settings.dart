/// Tunables for a game session.
class GameSettings {
  const GameSettings({this.imposterCount = 1});

  static const int minPlayers = 4;
  static const int maxPlayers = 8;

  /// Number of imposters per round. Extended later without engine rewrites.
  final int imposterCount;
}
