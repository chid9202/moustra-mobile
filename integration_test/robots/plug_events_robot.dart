import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page object for interacting with Plug Events screens in integration tests.
class PlugEventsRobot {
  PlugEventsRobot(this.tester);

  final WidgetTester tester;

  // ============ Plug Events List Screen Finders ============

  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get activeTab => find.widgetWithText(ChoiceChip, 'Active');
  Finder get completedTab => find.widgetWithText(ChoiceChip, 'Completed');
  Finder get allTab => find.widgetWithText(ChoiceChip, 'All');
  Finder get fabMenuButton => find.byType(FloatingActionButton);
  Finder get recordPlugEventAction => find.text('Record Plug Event');
  Finder get recordPlugCheckAction => find.text('Record Plug Check');
  Finder get viewButtons => find.byIcon(Icons.visibility);

  // ============ Plug Event New Screen Finders ============

  Finder get newScreenTitle => find.text('Record Plug Event');
  Finder get matingSelector => find.text('Mating (optional)');
  Finder get femaleSelector => find.text('Female *');
  Finder get maleSelector => find.text('Male');
  Finder get plugDateSelector => find.text('Plug Date *');
  Finder get targetEdayField =>
      find.widgetWithText(TextFormField, 'Target E-Day');
  Finder get commentField => find.widgetWithText(TextFormField, 'Comment');
  Finder get savePlugEventButton => find.text('Save Plug Event');

  // ============ Plug Event Detail Screen Finders ============

  Finder get saveButton => find.byIcon(Icons.save);
  Finder get deleteButton => find.byIcon(Icons.delete);
  Finder get recordOutcomeButton => find.text('Record Outcome');
  Finder get edayCard => find.textContaining('E-Day');
  Finder get detailTargetEdayField =>
      find.widgetWithText(TextFormField, 'Target E-Day');
  Finder get detailCommentField =>
      find.widgetWithText(TextFormField, 'Comment');
  Finder get backButton => find.byIcon(Icons.arrow_back);

  // ============ Outcome Dialog Finders ============

  Finder get outcomeDialogTitle => find.text('Record Outcome');
  Finder get liveBirthOption => find.text('Live Birth');
  Finder get harvestOption => find.text('Harvest');
  Finder get resorptionOption => find.text('Resorption');
  Finder get noPregnancyOption => find.text('No Pregnancy');
  Finder get cancelledOption => find.text('Cancelled');

  // ============ Delete Confirmation Dialog Finders ============

  Finder get deleteDialogTitle => find.text('Delete Plug Event');
  Finder get deleteConfirmButton => find.widgetWithText(TextButton, 'Delete');
  Finder get cancelButton => find.text('Cancel');

  // ============ Plug Events List Screen Methods ============

  /// Verifies that the Plug Events list screen is displayed with tab chips.
  Future<void> verifyPlugEventsListDisplayed() async {
    expect(activeTab, findsOneWidget);
    expect(completedTab, findsOneWidget);
    expect(allTab, findsOneWidget);
  }

  /// Taps the Active tab.
  Future<void> tapActiveTab() async {
    await tester.tap(activeTab);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Taps the Completed tab.
  Future<void> tapCompletedTab() async {
    await tester.tap(completedTab);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Taps the All tab.
  Future<void> tapAllTab() async {
    await tester.tap(allTab);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Opens the FAB menu by tapping the floating action button.
  Future<void> openFabMenu() async {
    final fab = fabMenuButton;
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();
  }

  /// Taps the "Record Plug Event" FAB menu action.
  Future<void> tapRecordPlugEvent() async {
    final action = recordPlugEventAction;
    expect(action, findsOneWidget);
    await tester.tap(action);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Taps the "Record Plug Check" FAB menu action.
  Future<void> tapRecordPlugCheck() async {
    final action = recordPlugCheckAction;
    expect(action, findsOneWidget);
    await tester.tap(action);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Taps the first view button in the list to open a plug event detail.
  Future<void> tapFirstViewButton() async {
    final buttons = viewButtons;
    expect(buttons, findsWidgets);
    await tester.tap(buttons.first);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ============ Plug Event New Screen Methods ============

  /// Verifies that the new plug event form is displayed.
  Future<void> verifyNewPlugEventFormDisplayed() async {
    expect(newScreenTitle, findsOneWidget);
    expect(targetEdayField, findsOneWidget);
    expect(commentField, findsOneWidget);
    expect(savePlugEventButton, findsOneWidget);
  }

  /// Enters a value in the Target E-Day field.
  Future<void> enterTargetEday(String value) async {
    await tester.enterText(targetEdayField, value);
    await tester.pump();
  }

  /// Enters a value in the Comment field.
  Future<void> enterComment(String value) async {
    await tester.enterText(commentField, value);
    await tester.pump();
  }

  /// Taps the "Save Plug Event" button on the new form.
  Future<void> tapSavePlugEvent() async {
    await tester.tap(savePlugEventButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ============ Plug Event Detail Screen Methods ============

  /// Verifies that the plug event detail screen is displayed.
  Future<void> verifyPlugEventDetailDisplayed() async {
    // The detail screen shows an E-Day card and info sections
    expect(edayCard, findsWidgets);
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('Dates'), findsOneWidget);
  }

  /// Taps the save icon button in the app bar.
  Future<void> tapSaveButton() async {
    await tester.tap(saveButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Taps the delete icon button in the app bar.
  Future<void> tapDeleteButton() async {
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
  }

  /// Confirms the delete action in the confirmation dialog.
  Future<void> confirmDelete() async {
    expect(deleteDialogTitle, findsOneWidget);
    await tester.tap(deleteConfirmButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Cancels the delete action in the confirmation dialog.
  Future<void> cancelDelete() async {
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
  }

  /// Taps the "Record Outcome" button (visible only on active events).
  Future<void> tapRecordOutcomeButton() async {
    // Scroll to make sure the button is visible
    await scrollToFind(recordOutcomeButton);
    await tester.tap(recordOutcomeButton);
    await tester.pumpAndSettle();
  }

  /// Verifies the outcome dialog is displayed with outcome options.
  Future<void> verifyOutcomeDialogDisplayed() async {
    expect(outcomeDialogTitle, findsOneWidget);
    expect(liveBirthOption, findsOneWidget);
    expect(harvestOption, findsOneWidget);
  }

  /// Edits the Target E-Day field on the detail screen.
  Future<void> editDetailTargetEday(String value) async {
    await scrollToFind(detailTargetEdayField);
    await tester.enterText(detailTargetEdayField, value);
    await tester.pump();
  }

  /// Edits the Comment field on the detail screen.
  Future<void> editDetailComment(String value) async {
    await scrollToFind(detailCommentField);
    await tester.enterText(detailCommentField, value);
    await tester.pump();
  }

  /// Taps the back button to return to the list.
  Future<void> tapBackButton() async {
    await tester.tap(backButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Verifies a success snackbar is shown.
  Future<void> verifySuccessSnackbar(String message) async {
    expect(find.textContaining(message), findsOneWidget);
  }

  // ============ Utility Methods ============

  /// Waits for network operations to complete.
  Future<void> waitForNetwork({int seconds = 5}) async {
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }

  /// Scrolls down to find an element.
  Future<void> scrollToFind(Finder finder) async {
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(
        finder,
        100,
        scrollable: scrollables.first,
      );
    }
  }
}
