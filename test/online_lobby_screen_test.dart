import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/core/theme/app_theme.dart';
import 'package:who_sus/data/categories.dart';
import 'package:who_sus/l10n/app_localizations.dart';
import 'package:who_sus/models/room.dart';
import 'package:who_sus/models/room_player.dart';
import 'package:who_sus/screens/online/online_lobby_screen.dart';
import 'package:who_sus/services/firebase_auth_service.dart';
import 'package:who_sus/services/online_game_service.dart';
import 'package:who_sus/services/room_service.dart';
import 'package:who_sus/services/word_repository.dart';
import 'package:who_sus/widgets/brand_logo.dart';
import 'package:who_sus/widgets/game_scaffold.dart';
import 'package:who_sus/widgets/player_card.dart';

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
        gameService = OnlineGameService(
          firestore: firestore,
          authService: _authService(_authFor(uid)),
          roomService: RoomService(
            firestore: firestore,
            authService: _authService(_authFor(uid)),
          ),
          wordSourceProvider: (_) => _StubWordSource(),
        );

  final String uid;
  final RoomService roomService;
  final OnlineGameService gameService;
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
  late SettlingFirestore firestore;
  late _PlayerContext alice;
  late _PlayerContext bob;
  late _PlayerContext cara;
  late _PlayerContext dave;
  late ({Room room, RoomPlayer hostPlayer}) created;

  setUp(() async {
    firestore = SettlingFirestore();
    alice = _PlayerContext('alice', firestore);
    bob = _PlayerContext('bob', firestore);
    cara = _PlayerContext('cara', firestore);
    dave = _PlayerContext('dave', firestore);

    // The lobby screens read the swappable singletons.
    RoomService.instance = alice.roomService;
    OnlineGameService.instance = alice.gameService;

    created = await alice.roomService.createRoom(playerName: 'Alice');
    await bob.roomService.joinRoom(roomCode: created.room.code, playerName: 'Bob');
    await cara.roomService.joinRoom(roomCode: created.room.code, playerName: 'Cara');
  });

  testWidgets(
      'online lobby builds and renders without an initState '
      'localization crash', (tester) async {
    await tester.pumpWidget(
      _localizedApp(OnlineLobbyScreen(
        room: created.room,
        currentPlayer: created.hostPlayer,
      )),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(OnlineLobbyScreen), findsOneWidget);
    expect(find.byType(GameScaffold), findsOneWidget);
    expect(find.text(created.room.code), findsOneWidget);
    expect(find.text('LOBBY'), findsOneWidget);
    expect(find.byType(PlayerCard), findsNWidgets(3));
    expect(find.byType(BrandLogo), findsWidgets);
  });

  testWidgets(
      'online lobby streams player joins in realtime and disposes '
      'subscriptions cleanly', (tester) async {
    await tester.pumpWidget(
      _localizedApp(OnlineLobbyScreen(
        room: created.room,
        currentPlayer: created.hostPlayer,
      )),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PlayerCard), findsNWidgets(3));

    // A player joining after the screen is live must appear via the
    // subscription callback (mounted-guarded setState).
    await tester.runAsync(
      () => dave.roomService.joinRoom(roomCode: created.room.code, playerName: 'Dave'),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(PlayerCard), findsNWidgets(4));

    // Unmounting must cancel the Firestore subscriptions without any
    // setState-after-dispose errors.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
