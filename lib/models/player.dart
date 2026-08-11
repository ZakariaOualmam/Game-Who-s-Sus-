import 'role.dart';

/// A participant in the game. Mutated by the game engine as rounds progress.
class Player {
  Player({required this.id, required this.name, this.role, this.score = 0});

  final String id;
  final String name;

  /// Assigned at the start of each round by the engine.
  Role? role;

  /// Running total kept across rounds.
  int score;

  bool get isImposter => role == Role.imposter;
  bool get isCrew => role == Role.crew;
}
