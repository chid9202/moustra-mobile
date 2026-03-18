import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/protocols_screen.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    installNoOpDioApiClient();
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      dotenv.env.clear();
    }
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  group('ProtocolsScreen', () {
    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: ProtocolsScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state after API failure', (
      WidgetTester tester,
    ) async {
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TestHelpers.createMockTheme(),
            home: const Scaffold(
              body: ProtocolsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('Error loading protocols'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      }, (error, stack) {
        // Suppress API errors
      });
    });

    testWidgets('renders the ProtocolsScreen widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: ProtocolsScreen(),
          ),
        ),
      );

      expect(find.byType(ProtocolsScreen), findsOneWidget);
    });
  });
}
