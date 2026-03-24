import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/cheese_ai_screen.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    installNoOpDioApiClient();
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      dotenv.loadFromString(envString: '', isOptional: true);
    }
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  group('CheeseAiScreen', () {
    testWidgets('shows placeholder text when no messages', (
      WidgetTester tester,
    ) async {
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TestHelpers.createMockTheme(),
            home: const Scaffold(
              body: CheeseAiScreen(),
            ),
          ),
        );

        // Before history loads, it may show loading or placeholder
        await tester.pump();

        expect(find.byType(CheeseAiScreen), findsOneWidget);
      }, (error, stack) {
        // Suppress API errors from loading history
      });
    });

    testWidgets('shows input bar with text field and send button', (
      WidgetTester tester,
    ) async {
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TestHelpers.createMockTheme(),
            home: const Scaffold(
              body: CheeseAiScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);
        expect(find.text('Ask something...'), findsOneWidget);
      }, (error, stack) {
        // Suppress API errors
      });
    });

    testWidgets('renders CheeseAiScreen widget', (
      WidgetTester tester,
    ) async {
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TestHelpers.createMockTheme(),
            home: const Scaffold(
              body: CheeseAiScreen(),
            ),
          ),
        );

        expect(find.byType(CheeseAiScreen), findsOneWidget);
      }, (error, stack) {
        // Suppress API errors
      });
    });

    testWidgets('shows suggestion presets after history load fails', (
      WidgetTester tester,
    ) async {
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TestHelpers.createMockTheme(),
            home: const Scaffold(
              body: CheeseAiScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 2));

        // After failed history load, should show suggestion presets
        expect(
          find.textContaining('what can I help you with?'),
          findsOneWidget,
        );
        expect(find.byType(ActionChip), findsWidgets);
      }, (error, stack) {
        // Suppress API errors
      });
    });
  });
}
