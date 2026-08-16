import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/core/theme/app_theme.dart';
import 'package:who_sus/data/categories.dart';
import 'package:who_sus/l10n/app_localizations.dart';
import 'package:who_sus/l10n/app_localizations_en.dart';
import 'package:who_sus/models/game_settings.dart';
import 'package:who_sus/models/online_game_phase.dart';
import 'package:who_sus/models/room.dart';
import 'package:who_sus/models/room_player.dart';
import 'package:who_sus/screens/online/online_game_screen.dart';
import 'package:who_sus/services/chat_service.dart';
import 'package:who_sus/services/firebase_auth_service.dart';
import 'package:who_sus/services/online_game_service.dart';
import 'package:who_sus/services/room_service.dart';
import 'package:who_sus/services/voice_chat_service.dart';
import 'package:who_sus/services/word_repository.dart';
import 'package:who_sus/widgets/chat_panel.dart';
import 'package:who_sus/widgets/game_countdown.dart';
import 'package:who_sus/widgets/player_card.dart';

import 'helpers/fake_voice.dart';
import 'helpers/settling_firestore.dart';

class _StubWordSource implements WordSource {
  @override
  Future<List<String>> decoyWords({
    required WordCategory category,
    required String correctWord,
    required int count,
  }) async {
    return ['lion', 'tiger', 'bear'].take(count).toList();
  }

  @override
  Future<List<String>> loadWords(WordCategory category) async {
    return ['elephant', 'lion', 'tiger', 'bear'];
  }

  @override
  Future<String> randomWord(WordCategory category) async => 'elephant';
}

MockFirebaseAuth _authFor(String uid) {
  return MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(uid: uid, isAnonymous: true),
  );
}

FirebaseAuthService _authService(MockFirebaseAuth auth) =>
    FirebaseAuthService.forTesting(auth);

class _PlayerContext {
  _PlayerContext(this.uid, SettlingFirestore firestore)
      : roomService = RoomService(
          firestore: firestore,
          authService: _authService(_authFor(uid)),
        ),
        chatService = ChatService(
          firestore: firestore,
          authService: _authService(_authFor(uid)),
        ),
        gameService = OnlineGameService(
          firestore: firestore,
          authService: _authService(_authFor(uid)),
          roomService: RoomService(
            firestore: firestore,
            authService: _authService(_authFor(uid)),
          ),
          chatService: ChatService(
            firestore: firestore,
            authService: _authService(_authFor(uid)),
          ),
          wordSourceProvider: (_) => _StubWordSource(),
        );

  final String uid;
  final RoomService roomService;
  final OnlineGameService gameService;
  final ChatService chatService;
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

/// Pumps frames in small steps (without settling the phase countdown) until
/// [finder] matches, so a fresh countdown does not run to completion while we
/// are still observing the current phase.
Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 40,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 20));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Finder $finder did not match within $maxPumps pumps');
}

