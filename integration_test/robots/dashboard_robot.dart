import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page object for interacting with the Dashboard screen in integration tests.
class DashboardRobot {
  DashboardRobot(this.tester);

  final WidgetTester tester;

  /// Finders for dashboard screen elements.
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get dashboardCards => find.byType(Card);
  Finder get miceCountByAgeTitle => find.text('Mice Count by Age');
  Finder get animalsToWeanTitle => find.text('Animals To Wean');
  Finder get dataByAccountTitle => find.text('Data by Account');

  /// Verifies that the dashboard is fully loaded with cards.
  Future<void> verifyDashboardLoaded() async {
    // Should not be loading anymore
    expect(loadingIndicator, findsNothing);

    // Should have 4 cards (Mice Count by Age, Animals To Wean, Data by Account, Mice by Sex)
    expect(dashboardCards, findsNWidgets(4));
  }

  /// Verifies that the dashboard is currently loading.
  Future<void> verifyLoading() async {
    expect(loadingIndicator, findsOneWidget);
  }

  /// Verifies that specific dashboard card titles are visible.
  Future<void> verifyCardTitlesVisible() async {
    expect(miceCountByAgeTitle, findsOneWidget);
    expect(animalsToWeanTitle, findsOneWidget);
    expect(dataByAccountTitle, findsOneWidget);
  }

  /// Waits for the dashboard to finish loading with a custom timeout.
  Future<void> waitForDashboardToLoad({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    // Wait for loading to complete with timeout
    await tester.pumpAndSettle(timeout);
  }
}
