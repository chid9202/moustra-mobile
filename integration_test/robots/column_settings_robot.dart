import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page object for interacting with the Column Settings bottom sheet
/// and the Columns chip on FilterPanel in integration tests.
class ColumnSettingsRobot {
  ColumnSettingsRobot(this.tester);

  final WidgetTester tester;

  // ============ FilterPanel Finders ============

  /// The "Columns" action chip in the FilterPanel header.
  Finder get columnsChip => find.widgetWithText(ActionChip, 'Columns');

  /// The view_column icon (appears in both chip and sheet).
  Finder get viewColumnIcon => find.byIcon(Icons.view_column);

  // ============ Bottom Sheet Finders ============

  Finder get sheetTitle => find.text('Column Settings');
  Finder get resetButton => find.text('Reset to Defaults');
  Finder get dragHandles => find.byIcon(Icons.drag_handle);
  Finder get switches => find.byType(Switch);
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);

  // ============ FilterPanel Methods ============

  /// Verifies the Columns chip is visible in the FilterPanel.
  Future<void> verifyColumnsChipVisible() async {
    expect(columnsChip, findsOneWidget);
  }

  /// Verifies the Columns chip is NOT visible (settings not yet loaded).
  Future<void> verifyColumnsChipNotVisible() async {
    expect(columnsChip, findsNothing);
  }

  /// Taps the Columns chip to open the bottom sheet.
  Future<void> openColumnSettings() async {
    expect(columnsChip, findsOneWidget);
    await tester.tap(columnsChip);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  // ============ Bottom Sheet Methods ============

  /// Verifies the column settings bottom sheet is displayed.
  Future<void> verifySheetDisplayed() async {
    expect(sheetTitle, findsOneWidget);
    expect(resetButton, findsOneWidget);
    expect(dragHandles, findsWidgets);
    expect(switches, findsWidgets);
  }

  /// Returns the number of column rows in the sheet.
  int getColumnCount() {
    return dragHandles.evaluate().length;
  }

  /// Returns all column labels displayed in the sheet.
  List<String> getColumnLabels() {
    final listTiles = find.byType(ListTile);
    final labels = <String>[];
    for (final element in listTiles.evaluate()) {
      final widget = element.widget as ListTile;
      if (widget.title is Text) {
        labels.add((widget.title as Text).data ?? '');
      }
    }
    return labels;
  }

  /// Finds the Switch for a column by its label text.
  Finder switchForColumn(String label) {
    return find.descendant(
      of: find.ancestor(
        of: find.text(label),
        matching: find.byType(ListTile),
      ),
      matching: find.byType(Switch),
    );
  }

  /// Toggles a column's visibility off (assumes currently on).
  Future<void> toggleColumnOff(String label) async {
    final sw = switchForColumn(label);
    expect(sw, findsOneWidget);
    await tester.tap(sw);
    await tester.pumpAndSettle();
  }

  /// Toggles a column's visibility on (assumes currently off).
  Future<void> toggleColumnOn(String label) async {
    final sw = switchForColumn(label);
    expect(sw, findsOneWidget);
    await tester.tap(sw);
    await tester.pumpAndSettle();
  }

  /// Gets the current value of a column's Switch.
  bool isColumnVisible(String label) {
    final sw = switchForColumn(label);
    final widget = tester.widget<Switch>(sw);
    return widget.value;
  }

  /// Taps "Reset to Defaults".
  Future<void> tapResetToDefaults() async {
    expect(resetButton, findsOneWidget);
    await tester.tap(resetButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Dismisses the bottom sheet by tapping outside or dragging down.
  Future<void> dismissSheet() async {
    // Tap the scrim (barrier) above the sheet
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
  }

  // ============ Grid Verification Methods ============

  /// Checks if a column header with the given text exists in the data grid.
  bool isGridColumnVisible(String headerText) {
    return find.text(headerText).evaluate().isNotEmpty;
  }

  // ============ Utility ============

  /// Waits for network operations.
  Future<void> waitForNetwork({int seconds = 3}) async {
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }
}
