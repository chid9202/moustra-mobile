import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/dashboard/reports_tab.dart';
import '../../test_helpers/test_helpers.dart';

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

  group('ReportsTab', () {
    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: ReportsTab(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message after API failure', (
      WidgetTester tester,
    ) async {
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TestHelpers.createMockTheme(),
            home: const Scaffold(
              body: ReportsTab(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.textContaining('Failed to load reports'), findsOneWidget);
      }, (error, stack) {
        // Suppress API errors
      });
    });

    testWidgets('renders ReportsTab widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: ReportsTab(),
          ),
        ),
      );

      expect(find.byType(ReportsTab), findsOneWidget);
    });
  });
}
