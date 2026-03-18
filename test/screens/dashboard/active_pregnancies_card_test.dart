import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/dashboard/active_pregnancies_card.dart';
import '../../test_helpers/test_helpers.dart';

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

  group('ActivePregnanciesCard', () {
    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: ActivePregnanciesCard(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows no active pregnancies after API error', (
      WidgetTester tester,
    ) async {
      // Use runZonedGuarded to suppress API errors from NoOpDioApiClient
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TestHelpers.createMockTheme(),
            home: const Scaffold(
              body: ActivePregnanciesCard(),
            ),
          ),
        );

        // Wait for the async load to complete (it will fail with NoOpDioApiClient)
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // After error, loading should be false; should show empty state
        expect(find.text('Active Pregnancies'), findsOneWidget);
        expect(find.text('No active pregnancies'), findsOneWidget);
      }, (error, stack) {
        // Suppress API errors
      });
    });

    testWidgets('renders the widget type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: ActivePregnanciesCard(),
          ),
        ),
      );

      expect(find.byType(ActivePregnanciesCard), findsOneWidget);
    });
  });
}
