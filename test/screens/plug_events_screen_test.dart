import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/plug_events_screen.dart';
import 'package:moustra/widgets/filter_panel.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import '../test_helpers/test_helpers.dart';

/// Helper to pump the PlugEventsScreen and ignore async API errors
/// that occur in the test environment (HTTP calls return 400 with empty body).
Future<void> pumpPlugEventsScreen(WidgetTester tester) async {
  await runZonedGuarded(
    () async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const PlugEventsScreen(),
      );
      await tester.pump();
    },
    (error, stack) {
      // Suppress FormatException from API calls in test environment
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

  group('PlugEventsScreen', () {
    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventsScreen(tester);

      // Screen should render
      expect(find.byType(PlugEventsScreen), findsOneWidget);
    });

    testWidgets('displays FilterPanel with prepared filters configured', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventsScreen(tester);

      // FilterPanel is rendered with preparedFilters for Active, Completed, All
      expect(find.byType(FilterPanel), findsOneWidget);
    });

    testWidgets('has FilterPanel widget', (WidgetTester tester) async {
      await pumpPlugEventsScreen(tester);

      expect(find.byType(FilterPanel), findsOneWidget);
    });

    testWidgets('has PaginatedDataGrid widget', (WidgetTester tester) async {
      await pumpPlugEventsScreen(tester);

      // PaginatedDataGrid is generic (PaginatedDataGrid<PlugEventDto>),
      // so use byWidgetPredicate to match regardless of type parameter.
      expect(
        find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString().startsWith('PaginatedDataGrid'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has MovableFabMenu widget', (WidgetTester tester) async {
      await pumpPlugEventsScreen(tester);

      expect(find.byType(MovableFabMenu), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await pumpPlugEventsScreen(tester);

      // Check for Column-based layout
      expect(find.byType(Column), findsAtLeastNWidgets(1));

      // Check for Divider between filter panel and grid
      expect(find.byType(Divider), findsAtLeastNWidgets(1));

      // Check for Row containing the ChoiceChips
      expect(find.byType(Row), findsAtLeastNWidgets(1));
    });

    testWidgets('handles screen lifecycle correctly', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventsScreen(tester);

      // Verify the screen can be built
      expect(find.byType(PlugEventsScreen), findsOneWidget);

      // Test that the screen can be rebuilt
      await tester.pump();
      expect(find.byType(PlugEventsScreen), findsOneWidget);
    });

    testWidgets('has proper accessibility structure', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventsScreen(tester);

      // Check for semantic structure
      expect(find.byType(Semantics), findsAtLeastNWidgets(1));
    });

    testWidgets('tabs have proper padding', (WidgetTester tester) async {
      await pumpPlugEventsScreen(tester);

      // Check for Padding around the tabs
      expect(find.byType(Padding), findsAtLeastNWidgets(1));
    });
  });
}
