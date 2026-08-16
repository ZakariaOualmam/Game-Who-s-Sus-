import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/core/theme/app_theme.dart';
import 'package:who_sus/data/categories.dart';
import 'package:who_sus/game/game_engine.dart';
import 'package:who_sus/l10n/app_localizations.dart';
import 'package:who_sus/models/game_settings.dart';
import 'package:who_sus/models/player.dart';
import 'package:who_sus/screens/offline/discussion_screen.dart';
import 'package:who_sus/screens/offline/vote_results_screen.dart';
import 'package:who_sus/screens/offline/voting_screen.dart';
import 'package:who_sus/services/word_repository.dart';
import 'package:who_sus/widgets/game_button.dart';
import 'package:who_sus/widgets/game_countdown.dart';
import 'package:who_sus/widgets/player_card.dart';

class _StubWordSource implements WordSource {
  @override
  Future<String> randomWord(WordCategory category) async => 'elephant';

  @override
  Future<List<String>> loadWords(WordCategory category) async =>
      ['elephant', 'lion', 'tiger'];

  @override
  Future<List<String>> decoyWords({
    required WordCategory category,
    required String correctWord,
    required int count,
  }) async =>
      ['lion', 'tiger', 'bear'].take(count).toList();
}

GameEngine _engine({GameSettings settings = const GameSettings()}) {
  return GameEngine(
    players: [
      for (var i = 0; i < 4; i++) Player(id: 'p$i', name: 'Player $i'),
    ],
    wordSource: _StubWordSource(),
    settings: settings,
  );
}

Widget _localizedApp(Widget home) {
  return MaterialApp(
    theme: AppTheme.dark(),
    locale: const Locale('en'),
    supportedLocales: const [Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  );
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  group('DiscussionScreen timer', () {
    testWidgets('shows the configured discussion countdown and advances to '
        'voting automatically at zero', (tester) async {
      final engine = _engine(
        settings: const GameSettings(discussionTime: Duration(seconds: 3)),
      );
      await engine.startRound(categories.first);
      await tester.pumpWidget(_localizedApp(DiscussionScreen(engine: engine)));
      await tester.pumpAndSettle();

      expect(find.byType(GameCountdown), findsOneWidget);
      expect(find.text('TIME LEFT'), findsOneWidget);
      expect(find.text('3s'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(VotingScreen), findsOneWidget);
    });

    testWidgets('manual START VOTING still advances immediately',
        (tester) async {
      final engine = _engine();
      await engine.startRound(categories.first);
      await tester.pumpWidget(_localizedApp(DiscussionScreen(engine: engine)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('START VOTING'));
      await tester.pumpAndSettle();

      expect(find.byType(VotingScreen), findsOneWidget);
    });

    testWidgets('respects a non-default discussion duration', (tester) async {
      final engine = _engine(
        settings: const GameSettings(discussionTime: Duration(seconds: 30)),
      );
      await engine.startRound(categories.first);
      await tester.pumpWidget(_localizedApp(DiscussionScreen(engine: engine)));
      await tester.pumpAndSettle();

      expect(find.text('30s'), findsOneWidget);
    });
  });

  group('VotingScreen timer', () {
    testWidgets('shows the voting countdown and finalizes to results at zero',
        (tester) async {
      final engine = _engine(
        settings: const GameSettings(votingTime: Duration(seconds: 3)),
      );
      await engine.startRound(categories.first);
      await tester.pumpWidget(_localizedApp(VotingScreen(engine: engine)));
      await tester.pumpAndSettle();

      expect(find.byType(GameCountdown), findsOneWidget);
      expect(find.text('3s'), findsOneWidget);

      // Time runs out before anyone votes: results show a tie.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(VoteResultsScreen), findsOneWidget);
      expect(find.text("IT'S A TIE!"), findsOneWidget);
    });

    testWidgets('manual votes still reach results without a duplicate '
        'transition when the timer later expires', (tester) async {
      final engine = _engine(
        settings: const GameSettings(votingTime: Duration(seconds: 3)),
      );
      await engine.startRound(categories.first);
      await tester.pumpWidget(_localizedApp(VotingScreen(engine: engine)));
      await tester.pumpAndSettle();

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byType(PlayerCard).first);
        await tester.pump();
        await tester.tap(find.textContaining('VOTE FOR'));
        await tester.pumpAndSettle();
      }

      expect(find.byType(VoteResultsScreen), findsOneWidget);

      // The disposed screen's timer must not fire a second navigation.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byType(VoteResultsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('manual votes only advance after confirming a selection',
        (tester) async {
      final engine = _engine();
      await engine.startRound(categories.first);
      await tester.pumpWidget(_localizedApp(VotingScreen(engine: engine)));
      await tester.pumpAndSettle();

      // No selection yet: the confirm button must not exist.
      expect(find.textContaining('VOTE FOR'), findsNothing);
      expect(find.byType(GameButton), findsNothing);
    });
  });
}
