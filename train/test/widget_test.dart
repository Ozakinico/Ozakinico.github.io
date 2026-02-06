import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:train/main.dart';

void main() {
  testWidgets('App builds and can be tapped', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DotCountingTrainingApp()));
    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text(appTitle), findsOneWidget);

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
  });
}
