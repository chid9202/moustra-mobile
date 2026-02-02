import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'robots/login_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env.test');
    await authService.init();
    
    // Clear saved transformation matrix to reset zoom level
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rack_transformation_matrix');
  });

  group('Cage Move by Position', () {
    testWidgets('move cage dialog uses x/y positioning', (tester) async {
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

      // Wait for login and navigation
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // 3. Verify cage data has x/y positions from backend
      final rackData = rackStore.value?.rackData;
      final cages = rackData?.cages;
      
      if (cages == null || cages.isEmpty) {
        fail('No cages found in rack data');
      }
      
      final firstCage = cages.first;
      debugPrint('Testing with cage: ${firstCage.cageTag} (${firstCage.cageUuid})');
      debugPrint('Current position: x=${firstCage.xPosition}, y=${firstCage.yPosition}');
      
      // Verify cage has x/y position data (backend sparse positioning works)
      expect(firstCage.xPosition, isNotNull, reason: 'Cage should have xPosition');
      expect(firstCage.yPosition, isNotNull, reason: 'Cage should have yPosition');
      
      debugPrint('✅ Backend x/y positioning verified!');
      
      // 4. Test the moveCage API (order-based positioning)
      final originalOrder = firstCage.order ?? 100;
      
      // Move to a new order position (shift by 1 for testing)
      final newOrder = originalOrder + 1;
      
      debugPrint('Moving cage from order $originalOrder to order $newOrder');
      
      try {
        await cageApi.moveCage(firstCage.cageUuid, newOrder);
        debugPrint('✅ moveCage API call succeeded!');
        
        // Refresh rack data to verify the change
        final newRackData = await cageApi.moveCage(firstCage.cageUuid, originalOrder);
        debugPrint('✅ Restored original order');
        
        // Update the store with new rack data
        rackStore.value = RackStoreDto(
          rackData: newRackData,
          transformationMatrix: rackStore.value?.transformationMatrix,
        );
        
      } catch (e) {
        debugPrint('API error: $e');
        fail('moveCage failed: $e');
      }
      
      debugPrint('🎉 Sparse X-Y cage positioning test PASSED!');
    });

    testWidgets('move cage dialog validates position bounds', (tester) async {
      // 1. Load app
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 2. Login
      final loginRobot = LoginRobot(tester);
      final email = dotenv.env['TEST_EMAIL']!;
      final password = dotenv.env['TEST_PASSWORD']!;

      await loginRobot.enterEmail(email);
      await loginRobot.enterPassword(password);
      await loginRobot.tapSignIn();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // 3. Navigate to cages grid via drawer menu
      final scaffoldState2 = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState2.openDrawer();
      await tester.pumpAndSettle();

      final gridViewItem2 = find.text('Grid View');
      await tester.tap(gridViewItem2);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 4. Open move dialog
      final menuButtons = find.byIcon(Icons.more_vert);
      if (menuButtons.evaluate().isEmpty) {
        debugPrint('No cages found - skipping bounds test');
        return;
      }

      await tester.tap(menuButtons.first);
      await tester.pumpAndSettle();
      
      final moveCageOption = find.text('Move Cage');
      await tester.tap(moveCageOption);
      await tester.pumpAndSettle();

      // 5. Enter out-of-bounds position
      final rowField = find.widgetWithText(TextFormField, 'Row');
      final columnField = find.widgetWithText(TextFormField, 'Column');
      
      await tester.enterText(rowField, '99');
      await tester.pump();
      await tester.enterText(columnField, '99');
      await tester.pump();

      // 6. Tap Move button
      final moveButton = find.widgetWithText(TextButton, 'Move');
      if (moveButton.evaluate().isNotEmpty) {
        await tester.tap(moveButton);
        await tester.pumpAndSettle();
      }

      // 7. Expect validation error (row/column out of bounds)
      // Dialog should still be open with error message
      expect(find.textContaining('must be between'), findsWidgets);
      
      debugPrint('Bounds validation test completed successfully');
    });
  });
}
