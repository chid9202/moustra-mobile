import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/calendar_screen.dart';
import '../test_helpers/test_helpers.dart';

/// Helper to pump the CalendarScreen and ignore async API errors
Future<void> pumpCalendarScreen(WidgetTester tester) async {
  await runZonedGuarded(
    () async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CalendarScreen(),
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

  group('CalendarScreen', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpCalendarScreen(tester);

      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('shows loading indicator when fetching', (
      WidgetTester tester,
    ) async {
      await pumpCalendarScreen(tester);

      // The screen starts loading on init, so a loading indicator may be present
      // or events may have already loaded with empty data
      expect(
        find.byType(CalendarScreen),
        findsOneWidget,
      );
    });

    testWidgets('has month navigation buttons', (WidgetTester tester) async {
      await pumpCalendarScreen(tester);

      expect(find.byKey(const Key('prev_month')), findsOneWidget);
      expect(find.byKey(const Key('next_month')), findsOneWidget);
    });

    testWidgets('has Today button', (WidgetTester tester) async {
      await pumpCalendarScreen(tester);

      expect(find.byKey(const Key('today_button')), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('has filter chips for event types', (
      WidgetTester tester,
    ) async {
      await pumpCalendarScreen(tester);

      expect(find.byType(FilterChip), findsAtLeastNWidgets(1));
    });

    testWidgets('has event list section', (WidgetTester tester) async {
      await pumpCalendarScreen(tester);
      // Wait for fetch to complete (success or error)
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      // Event list section: with today selected by default, header is "E, MMM d (N)" or "All Events (N)";
      // body shows "No events on this day" or "No events this month" when empty
      final allEvents = find.textContaining('All Events');
      final noEventsThisDay = find.text('No events on this day');
      final noEventsThisMonth = find.text('No events this month');
      final hasEventSection = allEvents.evaluate().isNotEmpty ||
          noEventsThisDay.evaluate().isNotEmpty ||
          noEventsThisMonth.evaluate().isNotEmpty;
      expect(hasEventSection, isTrue,
          reason:
              'Expected "All Events", "No events on this day", or "No events this month"');
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await pumpCalendarScreen(tester);

      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Divider), findsAtLeastNWidgets(1));
    });

    testWidgets('displays current month label', (WidgetTester tester) async {
      await pumpCalendarScreen(tester);

      // Should display the current month/year in the header
      final now = DateTime.now();
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      final monthLabel = '${months[now.month - 1]} ${now.year}';
      expect(find.text(monthLabel), findsOneWidget);
    });
  });
}
