import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/widgets/safe_text.dart';

void main() {
  group('cellText', () {
    testWidgets('renders a SafeText with the given value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellText('Hello World'),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
      expect(find.byType(SafeText), findsOneWidget);
    });

    testWidgets('renders em dash when value is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellText(null),
          ),
        ),
      );

      expect(find.text(emptyCellPlaceholder), findsOneWidget);
    });

    testWidgets('renders em dash when value is empty string', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellText(''),
          ),
        ),
      );

      expect(find.text(emptyCellPlaceholder), findsOneWidget);
    });

    testWidgets('renders em dash when value is whitespace only', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellText('   '),
          ),
        ),
      );

      expect(find.text(emptyCellPlaceholder), findsOneWidget);
    });

    testWidgets('returns a Padding widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellText('test'),
          ),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('uses centerLeft alignment by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellText('test'),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('uses custom alignment when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellText('test', textAlign: Alignment.centerRight),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerRight);
    });
  });

  group('cellTextList', () {
    testWidgets('renders multiple SafeText widgets for each value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellTextList(['Alpha', 'Beta', 'Gamma']),
          ),
        ),
      );

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
      expect(find.byType(SafeText), findsNWidgets(3));
    });

    testWidgets('renders em dash for empty list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellTextList([]),
          ),
        ),
      );

      expect(find.byType(SafeText), findsNothing);
      expect(find.text(emptyCellPlaceholder), findsOneWidget);
    });

    testWidgets('renders em dash when list contains only empty strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellTextList(['', '  ']),
          ),
        ),
      );

      expect(find.byType(SafeText), findsNothing);
      expect(find.text(emptyCellPlaceholder), findsOneWidget);
    });

    testWidgets('returns a Padding widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellTextList(['one']),
          ),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('uses centerLeft alignment by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellTextList(['test']),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('uses custom alignment when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: cellTextList(['test'], textAlign: Alignment.center),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.center);
    });
  });
}
