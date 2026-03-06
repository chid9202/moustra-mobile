import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moustra/main.dart' as app;

import 'robots/calendar_robot.dart';
import 'robots/login_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Calendar Integration Tests', () {
    testWidgets('navigate to calendar and verify display', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Login first
      final loginRobot = LoginRobot(tester);
      await loginRobot.tapSignIn();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Open drawer and navigate to Calendar
      final scaffoldState = tester.state<ScaffoldState>(
        find.byType(Scaffold).first,
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify Calendar screen is displayed
      final calendarRobot = CalendarRobot(tester);
      await calendarRobot.verifyCalendarDisplayed();
    });

    testWidgets('month navigation works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final loginRobot = LoginRobot(tester);
      await loginRobot.tapSignIn();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Calendar
      final scaffoldState = tester.state<ScaffoldState>(
        find.byType(Scaffold).first,
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final calendarRobot = CalendarRobot(tester);

      // Navigate to next month
      await calendarRobot.tapNextMonth();

      // Navigate to previous month
      await calendarRobot.tapPrevMonth();

      // Tap Today to return to current month
      await calendarRobot.tapToday();
    });

    testWidgets('day selection and event tap', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final loginRobot = LoginRobot(tester);
      await loginRobot.tapSignIn();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Calendar
      final scaffoldState = tester.state<ScaffoldState>(
        find.byType(Scaffold).first,
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final calendarRobot = CalendarRobot(tester);

      // Tap a day
      await calendarRobot.tapDay(15);

      // If there are events, tap the first one
      await calendarRobot.tapFirstEvent();
    });
  });
}
