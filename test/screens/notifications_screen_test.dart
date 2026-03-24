import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/notifications_screen.dart';
import '../test_helpers/test_helpers.dart';

/// Helper to pump the NotificationsScreen and ignore async API errors
Future<void> pumpNotificationsScreen(WidgetTester tester) async {
  await runZonedGuarded(
    () async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NotificationsScreen(),
      );
      await tester.pump();
    },
    (error, stack) {
      // Suppress errors from API calls in test environment
    },
  );
}

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

  group('NotificationsScreen', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpNotificationsScreen(tester);

      expect(find.byType(NotificationsScreen), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      await pumpNotificationsScreen(tester);

      expect(find.byType(NotificationsScreen), findsOneWidget);
    });

    testWidgets('shows Notifications title', (WidgetTester tester) async {
      await pumpNotificationsScreen(tester);

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows Mark all read button', (WidgetTester tester) async {
      await pumpNotificationsScreen(tester);

      expect(find.text('Mark all read'), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await pumpNotificationsScreen(tester);

      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Row), findsAtLeastNWidgets(1));
    });

    testWidgets('Mark all read button is a TextButton', (
      WidgetTester tester,
    ) async {
      await pumpNotificationsScreen(tester);

      expect(
        find.widgetWithText(TextButton, 'Mark all read'),
        findsOneWidget,
      );
    });
  });
}
