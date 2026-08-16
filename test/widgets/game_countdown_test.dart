import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:who_sus/core/theme/app_colors.dart';
import 'package:who_sus/core/theme/app_theme.dart';
import 'package:who_sus/l10n/app_localizations.dart';
import 'package:who_sus/widgets/game_countdown.dart';

Widget _wrap({
  required Duration duration,
  required VoidCallback onFinished,
  String? label,
  Duration warningAt = const Duration(seconds: 10),
  Duration dangerAt = const Duration(seconds: 5),
}) {
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
      body: Center(
        child: GameCountdown(
          duration: duration,
          onFinished: onFinished,
          label: label,
          warningAt: warningAt,
          dangerAt: dangerAt,
        ),
      ),
    ),
  );
}

Color? _iconColor(WidgetTester tester, IconData icon) {
  final finder = find.byIcon(icon);
  if (finder.evaluate().isEmpty) return null;
  return tester.widget<Icon>(finder).color;
}

void main() {
  testWidgets('displays the configured duration initially', (tester) async {
    await tester.pumpWidget(_wrap(
      duration: const Duration(seconds: 90),
      onFinished: () {},
    ));

    expect(find.text('1m 30s'), findsOneWidget);
    expect(_iconColor(tester, Icons.timer_outlined), AppColors.secondary);
  });

  testWidgets('ticks down every second', (tester) async {
    await tester.pumpWidget(_wrap(
      duration: const Duration(minutes: 1),
      onFinished: () {},
    ));

    expect(find.text('1m'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('59s'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('58s'), findsOneWidget);
  });

  testWidgets('shows warning then danger states close to zero',
      (tester) async {
    await tester.pumpWidget(_wrap(
      duration: const Duration(seconds: 15),
      onFinished: () {},
    ));

    // Normal state: cyan icon.
    expect(_iconColor(tester, Icons.timer_outlined), AppColors.secondary);

    // At or below the warning threshold the pill turns amber.
    await tester.pump(const Duration(seconds: 5));
    expect(_iconColor(tester, Icons.timer_outlined), AppColors.warning);

    // At or below the danger threshold the pill turns red and the icon swaps.
    await tester.pump(const Duration(seconds: 5));
    expect(_iconColor(tester, Icons.timer_outlined), isNull);
    expect(_iconColor(tester, Icons.timer_off_outlined), AppColors.danger);
  });

  testWidgets('fires onFinished exactly once at zero', (tester) async {
    var calls = 0;
    await tester.pumpWidget(_wrap(
      duration: const Duration(seconds: 3),
      onFinished: () => calls++,
    ));

    await tester.pump(const Duration(seconds: 3));
    expect(calls, 1);

    // Extra time after zero must not fire the callback again.
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets('cancels the timer on dispose', (tester) async {
    var calls = 0;
    await tester.pumpWidget(_wrap(
      duration: const Duration(minutes: 1),
      onFinished: () => calls++,
    ));

    await tester.pump(const Duration(seconds: 2));
    // Unmount before the countdown ends.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(seconds: 10));

    expect(calls, 0);
    // No pending-timer leak: flutter_test fails the test otherwise.
  });
}
