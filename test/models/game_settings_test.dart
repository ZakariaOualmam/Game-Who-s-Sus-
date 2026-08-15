import 'package:flutter_test/flutter_test.dart';
import 'package:who_sus/models/game_settings.dart';

void main() {
  group('GameSettings defaults', () {
    test('uses 4 players, 1 imposter, 60s/60s, no flags', () {
      const settings = GameSettings();
      expect(settings.playerCount, 4);
      expect(settings.imposterCount, 1);
      expect(settings.discussionTime, const Duration(minutes: 1));
      expect(settings.votingTime, const Duration(minutes: 1));
      expect(settings.anonymousVoting, isFalse);
      expect(settings.imposterClue, isFalse);
    });
  });

  group('GameSettings.maxImpostersFor', () {
    test('keeps at least three crew members', () {
      expect(GameSettings.maxImpostersFor(4), 1);
      expect(GameSettings.maxImpostersFor(5), 2);
      expect(GameSettings.maxImpostersFor(8), 2);
      expect(GameSettings.maxImpostersFor(3), 0);
      expect(GameSettings.maxImpostersFor(2), 0);
    });
  });

  group('GameSettings.validationIssue', () {
    test('accepts a valid configuration', () {
      const settings = GameSettings(playerCount: 6, imposterCount: 1);
      expect(
        settings.validationIssue(actualPlayerCount: 6),
        isNull,
      );
    });

    test('rejects a player count outside the supported range', () {
      const settings = GameSettings(playerCount: 3);
      expect(
        settings.validationIssue(actualPlayerCount: 3),
        GameSettingsIssue.invalidPlayerCount,
      );
      const tooMany = GameSettings(playerCount: 9);
      expect(
        tooMany.validationIssue(actualPlayerCount: 9),
        GameSettingsIssue.invalidPlayerCount,
      );
    });

    test('rejects more imposters than the player count allows', () {
      const settings = GameSettings(playerCount: 4, imposterCount: 2);
      expect(
        settings.validationIssue(actualPlayerCount: 4),
        GameSettingsIssue.tooManyImposters,
      );
    });

    test('rejects imposters beyond what gameplay supports', () {
      const settings = GameSettings(playerCount: 6, imposterCount: 2);
      expect(
        settings.validationIssue(actualPlayerCount: 6),
        GameSettingsIssue.unsupportedImposterCount,
      );
    });
  });

  group('GameSettings serialization', () {
    test('round-trips through toMap/fromMap', () {
      const settings = GameSettings(
        playerCount: 7,
        imposterCount: 2,
        discussionTime: Duration(minutes: 1, seconds: 30),
        votingTime: Duration(seconds: 30),
        anonymousVoting: true,
        imposterClue: true,
      );
      final restored = GameSettings.fromMap(settings.toMap());
      expect(restored, settings);
    });

    test('fromMap falls back to defaults for missing data', () {
      final restored = GameSettings.fromMap(null);
      expect(restored, const GameSettings());
      final partial = GameSettings.fromMap({'imposter_count': 1});
      expect(partial, const GameSettings());
    });
  });

  group('GameSettings.copyWith and forPlayerCount', () {
    test('copyWith overrides only the provided fields', () {
      const settings = GameSettings();
      final updated = settings.copyWith(
        playerCount: 6,
        anonymousVoting: true,
      );
      expect(updated.playerCount, 6);
      expect(updated.anonymousVoting, isTrue);
      expect(updated.imposterCount, 1);
      expect(updated.discussionTime, const Duration(minutes: 1));
    });

    test('forPlayerCount returns a copy with the player count set', () {
      final updated = const GameSettings().forPlayerCount(6);
      expect(updated.playerCount, 6);
      expect(updated, isNot(const GameSettings()));
    });
  });

  group('GameSettings equality', () {
    test('two identical settings are equal', () {
      expect(const GameSettings(), const GameSettings());
      expect(
        const GameSettings(anonymousVoting: true),
        const GameSettings(anonymousVoting: true),
      );
      expect(
        const GameSettings(anonymousVoting: true),
        isNot(const GameSettings()),
      );
    });
  });
}
