import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wordimposter/core/theme/app_theme.dart';
import 'package:wordimposter/data/categories.dart';
import 'package:wordimposter/game/game_engine.dart';
import 'package:wordimposter/main.dart';
import 'package:wordimposter/models/player.dart';
import 'package:wordimposter/screens/offline/imposter_guess_screen.dart';
import 'package:wordimposter/screens/offline/role_reveal_screen.dart';
import 'package:wordimposter/services/word_repository.dart';
import 'package:wordimposter/widgets/game_button.dart';
import 'package:wordimposter/widgets/player_card.dart';

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

GameEngine _engine({WordSource? wordSource}) {
  return GameEngine(
    players: [
      for (var i = 0; i < 4; i++) Player(id: 'p$i', name: 'Player $i'),
    ],
    wordSource: wordSource ?? _StubWordSource(),
  );
}

Widget _wrap(GameEngine engine) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: ImposterGuessScreen(engine: engine),
  );
}

void main() {
  testWidgets('app launches splash then shows home screen', (tester) async {
    await tester.pumpWidget(const WordImposterApp());

    // Splash is shown first.
    expect(find.text('IMPOSTER'), findsOneWidget);

    // Advance past the splash timer, then settle navigation animations.
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('OFFLINE'), findsOneWidget);
    expect(find.textContaining('COMING SOON'), findsOneWidget);
  });

  testWidgets('setup screen accepts players and reaches category selection',
      (tester) async {
    await tester.pumpWidget(const WordImposterApp());
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OFFLINE'));
    await tester.pumpAndSettle();
    expect(find.text('Player name'), findsOneWidget);

    for (final name in ['Anna', 'Ben', 'Cara', 'Dmitri']) {
      await tester.enterText(find.byType(TextField), name);
      await tester.tap(find.text('ADD PLAYER'));
      await tester.pumpAndSettle();
    }
    expect(find.byType(PlayerCard), findsNWidgets(4));

    await tester.tap(find.text('PICK CATEGORY'));
    await tester.pumpAndSettle();

    expect(find.text('Pick a word category'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('guess screen gates the options behind a pass to the imposter',
      (tester) async {
    final engine = _engine();
    await engine.startRound(categories.first);
    await tester.pumpWidget(_wrap(engine));
    await tester.pumpAndSettle();

    // The imposter's identity is public, but the answer set must be gated.
    expect(find.text("I'M READY"), findsOneWidget);
    expect(find.text(engine.secretWord!), findsNothing);

    await tester.tap(find.text("I'M READY"));
    await tester.pumpAndSettle();

    // Exactly 4 choices, and the correct word appears exactly once.
    expect(find.byType(GameButton), findsNWidgets(4));
    expect(find.text(engine.secretWord!), findsOneWidget);
  });

  testWidgets('role reveal hides the previous secret before the next player',
      (tester) async {
    final engine = _engine();
    await engine.startRound(categories.first);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: RoleRevealScreen(engine: engine),
    ));
    await tester.pumpAndSettle();

    // First player must explicitly confirm before their role is shown.
    expect(find.text("I'M READY"), findsOneWidget);
    expect(find.textContaining('YOUR SECRET WORD'), findsNothing);
    expect(find.textContaining('YOU ARE THE'), findsNothing);

    await tester.tap(find.text("I'M READY"));
    await tester.pumpAndSettle();
    expect(find.text('Player 0'), findsWidgets);

    // Advance: the screen must blank before the next player's pass view.
    await tester.tap(find.text('PASS THE PHONE'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('No peeking at the next player'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Next player's pass view: no trace of player 0's secret.
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text("I'M READY"), findsOneWidget);
    expect(find.textContaining('YOUR SECRET WORD'), findsNothing);
    expect(find.textContaining('YOU ARE THE'), findsNothing);
  });
}
