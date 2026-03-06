import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page object for interacting with the Calendar screen in integration tests.
class CalendarRobot {
  CalendarRobot(this.tester);

  final WidgetTester tester;

  // ============ Finders ============

  Finder get prevMonthButton => find.byKey(const Key('prev_month'));
  Finder get nextMonthButton => find.byKey(const Key('next_month'));
  Finder get todayButton => find.byKey(const Key('today_button'));
  Finder get filterChips => find.byType(FilterChip);
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get eventList => find.byType(ListView);
  Finder get eventTiles => find.byType(ListTile);

  // ============ Methods ============

  /// Verifies that the Calendar screen is displayed.
  Future<void> verifyCalendarDisplayed() async {
    expect(find.textContaining('All Events'), findsOneWidget);
    expect(prevMonthButton, findsOneWidget);
    expect(nextMonthButton, findsOneWidget);
    expect(todayButton, findsOneWidget);
  }

  /// Taps the previous month navigation button.
  Future<void> tapPrevMonth() async {
    await tester.tap(prevMonthButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Taps the next month navigation button.
  Future<void> tapNextMonth() async {
    await tester.tap(nextMonthButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Taps the Today button.
  Future<void> tapToday() async {
    await tester.tap(todayButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Taps a specific day number on the calendar grid.
  Future<void> tapDay(int day) async {
    final dayFinder = find.text(day.toString());
    if (dayFinder.evaluate().isNotEmpty) {
      await tester.tap(dayFinder.first);
      await tester.pumpAndSettle();
    }
  }

  /// Toggles an event type filter chip by its label.
  Future<void> toggleEventTypeFilter(String label) async {
    final chipFinder = find.widgetWithText(FilterChip, label);
    if (chipFinder.evaluate().isNotEmpty) {
      await tester.tap(chipFinder);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
  }

  /// Taps the first event tile in the event list.
  Future<void> tapFirstEvent() async {
    final tiles = eventTiles;
    if (tiles.evaluate().isNotEmpty) {
      await tester.tap(tiles.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
  }

  /// Waits for network operations to complete.
  Future<void> waitForNetwork({int seconds = 5}) async {
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }
}
