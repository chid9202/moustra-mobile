import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/services/auth_service.dart';

import 'robots/login_robot.dart';
import 'robots/plug_events_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env.test');
    await authService.init();
  });

  /// Helper: login and navigate to Plug Events screen.
  Future<PlugEventsRobot> loginAndNavigateToPlugEvents(
    WidgetTester tester,
  ) async {
    // 1. Load app
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // 2. Login
    final loginRobot = LoginRobot(tester);
    await loginRobot.verifyLoginScreenDisplayed();

    final email = dotenv.env['TEST_EMAIL']!;
    final password = dotenv.env['TEST_PASSWORD']!;

    await loginRobot.enterEmail(email);
    await loginRobot.enterPassword(password);
    await loginRobot.tapSignIn();

    // Wait for login and dashboard load
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // 3. Navigate to Plug Events via drawer
    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    final plugEventsMenuItem = find.text('Plug Events');
    expect(plugEventsMenuItem, findsOneWidget);
    await tester.tap(plugEventsMenuItem);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    debugPrint('Navigated to Plug Events screen');

    return PlugEventsRobot(tester);
  }

  group('Plug Events Flow', () {
    testWidgets('navigate to plug events and verify list tabs', (
      tester,
    ) async {
      final robot = await loginAndNavigateToPlugEvents(tester);

      // Verify the list screen is displayed with tab chips
      await robot.verifyPlugEventsListDisplayed();
      debugPrint('Plug Events list screen verified with Active/Completed/All tabs');

      // Test switching tabs
      await robot.tapCompletedTab();
      debugPrint('Switched to Completed tab');

      await robot.tapAllTab();
      debugPrint('Switched to All tab');

      await robot.tapActiveTab();
      debugPrint('Switched back to Active tab');

      debugPrint('Tab switching test PASSED');
    });

    testWidgets('open FAB menu and navigate to new plug event form', (
      tester,
    ) async {
      final robot = await loginAndNavigateToPlugEvents(tester);
      await robot.verifyPlugEventsListDisplayed();

      // Open FAB menu
      await robot.openFabMenu();
      debugPrint('FAB menu opened');

      // Tap Record Plug Event
      await robot.tapRecordPlugEvent();
      debugPrint('Navigated to new plug event form');

      // Verify form is displayed
      await robot.verifyNewPlugEventFormDisplayed();
      debugPrint('New plug event form verified');

      // Fill in optional fields
      await robot.enterTargetEday('18');
      await robot.enterComment('Integration test plug event');
      debugPrint('Form fields filled in');

      debugPrint('New plug event form test PASSED');
    });

    testWidgets('view plug event detail screen', (tester) async {
      final robot = await loginAndNavigateToPlugEvents(tester);
      await robot.verifyPlugEventsListDisplayed();

      // Wait for data to load
      await robot.waitForNetwork(seconds: 5);

      // Check if there are any view buttons (plug events in the list)
      final viewButtons = find.byIcon(Icons.visibility);
      if (viewButtons.evaluate().isEmpty) {
        debugPrint('No plug events found in list - skipping detail view test');
        return;
      }

      // Tap the first view button to open detail
      await robot.tapFirstViewButton();
      debugPrint('Opened plug event detail');

      // Verify detail screen is displayed
      await robot.verifyPlugEventDetailDisplayed();
      debugPrint('Detail screen verified with E-Day card and info sections');

      // Verify action buttons are present
      expect(robot.saveButton, findsOneWidget);
      expect(robot.deleteButton, findsOneWidget);
      debugPrint('Save and delete buttons verified');

      // Check if Record Outcome button is present (only for active events)
      final outcomeButton = find.text('Record Outcome');
      if (outcomeButton.evaluate().isNotEmpty) {
        debugPrint('Record Outcome button found (active event)');
      } else {
        debugPrint('No Record Outcome button (completed event)');
      }

      debugPrint('Detail screen test PASSED');
    });

    testWidgets('edit plug event detail fields and save', (tester) async {
      final robot = await loginAndNavigateToPlugEvents(tester);
      await robot.verifyPlugEventsListDisplayed();

      await robot.waitForNetwork(seconds: 5);

      final viewButtons = find.byIcon(Icons.visibility);
      if (viewButtons.evaluate().isEmpty) {
        debugPrint('No plug events found - skipping edit test');
        return;
      }

      // Open detail
      await robot.tapFirstViewButton();
      await robot.verifyPlugEventDetailDisplayed();

      // Edit the comment field
      await robot.editDetailComment('Updated via integration test');
      debugPrint('Comment field updated');

      // Save
      await robot.tapSaveButton();
      debugPrint('Save button tapped');

      // Verify success snackbar
      await robot.verifySuccessSnackbar('updated successfully');
      debugPrint('Edit and save test PASSED');
    });

    testWidgets('record outcome dialog on active plug event', (tester) async {
      final robot = await loginAndNavigateToPlugEvents(tester);
      await robot.verifyPlugEventsListDisplayed();

      // Make sure we are on the Active tab
      await robot.tapActiveTab();
      await robot.waitForNetwork(seconds: 5);

      final viewButtons = find.byIcon(Icons.visibility);
      if (viewButtons.evaluate().isEmpty) {
        debugPrint('No active plug events found - skipping outcome test');
        return;
      }

      // Open detail of an active event
      await robot.tapFirstViewButton();
      await robot.verifyPlugEventDetailDisplayed();

      // Check if Record Outcome button exists
      final outcomeButton = find.text('Record Outcome');
      if (outcomeButton.evaluate().isEmpty) {
        debugPrint('Event is not active - skipping outcome dialog test');
        return;
      }

      // Tap Record Outcome
      await robot.tapRecordOutcomeButton();
      debugPrint('Record Outcome button tapped');

      // Verify outcome dialog is displayed
      await robot.verifyOutcomeDialogDisplayed();
      debugPrint('Outcome dialog verified with options');

      // Dismiss dialog without selecting (avoid changing real data)
      final cancelButton = find.text('Cancel');
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        debugPrint('Outcome dialog dismissed');
      }

      debugPrint('Record outcome dialog test PASSED');
    });
  });
}
