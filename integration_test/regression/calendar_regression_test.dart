import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/integration_test_helpers.dart';
import '../robots/calendar_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadIntegrationTestEnv();
  });

  group('Regression: Calendar', () {
    testWidgets('navigate to calendar and verify display', (
      WidgetTester tester,
    ) async {
      await pumpAppAndSignIn(tester);

      final scaffoldState = tester.state<ScaffoldState>(
        find.byType(Scaffold).first,
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final calendarRobot = CalendarRobot(tester);
      await calendarRobot.verifyCalendarDisplayed();
    });

    testWidgets('month navigation works', (WidgetTester tester) async {
      await pumpAppAndSignIn(tester);

      final scaffoldState = tester.state<ScaffoldState>(
        find.byType(Scaffold).first,
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final calendarRobot = CalendarRobot(tester);
      await calendarRobot.tapNextMonth();
      await calendarRobot.tapPrevMonth();
      await calendarRobot.tapToday();
    });

    testWidgets('day selection and event tap', (WidgetTester tester) async {
      await pumpAppAndSignIn(tester);

      final scaffoldState = tester.state<ScaffoldState>(
        find.byType(Scaffold).first,
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final calendarRobot = CalendarRobot(tester);
      await calendarRobot.tapDay(15);
      await calendarRobot.tapFirstEvent();
    });
  });
}
