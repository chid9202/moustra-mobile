import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page object for interacting with the Notification screen in integration tests.
class NotificationRobot {
  NotificationRobot(this.tester);

  final WidgetTester tester;

  // ============ Finders ============

  Finder get bellIcon => find.byIcon(Icons.notifications_outlined);
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get emptyState => find.text('No notifications');
  Finder get markAllReadButton => find.text('Mark all read');
  Finder get notificationItems => find.byType(ListTile);

  // ============ Methods ============

  /// Taps the notification bell icon in the app bar.
  Future<void> tapBell() async {
    await tester.tap(bellIcon);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Verifies that the Notifications screen is displayed.
  Future<void> verifyScreenLoaded() async {
    expect(find.text('Notifications'), findsOneWidget);
    expect(markAllReadButton, findsOneWidget);
  }

  /// Taps a notification by its title text.
  Future<void> tapNotification(String title) async {
    final finder = find.text(title);
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
  }

  /// Verifies that the detail bottom sheet is visible for a given title.
  Future<void> verifyDetailSheetVisible(String title) async {
    expect(find.text(title), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  }

  /// Waits for network operations to complete.
  Future<void> waitForNetwork({int seconds = 5}) async {
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }
}
