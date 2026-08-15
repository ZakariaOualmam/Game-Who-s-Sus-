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

Future<void> _pushOffline(WidgetTester tester) async {
  await tester.pumpWidget(_localizedApp(Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push<GameSettings>(
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

    // Toggle anonymous voting and pick a 2-minute discussion.
    final firstSwitch = find.byType(Switch).first;
    await tester.ensureVisible(firstSwitch);
    await tester.pumpAndSettle();
    await tester.tap(firstSwitch);
    await tester.pumpAndSettle();

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
    expect(returned!.anonymousVoting, isTrue);
    expect(returned!.discussionTime, const Duration(minutes: 2));
  });

  testWidgets('offline mode flags unsupported imposter counts', (tester) async {
    await _pushOffline(tester);

    // 5 players allow 2 imposters, but gameplay does not support it yet.
    final twoImposters = find.text('2');
    await tester.ensureVisible(twoImposters);
    await tester.pumpAndSettle();
    await tester.tap(twoImposters);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(GameSettingsScreen)),
    );
    expect(find.text(l10n.settingsImpostersUnsupported), findsOneWidget);
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
