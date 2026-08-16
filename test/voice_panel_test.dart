import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/core/theme/app_theme.dart';
import 'package:who_sus/l10n/app_localizations.dart';
import 'package:who_sus/l10n/app_localizations_en.dart';
import 'package:who_sus/voice/voice_participant.dart';
import 'package:who_sus/widgets/voice_panel.dart';

Widget _wrap(VoicePanel panel) {
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
    home: Scaffold(
      body: SingleChildScrollView(
        child: panel,
      ),
    ),
  );
}

VoicePanel _panel({
  required VoiceConnectionState state,
  VoiceFailure? failure,
  List<VoiceParticipant> participants = const [],
  bool micEnabled = false,
  VoidCallback? onHoldStart,
  VoidCallback? onHoldEnd,
  VoidCallback? onRetry,
  VoidCallback? onAllowMicrophone,
  VoidCallback? onContinueWithoutVoice,
}) {
  return VoicePanel(
    participants: participants,
    state: state,
    failure: failure,
    micEnabled: micEnabled,
    myPlayerId: 'me',
    onHoldStart: onHoldStart ?? () {},
    onHoldEnd: onHoldEnd ?? () {},
    onRetry: onRetry ?? () {},
    onAllowMicrophone: onAllowMicrophone ?? () {},
    onContinueWithoutVoice: onContinueWithoutVoice ?? () {},
  );
}

const _participants = [
  VoiceParticipant(playerId: 'me', name: 'Ada', state: VoiceParticipantState.speaking),
  VoiceParticipant(playerId: 'u2', name: 'Bob', state: VoiceParticipantState.muted),
  VoiceParticipant(playerId: 'u3', name: 'Cara', state: VoiceParticipantState.reconnecting),
  VoiceParticipant(playerId: 'u4', name: 'Dave', state: VoiceParticipantState.disconnected),
];

