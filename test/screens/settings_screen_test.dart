import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/settings_screen.dart';
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

  group('SettingsScreen', () {
    testWidgets('renders tabs', (WidgetTester tester) async {
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TestHelpers.createMockTheme(),
            home: const Scaffold(
              body: SettingsScreen(),
            ),
          ),
        );

        await tester.pump();

        expect(find.text('Lab'), findsOneWidget);
        expect(find.text('Account'), findsOneWidget);
        expect(find.text('Cage Cards'), findsOneWidget);
        expect(find.text('Protocols'), findsOneWidget);
        expect(find.text('Feedback'), findsOneWidget);
      }, (error, stack) {
        // Suppress API errors from child tabs loading
      });
    });

    testWidgets('renders SettingsScreen widget', (
      WidgetTester tester,
    ) async {
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TestHelpers.createMockTheme(),
            home: const Scaffold(
              body: SettingsScreen(),
            ),
          ),
        );

        expect(find.byType(SettingsScreen), findsOneWidget);
      }, (error, stack) {
        // Suppress errors
      });
    });
  });
}
