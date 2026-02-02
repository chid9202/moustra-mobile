import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page object for interacting with the Cages Grid screen in integration tests.
class CagesGridRobot {
  CagesGridRobot(this.tester);

  final WidgetTester tester;

  /// Finders for cages grid screen elements.
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get cagesGridView => find.byType(GridView);
  Finder get bottomNavCages => find.byIcon(Icons.grid_view);
  Finder get cageCards => find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).borderRadius != null,
      );

  /// Navigate to cages grid from bottom navigation.
  Future<void> navigateToCagesGrid() async {
    await tester.tap(bottomNavCages);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Verifies that the cages grid is loaded.
  Future<void> verifyCagesGridLoaded() async {
    expect(loadingIndicator, findsNothing);
    expect(cagesGridView, findsOneWidget);
  }

  /// Long press on a cage to open context menu.
  Future<void> longPressOnCage(String cageTag) async {
    final cageFinder = find.text(cageTag);
    expect(cageFinder, findsOneWidget);
    await tester.longPress(cageFinder);
    await tester.pumpAndSettle();
  }

  /// Tap on "Move" option in context menu.
  Future<void> tapMoveOption() async {
    final moveFinder = find.text('Move');
    await tester.tap(moveFinder);
    await tester.pumpAndSettle();
  }

  /// Verify move cage dialog is displayed.
  Future<void> verifyMoveCageDialogDisplayed() async {
    expect(find.text('Move Cage'), findsOneWidget);
  }

  /// Enter new row position (1-indexed).
  Future<void> enterRow(int row) async {
    final rowField = find.widgetWithText(TextFormField, 'Row');
    await tester.enterText(rowField, row.toString());
    await tester.pump();
  }

  /// Enter new column position (1-indexed).
  Future<void> enterColumn(int column) async {
    final columnField = find.widgetWithText(TextFormField, 'Column');
    await tester.enterText(columnField, column.toString());
    await tester.pump();
  }

  /// Tap move button in dialog.
  Future<void> tapMoveButton() async {
    final moveButton = find.widgetWithText(TextButton, 'Move');
    await tester.tap(moveButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Tap cancel button in dialog.
  Future<void> tapCancelButton() async {
    final cancelButton = find.text('Cancel');
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
  }

  /// Verify success snackbar is shown.
  Future<void> verifyMoveSuccess() async {
    expect(find.textContaining('moved'), findsOneWidget);
  }

  /// Get cage position info from dialog (for verification).
  Future<Map<String, int>> getCurrentPositionFromDialog() async {
    // This reads the current position displayed in the dialog
    // Format: "Current position: Row X, Column Y"
    final currentPosFinder = find.textContaining('Current position');
    expect(currentPosFinder, findsOneWidget);

    final text =
        (tester.widget(currentPosFinder) as Text).data ?? '';
    final rowMatch = RegExp(r'Row (\d+)').firstMatch(text);
    final colMatch = RegExp(r'Column (\d+)').firstMatch(text);

    return {
      'row': int.tryParse(rowMatch?.group(1) ?? '0') ?? 0,
      'column': int.tryParse(colMatch?.group(1) ?? '0') ?? 0,
    };
  }
}
