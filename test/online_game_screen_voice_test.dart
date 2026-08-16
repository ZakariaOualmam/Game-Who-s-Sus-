import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/core/theme/app_theme.dart';
import 'package:who_sus/data/categories.dart';
import 'package:who_sus/l10n/app_localizations.dart';
import 'package:who_sus/l10n/app_localizations_en.dart';
import 'package:who_sus/models/game_settings.dart';
import 'package:who_sus/models/room.dart';
import 'package:who_sus/models/room_player.dart';
import 'package:who_sus/screens/online/online_game_screen.dart';
import 'package:who_sus/services/chat_service.dart';
import 'package:who_sus/services/firebase_auth_service.dart';
import 'package:who_sus/services/online_game_service.dart';
import 'package:who_sus/services/room_service.dart';
import 'package:who_sus/services/voice_chat_service.dart';
import 'package:who_sus/services/word_repository.dart';
import 'package:who_sus/voice/voice_participant.dart';
import 'package:who_sus/voice/voice_transport.dart';
import 'package:who_sus/widgets/voice_panel.dart';

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
      : authService = _authService(_authFor(uid)),
        roomService = RoomService(
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
  final FirebaseAuthService authService;
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
  late FakeVoiceTransport voiceTransport;
  late FakeVoiceTokenProvider voiceTokenProvider;

  setUp(() async {
    firestore = SettlingFirestore();
    alice = _PlayerContext('alice', firestore);
    bob = _PlayerContext('bob', firestore);
    cara = _PlayerContext('cara', firestore);
    dave = _PlayerContext('dave', firestore);
    voiceTransport = FakeVoiceTransport();
    voiceTokenProvider = FakeVoiceTokenProvider();

    created = await alice.roomService.createRoom(playerName: 'Alice');
    await bob.roomService.joinRoom(roomCode: created.room.code, playerName: 'Bob');
    await cara.roomService.joinRoom(roomCode: created.room.code, playerName: 'Cara');
    await dave.roomService.joinRoom(roomCode: created.room.code, playerName: 'Dave');
  });

  Future<void> startRoundInDiscussion() async {
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

  void installVoiceService(_PlayerContext client) {
    // Uses the fakes from setUp, or whichever the test replaced beforehand
    // (e.g. permission/connect failure scenarios).
    VoiceChatService.instance = buildFakeVoiceService(
      authService: client.authService,
      transport: voiceTransport,
      tokenProvider: voiceTokenProvider,
    );
  }

  Future<void> pumpScreenAs(WidgetTester tester, _PlayerContext client) async {
    final players = await client.roomService.getPlayersInRoom(created.room.id);
    final currentPlayer = players.firstWhere((p) => p.playerId == client.uid);
    RoomService.instance = client.roomService;
    OnlineGameService.instance = client.gameService;
    ChatService.instance = client.chatService;
    installVoiceService(client);
    await tester.pumpWidget(
      _localizedApp(OnlineGameScreen(
        roomId: created.room.id,
        currentPlayer: currentPlayer,
      )),
    );
  }

  testWidgets('discussion phase joins the voice room and shows the panel',
      (tester) async {
    await tester.runAsync(startRoundInDiscussion);

    await pumpScreenAs(tester, bob);
    await _pumpUntilFound(tester, find.byKey(const ValueKey('voice-panel')));

    expect(VoiceChatService.instance.state, VoiceConnectionState.connected);
    expect(voiceTransport.connectedPlayerId, 'bob');
    expect(find.byType(VoicePanel), findsOneWidget);
    expect(find.byKey(const ValueKey('hold-to-talk')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('hold to talk publishes and releases the microphone',
      (tester) async {
    await tester.runAsync(startRoundInDiscussion);

    await pumpScreenAs(tester, bob);
    await _pumpUntilFound(tester, find.byKey(const ValueKey('hold-to-talk')));
    for (var i = 0;
        i < 40 && VoiceChatService.instance.state != VoiceConnectionState.connected;
        i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(VoiceChatService.instance.state, VoiceConnectionState.connected);

    await tester.ensureVisible(find.byKey(const ValueKey('hold-to-talk')));
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('hold-to-talk'))),
    );
    await tester.pumpAndSettle();
    expect(VoiceChatService.instance.micEnabled, isTrue);
    expect(voiceTransport.micEnabled, isTrue);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(VoiceChatService.instance.micEnabled, isFalse);
    expect(voiceTransport.micEnabled, isFalse);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('marks players as speaking from real audio activity',
      (tester) async {
    await tester.runAsync(startRoundInDiscussion);

    await pumpScreenAs(tester, bob);
    await _pumpUntilFound(tester, find.byKey(const ValueKey('voice-panel')));

    voiceTransport.emitParticipant(const VoiceTransportParticipant(
      playerId: 'cara',
      name: 'Cara',
      isSpeaking: true,
    ));
    await tester.pump();
    await _pumpUntilFound(tester, find.text(AppLocalizationsEn().voiceSpeaking));

    expect(find.text(AppLocalizationsEn().voiceSpeaking), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('voting phase hides voice and leaves the room', (tester) async {
    await tester.runAsync(startRoundInVoting);

    await pumpScreenAs(tester, bob);
    await tester.pumpAndSettle();

    expect(find.byType(VoicePanel), findsNothing);
    expect(find.byKey(const ValueKey('voice-panel')), findsNothing);
    expect(VoiceChatService.instance.state, VoiceConnectionState.disabled);
    expect(voiceTransport.connectedUrl, isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('permission denied offers continue without voice',
      (tester) async {
    await tester.runAsync(startRoundInDiscussion);

    voiceTransport = FakeVoiceTransport(permissionGranted: false);
    voiceTokenProvider = FakeVoiceTokenProvider();
    VoiceChatService.instance = buildFakeVoiceService(
      authService: bob.authService,
      transport: voiceTransport,
      tokenProvider: voiceTokenProvider,
    );
    await pumpScreenAs(tester, bob);
    await _pumpUntilFound(
      tester,
      find.text(AppLocalizationsEn().voicePermissionRequired),
    );

    expect(find.text(AppLocalizationsEn().voiceAllowMicrophone), findsOneWidget);

    await tester.tap(find.text(AppLocalizationsEn().voiceContinueWithoutVoice));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('voice-panel')), findsNothing);
    // Still in the discussion phase.
    expect(find.byKey(const ValueKey('discussion-players')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('failed connection can be retried', (tester) async {
    await tester.runAsync(startRoundInDiscussion);

    voiceTransport = FakeVoiceTransport()..connectShouldFail = true;
    voiceTokenProvider = FakeVoiceTokenProvider();
    VoiceChatService.instance = buildFakeVoiceService(
      authService: bob.authService,
      transport: voiceTransport,
      tokenProvider: voiceTokenProvider,
    );
    await pumpScreenAs(tester, bob);
    await _pumpUntilFound(
      tester,
      find.text(AppLocalizationsEn().voiceConnectionFailed),
    );

    voiceTransport.connectShouldFail = false;
    await tester.tap(find.text(AppLocalizationsEn().voiceRetry));
    await tester.pumpAndSettle();

    expect(VoiceChatService.instance.state, VoiceConnectionState.connected);
    expect(find.byKey(const ValueKey('hold-to-talk')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('leaves the voice room when the screen is disposed',
      (tester) async {
    await tester.runAsync(startRoundInDiscussion);

    await pumpScreenAs(tester, bob);
    await _pumpUntilFound(tester, find.byKey(const ValueKey('voice-panel')));
    expect(VoiceChatService.instance.state, VoiceConnectionState.connected);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(VoiceChatService.instance.state, VoiceConnectionState.disabled);
    expect(voiceTransport.connectedUrl, isNull);
  });

  testWidgets('players not in voice show as not connected', (tester) async {
    await tester.runAsync(startRoundInDiscussion);

    await pumpScreenAs(tester, bob);
    await _pumpUntilFound(tester, find.byKey(const ValueKey('voice-panel')));

    // Only Bob joined voice; the others should appear offline.
    expect(find.text(AppLocalizationsEn().voiceNotConnected), findsNWidgets(3));

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
