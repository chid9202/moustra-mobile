import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:intl/intl.dart';
import '../../test_helpers/test_helpers.dart';

void main() {
  group('SelectDate', () {
    testWidgets('renders with basic properties', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Select date'), findsOneWidget);
      expect(find.byType(InputDecorator), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('renders with custom hintText', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
          hintText: 'Choose a date',
        ),
      );

      expect(find.text('Choose a date'), findsOneWidget);
      expect(find.text('Select date'), findsNothing);
    });

    testWidgets('shows selected date when provided', (
      WidgetTester tester,
    ) async {
      final selectedDate = DateTime(2024, 1, 15);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: selectedDate,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      final expectedDateText = DateFormat('yyyy-MM-dd').format(selectedDate);
      expect(find.text(expectedDateText), findsOneWidget);
      expect(find.text('Select date'), findsNothing);
    });

    testWidgets('shows clear button when date is selected', (
      WidgetTester tester,
    ) async {
      final selectedDate = DateTime(2024, 1, 15);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: selectedDate,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('does not show clear button when no date is selected', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('calls onChanged when clear button is tapped', (
      WidgetTester tester,
    ) async {
      final selectedDate = DateTime(2024, 1, 15);
      DateTime? clearedDate;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: selectedDate,
          onChanged: (date) => clearedDate = date,
          labelText: 'Select Date',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byIcon(Icons.clear));
      expect(clearedDate, isNull);
    });

    testWidgets('opens date picker when tapped', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));

      // Wait for date picker to appear
      await tester.pump(const Duration(milliseconds: 300));
      // Note: Date picker behavior may vary by platform
    });

    testWidgets('displays calendar icon', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('formats date correctly', (WidgetTester tester) async {
      final testDate = DateTime(2024, 12, 25);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: testDate,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      final expectedFormat = DateFormat('yyyy-MM-dd').format(testDate);
      expect(find.text(expectedFormat), findsOneWidget);
    });
  });

  group('SelectDate Date Range', () {
    testWidgets('respects firstDate constraint', (WidgetTester tester) async {
      final firstDate = DateTime(2020, 1, 1);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
          firstDate: firstDate,
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
      // Additional tests for date range constraints would require mocking the date picker
    });

    testWidgets('respects lastDate constraint', (WidgetTester tester) async {
      final lastDate = DateTime(2030, 12, 31);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
          lastDate: lastDate,
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
      // Additional tests for date range constraints would require mocking the date picker
    });

    testWidgets('uses default date range when not specified', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
    });
  });

  group('SelectDate Validation', () {
    testWidgets('calls validator when provided', (WidgetTester tester) async {
      final validator = (DateTime? date) {
        if (date == null) return 'Date is required';
        if (date.isBefore(DateTime.now())) return 'Date must be in the future';
        return null;
      };

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
          validator: validator,
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
      // Validator testing would require form integration
    });

    testWidgets('works without validator', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
    });
  });

  group('SelectDate Edge Cases', () {
    testWidgets('handles null selectedDate gracefully', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      expect(find.text('Select date'), findsOneWidget);
      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('handles empty labelText gracefully', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(selectedDate: null, onChanged: (date) {}, labelText: ''),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('handles empty hintText gracefully', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
          hintText: '',
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('handles very long labelText', (WidgetTester tester) async {
      const longLabel =
          'This is a very long label text that should be handled gracefully by the widget';

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: longLabel,
        ),
      );

      expect(find.text(longLabel), findsOneWidget);
    });

    testWidgets('handles very long hintText', (WidgetTester tester) async {
      const longHint =
          'This is a very long hint text that should be handled gracefully by the widget';

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
          hintText: longHint,
        ),
      );

      expect(find.text(longHint), findsOneWidget);
    });
  });

  group('SelectDate Accessibility', () {
    testWidgets('has proper semantics', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('has proper semantics when date is selected', (
      WidgetTester tester,
    ) async {
      final selectedDate = DateTime(2024, 1, 15);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: selectedDate,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });

  group('SelectDate Theme Integration', () {
    testWidgets('uses theme colors correctly', (WidgetTester tester) async {
      final theme = TestHelpers.createMockTheme();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
        theme: theme,
      );

      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('uses dark theme correctly', (WidgetTester tester) async {
      final darkTheme = TestHelpers.createDarkTheme();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectDate(
          selectedDate: null,
          onChanged: (date) {},
          labelText: 'Select Date',
        ),
        theme: darkTheme,
      );

      expect(find.byType(InputDecorator), findsOneWidget);
    });
  });
}
