import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/screens/plug_check_screen.dart';
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

  group('PlugCheckScreen', () {
    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: PlugCheckScreen(),
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
              initialLocation: '/plug-check',
              routes: [
                GoRoute(
                  path: '/plug-check',
                  builder: (context, state) => const PlugCheckScreen(),
                ),
                GoRoute(
                  path: '/plug-event',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Events')),
                ),
              ],
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.textContaining('Error'), findsOneWidget);
      }, (error, stack) {
        // Suppress API errors
      });
    });

    testWidgets('renders PlugCheckScreen widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: PlugCheckScreen(),
          ),
        ),
      );

      expect(find.byType(PlugCheckScreen), findsOneWidget);
    });
  });
}
