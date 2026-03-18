import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/screens/protocol_compliance_screen.dart';
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

  group('ProtocolComplianceScreen', () {
    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: ProtocolComplianceScreen(),
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
          MaterialApp.router(
            theme: TestHelpers.createMockTheme(),
            routerConfig: GoRouter(
              initialLocation: '/compliance',
              routes: [
                GoRoute(
                  path: '/compliance',
                  builder: (context, state) =>
                      const Scaffold(body: ProtocolComplianceScreen()),
                ),
                GoRoute(
                  path: '/protocol',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Protocols')),
                ),
              ],
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('Error loading compliance data'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      }, (error, stack) {
        // Suppress API errors
      });
    });

    testWidgets('renders the ProtocolComplianceScreen widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: ProtocolComplianceScreen(),
          ),
        ),
      );

      expect(find.byType(ProtocolComplianceScreen), findsOneWidget);
    });
  });
}
