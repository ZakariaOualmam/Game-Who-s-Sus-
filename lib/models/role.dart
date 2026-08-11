/// The secret role assigned to a player in a round.
enum Role {
  crew,
  imposter;

  String get label => switch (this) {
        Role.crew => 'Crew',
        Role.imposter => 'Imposter',
      };
}
