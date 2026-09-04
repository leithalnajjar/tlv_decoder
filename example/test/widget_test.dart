import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('shows encode and decode buttons', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Encode'), findsOneWidget);
    expect(find.text('Decode'), findsOneWidget);
  });

  testWidgets('tapping Encode shows encoded output', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Encode'));
    await tester.pump();

    expect(find.textContaining('Encoded:'), findsOneWidget);
  });
}