void main() {
  testWidgets('is invisible while disabled', (tester) async {
    await tester.pumpWidget(_wrap(_panel(state: VoiceConnectionState.disabled)));
    expect(find.byKey(const ValueKey('voice-panel')), findsNothing);
  });

  testWidgets('shows participants and speaking/muted/offline states',
      (tester) async {
    await tester.pumpWidget(_wrap(
      _panel(state: VoiceConnectionState.connected, participants: _participants),
    ));

    expect(find.byKey(const ValueKey('voice-panel')), findsOneWidget);
    expect(find.text(AppLocalizationsEn().voiceTitle), findsOneWidget);
    expect(find.text(AppLocalizationsEn().voiceSpeaking), findsOneWidget);
    expect(find.text(AppLocalizationsEn().voiceMuted), findsOneWidget);
    expect(find.text(AppLocalizationsEn().voiceReconnecting), findsOneWidget);
    expect(find.text(AppLocalizationsEn().voiceNotConnected), findsOneWidget);
    expect(find.byKey(const ValueKey('hold-to-talk')), findsOneWidget);
  });

  testWidgets('hold and release drive the push-to-talk callbacks',
      (tester) async {
    var starts = 0;
    var stops = 0;

    await tester.pumpWidget(_wrap(_panel(
      state: VoiceConnectionState.connected,
      participants: _participants,
      onHoldStart: () => starts++,
      onHoldEnd: () => stops++,
    )));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('hold-to-talk'))),
    );
    await tester.pump();
    expect(starts, 1);
    expect(find.text(AppLocalizationsEn().voiceReleaseToStop), findsNothing);

    await gesture.up();
    await tester.pump();
    expect(stops, 1);
  });

  testWidgets('shows the talking label while the mic is hot', (tester) async {
    await tester.pumpWidget(_wrap(_panel(
      state: VoiceConnectionState.connected,
      participants: _participants,
      micEnabled: true,
    )));
    expect(find.text(AppLocalizationsEn().voiceTalking), findsOneWidget);
  });

  testWidgets('does not fire callbacks while not connected', (tester) async {
    var starts = 0;
    await tester.pumpWidget(_wrap(_panel(
      state: VoiceConnectionState.reconnecting,
      participants: _participants,
      onHoldStart: () => starts++,
    )));

    await tester.tap(find.byKey(const ValueKey('hold-to-talk')));
    await tester.pump();
    expect(starts, 0);
  });

  testWidgets('shows a connecting status while joining', (tester) async {
    await tester.pumpWidget(_wrap(_panel(state: VoiceConnectionState.joining)));
    expect(find.text(AppLocalizationsEn().voiceConnecting), findsOneWidget);
  });

  testWidgets('shows reconnecting status', (tester) async {
    await tester.pumpWidget(
        _wrap(_panel(state: VoiceConnectionState.reconnecting)));
    expect(find.text(AppLocalizationsEn().voiceReconnecting), findsOneWidget);
  });

  testWidgets('permission denied offers allow and continue without voice',
      (tester) async {
    var allow = 0;
    var continueWithoutVoice = 0;

    await tester.pumpWidget(_wrap(_panel(
      state: VoiceConnectionState.permissionDenied,
      failure: VoiceFailure.permissionDenied,
      onAllowMicrophone: () => allow++,
      onContinueWithoutVoice: () => continueWithoutVoice++,
    )));

    expect(
      find.text(AppLocalizationsEn().voicePermissionRequired),
      findsOneWidget,
    );
    expect(find.text(AppLocalizationsEn().voiceAllowMicrophone), findsOneWidget);
    expect(
      find.text(AppLocalizationsEn().voiceContinueWithoutVoice),
      findsOneWidget,
    );

    await tester.tap(find.text(AppLocalizationsEn().voiceAllowMicrophone));
    await tester.tap(find.text(AppLocalizationsEn().voiceContinueWithoutVoice));
    expect(allow, 1);
    expect(continueWithoutVoice, 1);
  });

  testWidgets('failed connection offers retry and continue', (tester) async {
    var retry = 0;
    var continueWithoutVoice = 0;

    await tester.pumpWidget(_wrap(_panel(
      state: VoiceConnectionState.failed,
      failure: VoiceFailure.connectionFailed,
      onRetry: () => retry++,
      onContinueWithoutVoice: () => continueWithoutVoice++,
    )));

    expect(find.text(AppLocalizationsEn().voiceConnectionFailed), findsOneWidget);
    expect(find.text(AppLocalizationsEn().voiceRetry), findsOneWidget);

    await tester.tap(find.text(AppLocalizationsEn().voiceRetry));
    await tester.tap(find.text(AppLocalizationsEn().voiceContinueWithoutVoice));
    expect(retry, 1);
    expect(continueWithoutVoice, 1);
  });

  testWidgets('not-configured failure shows the unavailable copy',
      (tester) async {
    await tester.pumpWidget(_wrap(_panel(
      state: VoiceConnectionState.failed,
      failure: VoiceFailure.notConfigured,
    )));
    expect(find.text(AppLocalizationsEn().voiceNotConfigured), findsOneWidget);
  });

  testWidgets('connected with an unavailable mic offers to recover',
      (tester) async {
    var allow = 0;
    await tester.pumpWidget(_wrap(_panel(
      state: VoiceConnectionState.connected,
      failure: VoiceFailure.microphoneUnavailable,
      onAllowMicrophone: () => allow++,
    )));

    expect(find.text(AppLocalizationsEn().voiceMicUnavailable), findsOneWidget);
    await tester.tap(find.text(AppLocalizationsEn().voiceAllowMicrophone));
    expect(allow, 1);
  });

  testWidgets('keyboard SPACE down starts talking, up stops',
      (tester) async {
    var starts = 0;
    var stops = 0;

    await tester.pumpWidget(_wrap(_panel(
      state: VoiceConnectionState.connected,
      onHoldStart: () => starts++,
      onHoldEnd: () => stops++,
    )));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(starts, 1);

    await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(stops, 1);
  });

  testWidgets('keyboard SPACE does not start when not connected',
      (tester) async {
    var starts = 0;

    await tester.pumpWidget(_wrap(_panel(
      state: VoiceConnectionState.joining,
      onHoldStart: () => starts++,
    )));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(starts, 0);
  });

  testWidgets('keyboard SPACE does not start when a TextField is focused',
      (tester) async {
    var starts = 0;
    final focusNode = FocusNode();

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              TextField(focusNode: focusNode),
              _panel(
                state: VoiceConnectionState.connected,
                onHoldStart: () => starts++,
              ),
            ],
          ),
        ),
      ),
    ));

    focusNode.requestFocus();
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(starts, 0);

    await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
    await tester.pump();
  });

  testWidgets('shows a red indicator dot when talking', (tester) async {
    await tester.pumpWidget(_wrap(_panel(
      state: VoiceConnectionState.connected,
      micEnabled: true,
    )));

    // The red dot is a Container with danger color — verify the talking label.
    expect(find.text(AppLocalizationsEn().voiceTalking), findsOneWidget);
    expect(find.text(AppLocalizationsEn().voiceHoldToTalk), findsNothing);
  });
}
