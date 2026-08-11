import 'package:flutter_test/flutter_test.dart';

import 'package:wordimposter/main.dart';

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
}
