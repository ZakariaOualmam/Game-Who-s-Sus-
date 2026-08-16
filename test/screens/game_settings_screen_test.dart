import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/core/router.dart';
import 'package:who_sus/core/theme/app_theme.dart';
import 'package:who_sus/l10n/app_localizations.dart';
import 'package:who_sus/models/game_settings.dart';
import 'package:who_sus/models/room.dart';
import 'package:who_sus/screens/settings/game_settings_screen.dart';
import 'package:who_sus/services/firebase_auth_service.dart';
import 'package:who_sus/services/room_service.dart';

import '../helpers/settling_firestore.dart';

MockFirebaseAuth _authFor(String uid) {
  return MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(uid: uid, isAnonymous: true),
  );
}

FirebaseAuthService _authService(MockFirebaseAuth auth) =>
    FirebaseAuthService.forTesting(auth);

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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  testWidgets('offline mode renders sections and returns edits on close',
      (tester) async {
    GameSettings? returned;
    await tester.pumpWidget(_localizedApp(Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              returned = await Navigator.of(context).push<GameSettings>(
                appRoute(const GameSettingsScreen.offline(
                  initialSettings: GameSettings(),
                  playerCount: 5,
                )),
              );
            },
            child: const Text('OPEN'),
          ),
        ),
      ),
    )));
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    expect(find.text('GAME SETTINGS'), findsOneWidget);
    expect(find.text('Players'), findsOneWidget);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(GameSettingsScreen)),
    );

    // Settings without a gameplay effect are hidden for V1.
    expect(find.text(l10n.settingsAnonymousVoting), findsNothing);
    expect(find.text(l10n.settingsImposterClue), findsNothing);
    expect(find.byType(Switch), findsNothing);

    // Pick a 2-minute discussion.
    final twoMinutes = find.text('2m');
    await tester.ensureVisible(twoMinutes);
    await tester.pumpAndSettle();
    await tester.tap(twoMinutes);
    await tester.pumpAndSettle();

    final close = find.text('CLOSE');
    await tester.ensureVisible(close);
    await tester.pumpAndSettle();
    await tester.tap(close);
    await tester.pumpAndSettle();

    expect(returned, isNotNull);
    expect(returned!.anonymousVoting, isFalse);
    expect(returned!.imposterCount, 1);
    expect(returned!.discussionTime, const Duration(minutes: 2));
  });

  testWidgets('two-imposter option is locked for V1', (tester) async {
    GameSettings? returned;
    await tester.pumpWidget(_localizedApp(Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              returned = await Navigator.of(context).push<GameSettings>(
                appRoute(const GameSettingsScreen.offline(
                  initialSettings: GameSettings(),
                  playerCount: 5,
                )),
              );
            },
            child: const Text('OPEN'),
          ),
        ),
      ),
    )));
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(GameSettingsScreen)),
    );

    // 5 players would allow 2 imposters, but gameplay does not support it,
    // so the "2" option is disabled and cannot be selected.
    final twoImposters = find.text('2');
    await tester.ensureVisible(twoImposters);
    await tester.pumpAndSettle();
    await tester.tap(twoImposters, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text(l10n.settingsImpostersUnsupported), findsNothing);

    final close = find.text('CLOSE');
    await tester.ensureVisible(close);
    await tester.pumpAndSettle();
    await tester.tap(close);
    await tester.pumpAndSettle();

    expect(returned, isNotNull);
    expect(returned!.imposterCount, 1);
  });

  testWidgets('legacy online room with 2 imposters warns the host', (tester) async {
    final firestore = SettlingFirestore();
    final host = RoomService(
      firestore: firestore,
      authService: _authService(_authFor('alice')),
    );
    RoomService.instance = host;

    late Room createdRoom;
    await tester.runAsync(() async {
      final created = await host.createRoom(playerName: 'Alice');
      createdRoom = created.room;

      // Simulate a room saved before V1 locked imposter count to 1.
      await firestore.collection('rooms').doc(createdRoom.id).update({
        'settings': GameSettings(
          playerCount: createdRoom.settings.playerCount,
          imposterCount: 2,
        ).toMap(),
      });
      final legacyDoc = await firestore
          .collection('rooms')
          .doc(createdRoom.id)
          .get();
      createdRoom = Room.fromMap(legacyDoc.data()!, id: legacyDoc.id);
    });
    expect(createdRoom.settings.imposterCount, 2);

    await tester.pumpWidget(_localizedApp(
      GameSettingsScreen.online(room: createdRoom, isHost: true),
    ));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(GameSettingsScreen)),
    );
    expect(find.text(l10n.settingsImpostersUnsupported), findsOneWidget);

    // The host can switch back to 1 imposter and save.
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.settingsSave));
    await tester.pumpAndSettle();

    final savedDoc = await tester.runAsync(
      () => firestore.collection('rooms').doc(createdRoom.id).get(),
    );
    final savedSettings = savedDoc!.data()!['settings'] as Map<String, dynamic>;
    expect(savedSettings['imposter_count'], 1);
  });

  testWidgets('online host saves settings to the room', (tester) async {
    final firestore = SettlingFirestore();
    final host = RoomService(
      firestore: firestore,
      authService: _authService(_authFor('alice')),
    );
    RoomService.instance = host;

    late Room createdRoom;
    await tester.runAsync(() async {
      final created = await host.createRoom(playerName: 'Alice');
      createdRoom = created.room;
    });

    bool popped = false;
    await tester.pumpWidget(_localizedApp(Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.of(context).push(
                appRoute(GameSettingsScreen.online(
                  room: createdRoom,
                  isHost: true,
                )),
              );
              popped = true;
            },
            child: const Text('OPEN'),
          ),
        ),
      ),
    )));
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    // Pick 6 players.
    await tester.tap(find.text('6'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SAVE SETTINGS'));
    await tester.pumpAndSettle();

    expect(popped, isTrue);

    final roomDoc = await firestore
        .collection('rooms')
        .doc(createdRoom.id)
        .get();
    final settings = roomDoc.data()!['settings'] as Map<String, dynamic>;
    expect(settings['player_count'], 6);
  });

  testWidgets('online non-host sees read-only settings', (tester) async {
    final firestore = SettlingFirestore();
    final host = RoomService(
      firestore: firestore,
      authService: _authService(_authFor('alice')),
    );

    late Room createdRoom;
    await tester.runAsync(() async {
      final created = await host.createRoom(playerName: 'Alice');
      createdRoom = created.room;
    });

    await tester.pumpWidget(_localizedApp(
      GameSettingsScreen.online(room: createdRoom, isHost: false),
    ));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(GameSettingsScreen)),
    );
    expect(find.text(l10n.settingsHostControls), findsOneWidget);
    expect(find.text(l10n.settingsSave), findsNothing);
    expect(find.text(l10n.settingsClose), findsOneWidget);
  });
}
