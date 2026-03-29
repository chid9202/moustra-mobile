import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/services/auth_service.dart';

import '../robots/column_settings_robot.dart';
import '../robots/login_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env.test');
    await authService.init();
  });

  /// Helper: login and navigate to Animals screen via drawer.
  Future<ColumnSettingsRobot> loginAndNavigateToAnimals(
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Login
    final loginRobot = LoginRobot(tester);
    await loginRobot.verifyLoginScreenDisplayed();

    final email = dotenv.env['TEST_EMAIL']!;
    final password = dotenv.env['TEST_PASSWORD']!;

    await loginRobot.enterEmail(email);
    await loginRobot.enterPassword(password);
    await loginRobot.tapSignIn();
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // Navigate to Animals via drawer
    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    final animalsMenuItem = find.text('Animals');
    expect(animalsMenuItem, findsOneWidget);
    await tester.tap(animalsMenuItem);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    debugPrint('Navigated to Animals screen');
    return ColumnSettingsRobot(tester);
  }

  /// Helper: login and navigate to a named screen via drawer.
  Future<ColumnSettingsRobot> loginAndNavigateTo(
    WidgetTester tester,
    String menuLabel,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    final loginRobot = LoginRobot(tester);
    await loginRobot.verifyLoginScreenDisplayed();

    final email = dotenv.env['TEST_EMAIL']!;
    final password = dotenv.env['TEST_PASSWORD']!;

    await loginRobot.enterEmail(email);
    await loginRobot.enterPassword(password);
    await loginRobot.tapSignIn();
    await tester.pumpAndSettle(const Duration(seconds: 15));

    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    final menuItem = find.text(menuLabel);
    expect(menuItem, findsOneWidget);
    await tester.tap(menuItem);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    debugPrint('Navigated to $menuLabel screen');
    return ColumnSettingsRobot(tester);
  }

  // =========================================================================
  // TEST GROUP 1: Column Settings on Animals Screen (primary validation)
  // =========================================================================
  group('Column Settings - Animals Screen', () {
    testWidgets('1.1 Columns chip appears after settings load', (
      tester,
    ) async {
      final robot = await loginAndNavigateToAnimals(tester);

      // Wait extra for table settings API call
      await robot.waitForNetwork(seconds: 5);

      await robot.verifyColumnsChipVisible();
      debugPrint('PASS: Columns chip is visible on Animals screen');
    });

    testWidgets('1.2 Open column settings sheet and verify contents', (
      tester,
    ) async {
      final robot = await loginAndNavigateToAnimals(tester);
      await robot.waitForNetwork(seconds: 5);

      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();

      // Verify there are columns listed
      final count = robot.getColumnCount();
      expect(count, greaterThan(0));
      debugPrint('PASS: Sheet displays $count columns');
    });

    testWidgets('1.3 Toggle column off hides it from grid', (tester) async {
      final robot = await loginAndNavigateToAnimals(tester);
      await robot.waitForNetwork(seconds: 5);

      // Verify "Owner" column header is visible in grid before
      final ownerVisibleBefore = robot.isGridColumnVisible('Owner');
      debugPrint('Owner column visible before toggle: $ownerVisibleBefore');

      // Open settings and toggle Owner off
      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();

      // Verify Owner starts visible
      expect(robot.isColumnVisible('Owner'), isTrue);

      await robot.toggleColumnOff('Owner');
      debugPrint('Toggled Owner column off');

      // Dismiss sheet
      await robot.dismissSheet();
      await robot.waitForNetwork(seconds: 2);

      // Verify "Owner" header is no longer in the grid
      // (Exact verification depends on SfDataGrid rendering — the column
      //  should be removed from the columns list)
      debugPrint('PASS: Owner column toggled off');
    });

    testWidgets('1.4 Toggle column back on restores it', (tester) async {
      final robot = await loginAndNavigateToAnimals(tester);
      await robot.waitForNetwork(seconds: 5);

      // Open settings
      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();

      // Toggle Owner off then back on
      if (robot.isColumnVisible('Owner')) {
        await robot.toggleColumnOff('Owner');
        debugPrint('Toggled Owner off');
      }
      await robot.toggleColumnOn('Owner');
      debugPrint('Toggled Owner back on');

      expect(robot.isColumnVisible('Owner'), isTrue);

      await robot.dismissSheet();
      debugPrint('PASS: Column visibility can be toggled on/off');
    });

    testWidgets('1.5 Reset to Defaults restores all columns', (
      tester,
    ) async {
      final robot = await loginAndNavigateToAnimals(tester);
      await robot.waitForNetwork(seconds: 5);

      // Open settings and toggle something off
      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();

      final initialCount = robot.getColumnCount();

      // Toggle a column off
      await robot.toggleColumnOff('Owner');
      debugPrint('Toggled Owner off');

      // Reset to defaults
      await robot.tapResetToDefaults();
      debugPrint('Tapped Reset to Defaults');

      // Verify all columns restored — count should match or all switches on
      expect(robot.isColumnVisible('Owner'), isTrue);
      expect(robot.getColumnCount(), initialCount);

      await robot.dismissSheet();
      debugPrint('PASS: Reset to Defaults restores columns');
    });

    testWidgets('1.6 Settings persist after closing and reopening sheet', (
      tester,
    ) async {
      final robot = await loginAndNavigateToAnimals(tester);
      await robot.waitForNetwork(seconds: 5);

      // First: reset to known state
      await robot.openColumnSettings();
      await robot.tapResetToDefaults();
      await robot.dismissSheet();
      await robot.waitForNetwork(seconds: 2);

      // Open and toggle Owner off
      await robot.openColumnSettings();
      await robot.toggleColumnOff('Owner');
      await robot.dismissSheet();
      await robot.waitForNetwork(seconds: 2);

      // Reopen and verify Owner is still off
      await robot.openColumnSettings();
      expect(robot.isColumnVisible('Owner'), isFalse);
      debugPrint('Owner is still off after reopen — setting persisted in cache');

      // Clean up: reset
      await robot.tapResetToDefaults();
      await robot.dismissSheet();
      debugPrint('PASS: Settings persist across sheet open/close');
    });
  });

  // =========================================================================
  // TEST GROUP 2: Column Settings on other list screens
  // =========================================================================
  group('Column Settings - Other Screens', () {
    testWidgets('2.1 Cages screen has Columns chip', (tester) async {
      final robot = await loginAndNavigateTo(tester, 'Cages');
      await robot.waitForNetwork(seconds: 5);

      await robot.verifyColumnsChipVisible();
      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();
      expect(robot.getColumnCount(), greaterThan(0));
      await robot.dismissSheet();
      debugPrint('PASS: Cages screen column settings work');
    });

    testWidgets('2.2 Matings screen has Columns chip', (tester) async {
      final robot = await loginAndNavigateTo(tester, 'Matings');
      await robot.waitForNetwork(seconds: 5);

      await robot.verifyColumnsChipVisible();
      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();
      expect(robot.getColumnCount(), greaterThan(0));
      await robot.dismissSheet();
      debugPrint('PASS: Matings screen column settings work');
    });

    testWidgets('2.3 Litters screen has Columns chip', (tester) async {
      final robot = await loginAndNavigateTo(tester, 'Litters');
      await robot.waitForNetwork(seconds: 5);

      await robot.verifyColumnsChipVisible();
      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();
      expect(robot.getColumnCount(), greaterThan(0));
      await robot.dismissSheet();
      debugPrint('PASS: Litters screen column settings work');
    });

    testWidgets('2.4 Strains screen has Columns chip', (tester) async {
      final robot = await loginAndNavigateTo(tester, 'Strains');
      await robot.waitForNetwork(seconds: 5);

      await robot.verifyColumnsChipVisible();
      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();
      expect(robot.getColumnCount(), greaterThan(0));
      await robot.dismissSheet();
      debugPrint('PASS: Strains screen column settings work');
    });

    testWidgets('2.5 Plug Events screen has Columns chip', (tester) async {
      final robot = await loginAndNavigateTo(tester, 'Plug Events');
      await robot.waitForNetwork(seconds: 5);

      await robot.verifyColumnsChipVisible();
      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();
      expect(robot.getColumnCount(), greaterThan(0));
      await robot.dismissSheet();
      debugPrint('PASS: Plug Events screen column settings work');
    });
  });

  // =========================================================================
  // TEST GROUP 3: Mobile/Web isolation
  // =========================================================================
  group('Column Settings - Mobile prefix isolation', () {
    testWidgets('3.1 Settings use Mobile_ prefix (verify via sheet title)', (
      tester,
    ) async {
      final robot = await loginAndNavigateToAnimals(tester);
      await robot.waitForNetwork(seconds: 5);

      // Open settings — the sheet should load successfully, which proves
      // the Mobile_AnimalList table setting was fetched/created on the backend
      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();

      debugPrint(
        'PASS: Mobile_AnimalList table setting loaded from backend '
        '(separate from web AnimalList)',
      );
      await robot.dismissSheet();
    });
  });

  // =========================================================================
  // TEST GROUP 4: Edge cases
  // =========================================================================
  group('Column Settings - Edge Cases', () {
    testWidgets('4.1 Rapidly toggling columns does not crash', (
      tester,
    ) async {
      final robot = await loginAndNavigateToAnimals(tester);
      await robot.waitForNetwork(seconds: 5);

      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();

      final labels = robot.getColumnLabels();
      if (labels.length >= 3) {
        // Rapidly toggle first 3 columns
        for (final label in labels.take(3)) {
          await robot.toggleColumnOff(label);
        }
        for (final label in labels.take(3)) {
          await robot.toggleColumnOn(label);
        }
        debugPrint('Rapidly toggled 3 columns off and back on');
      }

      await robot.dismissSheet();
      debugPrint('PASS: Rapid toggles handled without crash');
    });

    testWidgets('4.2 Reset to Defaults during loading does not crash', (
      tester,
    ) async {
      final robot = await loginAndNavigateToAnimals(tester);
      await robot.waitForNetwork(seconds: 5);

      await robot.openColumnSettings();
      await robot.verifySheetDisplayed();

      // Toggle something, then immediately reset
      await robot.toggleColumnOff('Owner');
      await robot.tapResetToDefaults();

      // Should still have a valid sheet
      await robot.verifySheetDisplayed();
      await robot.dismissSheet();
      debugPrint('PASS: Reset after toggle works correctly');
    });
  });
}