void main() {
  late SettlingFirestore firestore;
  late _PlayerContext alice;
  late _PlayerContext bob;
  late _PlayerContext cara;
  late _PlayerContext dave;
  late ({Room room, RoomPlayer hostPlayer}) created;
  late String roundId;

  setUp(() async {
    firestore = SettlingFirestore();
    alice = _PlayerContext('alice', firestore);
    bob = _PlayerContext('bob', firestore);
    cara = _PlayerContext('cara', firestore);
    dave = _PlayerContext('dave', firestore);

    created = await alice.roomService.createRoom(playerName: 'Alice');
    await bob.roomService.joinRoom(roomCode: created.room.code, playerName: 'Bob');
    await cara.roomService.joinRoom(roomCode: created.room.code, playerName: 'Cara');
    await dave.roomService.joinRoom(roomCode: created.room.code, playerName: 'Dave');
  });

  Future<void> startRoundInRoleReveal() async {
    await alice.roomService.updateGameSettings(
      roomId: created.room.id,
      settings: const GameSettings(
        playerCount: 4,
        discussionTime: Duration(seconds: 3),
        votingTime: Duration(seconds: 3),
      ),
    );
    final room = await alice.gameService.getRoomById(created.room.id);
    await alice.gameService.startRoundFromCategory(
      room: room,
      categoryId: 'animals',
      languageCode: 'en',
    );
    final fresh = await alice.gameService.getRoomById(created.room.id);
    roundId = fresh.activeRoundId!;
  }

  Future<void> startRoundInDiscussion() async {
    await startRoundInRoleReveal();
    for (final player in [alice, bob, cara, dave]) {
      await player.gameService.setRevealReady(
        roomId: created.room.id,
        roundId: roundId,
        ready: true,
      );
    }
    await alice.gameService.hostTryAdvanceReveal(created.room.id, roundId);
  }

  Future<void> startRoundInVoting() async {
    await startRoundInDiscussion();
    for (final player in [alice, bob, cara, dave]) {
      await player.gameService.setDiscussionReady(
        roomId: created.room.id,
        roundId: roundId,
        ready: true,
      );
    }
    await alice.gameService.hostAdvanceDiscussion(
      created.room.id,
      roundId,
      requireAllReady: true,
    );
  }

  Future<void> pumpScreenAs(WidgetTester tester, _PlayerContext client) async {
    final players = await client.roomService.getPlayersInRoom(created.room.id);
    final currentPlayer = players.firstWhere((p) => p.playerId == client.uid);
    RoomService.instance = client.roomService;
    OnlineGameService.instance = client.gameService;
    ChatService.instance = client.chatService;
    VoiceChatService.instance = buildFakeVoiceService(
      authService: _authService(_authFor(client.uid)),
    );
    await tester.pumpWidget(
      _localizedApp(OnlineGameScreen(
        roomId: created.room.id,
        currentPlayer: currentPlayer,
      )),
    );
  }

  testWidgets(
      'host discussion timer ends the phase and opens voting', (tester) async {
    await tester.runAsync(startRoundInDiscussion);

    await pumpScreenAs(tester, alice);
    await _pumpUntilFound(tester, find.byKey(const ValueKey('discussion-timer')));

    expect(find.text('DISCUSS!'), findsOneWidget);
    expect(find.byType(GameCountdown), findsOneWidget);

    // The host's countdown expires and pushes the voting phase to everyone.
    await tester.pump(const Duration(seconds: 3));
    await _pumpUntilFound(tester, find.byKey(const ValueKey('voting-timer')));

    expect(find.byKey(const ValueKey('discussion-timer')), findsNothing);
    expect(find.text('Who is the imposter?'), findsOneWidget);
    expect(find.byType(PlayerCard), findsNWidgets(3));

    final room = await alice.gameService.getRoomById(created.room.id);
    expect(OnlineGamePhase.fromDb(room.gamePhase), OnlineGamePhase.voting);

    // Tear the screen down so its active countdown timer is cancelled.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets(
      'non-host discussion timer does not advance the room, and the '
      'client follows the host to voting', (tester) async {
    await tester.runAsync(startRoundInDiscussion);

    await pumpScreenAs(tester, bob);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('discussion-timer')), findsOneWidget);

    // Bob's own timer already ran to zero during settle; as a non-host that is
    // a no-op, so the room must remain in the discussion phase.
    final roomAfterOwnTimer =
        await alice.gameService.getRoomById(created.room.id);
    expect(
      OnlineGamePhase.fromDb(roomAfterOwnTimer.gamePhase),
      OnlineGamePhase.discussion,
    );

    // The host ends the discussion -> Bob's screen syncs to voting.
    await tester.runAsync(() async {
      await alice.gameService.hostEndDiscussion(created.room.id, roundId);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _pumpUntilFound(tester, find.byKey(const ValueKey('voting-timer')));

    expect(find.byKey(const ValueKey('discussion-timer')), findsNothing);
    expect(find.text('Who is the imposter?'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets(
      'non-host voting screen follows the host to results', (tester) async {
    await tester.runAsync(startRoundInVoting);

    await pumpScreenAs(tester, bob);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('voting-timer')), findsOneWidget);
    expect(find.text('Who is the imposter?'), findsOneWidget);
    expect(find.byType(PlayerCard), findsNWidgets(3));

    // Host casts a vote and ends voting (batch write) -> sync to results.
    await tester.runAsync(() async {
      await alice.gameService.castVote(
        roomId: created.room.id,
        roundId: roundId,
        targetPlayerId: 'bob',
      );
      await alice.gameService.hostEndVoting(created.room.id, roundId);
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await tester.pumpAndSettle();

    expect(find.byType(GameCountdown), findsNothing);
    expect(find.text('Most suspected'), findsOneWidget);
    expect(find.text('Bob'), findsWidgets);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('non-host screen reflects its own ready state', (tester) async {
    await tester.runAsync(() async {
      await alice.roomService.updateGameSettings(
        roomId: created.room.id,
        settings: const GameSettings(playerCount: 4),
      );
      final room = await alice.gameService.getRoomById(created.room.id);
      await alice.gameService.startRoundFromCategory(
        room: room,
        categoryId: 'animals',
        languageCode: 'en',
      );
      final fresh = await alice.gameService.getRoomById(created.room.id);
      roundId = fresh.activeRoundId!;
    });

    await pumpScreenAs(tester, bob);
    await _pumpUntilFound(tester, find.text("I'M READY"));

    // Bob marks himself ready; his own-state subscription updates the button.
    await tester.runAsync(() async {
      await bob.gameService.setRevealReady(
        roomId: created.room.id,
        roundId: roundId,
        ready: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await _pumpUntilFound(tester, find.text('READY'));

    // As a non-host, the room must not advance to the discussion phase.
    final room = await alice.gameService.getRoomById(created.room.id);
    expect(
      OnlineGamePhase.fromDb(room.gamePhase),
      OnlineGamePhase.roleReveal,
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets(
      'non-host client takes over host duties after the host leaves',
      (tester) async {
    await tester.runAsync(startRoundInRoleReveal);

    await pumpScreenAs(tester, bob);
    await _pumpUntilFound(tester, find.text("I'M READY"));

    // The original host leaves mid-game; bob becomes host.
    await tester.runAsync(() async {
      await alice.roomService.leaveRoom(
        roomId: created.room.id,
        isHost: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await tester.pumpAndSettle();

    final roomAfterLeave = await bob.gameService.getRoomById(created.room.id);
    expect(roomAfterLeave.hostPlayerId, 'bob');

    // The new host presses ready, then the other players do too. Bob's
    // subscription re-scopes to the whole round, so their ready events reach
    // him and he advances the game to the discussion phase.
    await tester.tap(find.text("I'M READY"));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await cara.gameService.setRevealReady(
        roomId: created.room.id,
        roundId: roundId,
        ready: true,
      );
      await dave.gameService.setRevealReady(
        roomId: created.room.id,
        roundId: roundId,
        ready: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await _pumpUntilFound(tester, find.byKey(const ValueKey('discussion-timer')));

    final roomAdvanced = await bob.gameService.getRoomById(created.room.id);
    expect(
      OnlineGamePhase.fromDb(roomAdvanced.gamePhase),
      OnlineGamePhase.discussion,
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('discussion phase shows the chat panel with an empty state',
      (tester) async {
    await tester.runAsync(startRoundInDiscussion);

    await pumpScreenAs(tester, bob);
    await _pumpUntilFound(tester, find.byType(ChatPanel));

    expect(find.byType(ChatPanel), findsOneWidget);
    expect(
      find.byKey(const ValueKey('discussion-players')),
      findsOneWidget,
    );
    expect(find.text(AppLocalizationsEn().discussionPlayers(4)), findsOneWidget);
    expect(find.text(AppLocalizationsEn().chatEmpty), findsOneWidget);

    // The send button is disabled while the input is empty.
    final send = tester.widget<GestureDetector>(
      find.byKey(const ValueKey('chat-send')),
    );
    expect(send.onTap, isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('players can send chat messages that appear in real time',
      (tester) async {
    await tester.runAsync(startRoundInDiscussion);

    await pumpScreenAs(tester, bob);
    await _pumpUntilFound(tester, find.byType(ChatPanel));

    // The chat sits below the fold of the 600px test viewport.
    await tester.ensureVisible(find.byKey(const ValueKey('chat-input')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('chat-input')),
      'I think Cara is sus',
    );
    await tester.pump();

    final send = tester.widget<GestureDetector>(
      find.byKey(const ValueKey('chat-send')),
    );
    expect(send.onTap, isNotNull);

    await tester.tap(find.byKey(const ValueKey('chat-send')));
    await tester.pump();

    // The message lands in Firestore and the subscription delivers it back.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await _pumpUntilFound(tester, find.text('I think Cara is sus'));

    // The input clears after a successful send.
    final input = tester.widget<TextField>(
      find.byKey(const ValueKey('chat-input')),
    );
    expect(input.controller!.text, isEmpty);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('chat is not shown outside the discussion phase',
      (tester) async {
    await tester.runAsync(startRoundInVoting);

    await pumpScreenAs(tester, bob);
    await tester.pumpAndSettle();

    expect(find.byType(ChatPanel), findsNothing);
    expect(find.byKey(const ValueKey('chat-input')), findsNothing);
    expect(find.byKey(const ValueKey('chat-send')), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
