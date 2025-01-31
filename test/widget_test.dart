import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_text_reader_prototype/main.dart';

void main() {
  testWidgets(
    'TextReaderPrototype builds and responds to taps',
    (WidgetTester tester) async {
      const testText = 'Hello world this is a test of the text reader';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TextReaderPrototype(text: testText)),
        ),
      );

      expect(find.textContaining('Hello'), findsOneWidget);
      expect(find.textContaining('world'), findsOneWidget);

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow), findsNothing);
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // TODO: figure out how to tap on the TextSpan

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();

      // reason: we expect the play button to be visible again
      // ignore: avoid-duplicate-test-assertions
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      // reason: we expect the pause button to be hidden
      // ignore: avoid-duplicate-test-assertions
      expect(find.byIcon(Icons.pause), findsNothing);
    },
  );
}
