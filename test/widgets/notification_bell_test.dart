import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/notification_bell.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  group('NotificationBell', () {
    testWidgets('renders bell icon', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NotificationBell(),
      );
      await tester.pump();

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('renders as an IconButton', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NotificationBell(),
      );
      await tester.pump();

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('contains a Badge widget', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NotificationBell(),
      );
      await tester.pump();

      expect(find.byType(Badge), findsOneWidget);
    });

    testWidgets('badge is hidden when unread count is 0 (initial state with NoOp client)', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NotificationBell(),
      );
      await tester.pump();

      // With NoOpDioApiClient, fetch fails silently, count stays at 0
      // Badge should have isLabelVisible = false
      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
    });

    testWidgets('timer is cancelled on dispose', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NotificationBell(),
      );
      await tester.pump();

      // Rebuild with a different widget to trigger dispose
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SizedBox(),
      );
      await tester.pump();

      // No exception means timer was properly cancelled
    });
  });
}
