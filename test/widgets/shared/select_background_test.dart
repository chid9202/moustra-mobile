import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';
import '../../test_helpers/test_helpers.dart';
import '../../test_helpers/test_widgets.dart';
import '../../test_helpers/mock_data.dart';

void main() {
  group('TestSelectBackground Widget Tests', () {
    testWidgets('should render with basic properties', (
      WidgetTester tester,
    ) async {
      List<BackgroundStoreDto> selectedBackgrounds = [];
      List<BackgroundStoreDto>? changedBackgrounds;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectBackground(
          selectedBackgrounds: selectedBackgrounds,
          onChanged: (backgrounds) {
            changedBackgrounds = backgrounds;
          },
        ),
      );

      expect(find.text('Backgrounds'), findsOneWidget);
      expect(find.text('Select backgrounds'), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('should show selected backgrounds as chips', (
      WidgetTester tester,
    ) async {
      final mockBackgrounds = MockDataFactory.createBackgroundStoreDtoList(2);
      List<BackgroundStoreDto> selectedBackgrounds = [mockBackgrounds[0]];
      List<BackgroundStoreDto>? changedBackgrounds;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectBackground(
          selectedBackgrounds: selectedBackgrounds,
          onChanged: (backgrounds) {
            changedBackgrounds = backgrounds;
          },
          mockBackgrounds: mockBackgrounds,
        ),
      );

      expect(find.text('Backgrounds'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text(mockBackgrounds[0].name), findsOneWidget);
    });

    testWidgets('should open dialog when tapped', (WidgetTester tester) async {
      final mockBackgrounds = MockDataFactory.createBackgroundStoreDtoList(3);
      List<BackgroundStoreDto> selectedBackgrounds = [];
      List<BackgroundStoreDto>? changedBackgrounds;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectBackground(
          selectedBackgrounds: selectedBackgrounds,
          onChanged: (backgrounds) {
            changedBackgrounds = backgrounds;
          },
          mockBackgrounds: mockBackgrounds,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Select Backgrounds'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
    });

    testWidgets('should show OK and Cancel buttons in dialog', (
      WidgetTester tester,
    ) async {
      final mockBackgrounds = MockDataFactory.createBackgroundStoreDtoList(2);
      List<BackgroundStoreDto> selectedBackgrounds = [];
      List<BackgroundStoreDto>? changedBackgrounds;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectBackground(
          selectedBackgrounds: selectedBackgrounds,
          onChanged: (backgrounds) {
            changedBackgrounds = backgrounds;
          },
          mockBackgrounds: mockBackgrounds,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should close dialog when Cancel is tapped', (
      WidgetTester tester,
    ) async {
      final mockBackgrounds = MockDataFactory.createBackgroundStoreDtoList(2);
      List<BackgroundStoreDto> selectedBackgrounds = [];
      List<BackgroundStoreDto>? changedBackgrounds;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectBackground(
          selectedBackgrounds: selectedBackgrounds,
          onChanged: (backgrounds) {
            changedBackgrounds = backgrounds;
          },
          mockBackgrounds: mockBackgrounds,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
      'should call onChanged when background is selected and OK is tapped',
      (WidgetTester tester) async {
        final mockBackgrounds = MockDataFactory.createBackgroundStoreDtoList(3);
        List<BackgroundStoreDto> selectedBackgrounds = [];
        List<BackgroundStoreDto>? changedBackgrounds;

        await TestHelpers.pumpWidgetWithTheme(
          tester,
          TestSelectBackground(
            selectedBackgrounds: selectedBackgrounds,
            onChanged: (backgrounds) {
              changedBackgrounds = backgrounds;
            },
            mockBackgrounds: mockBackgrounds,
          ),
        );

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        // Select first background
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.pumpAndSettle();

        // Tap OK
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(changedBackgrounds, isNotNull);
        expect(changedBackgrounds!.length, equals(1));
        expect(changedBackgrounds![0].uuid, equals(mockBackgrounds[0].uuid));
      },
    );

    testWidgets('should allow multiple background selection', (
      WidgetTester tester,
    ) async {
      final mockBackgrounds = MockDataFactory.createBackgroundStoreDtoList(3);
      List<BackgroundStoreDto> selectedBackgrounds = [];
      List<BackgroundStoreDto>? changedBackgrounds;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectBackground(
          selectedBackgrounds: selectedBackgrounds,
          onChanged: (backgrounds) {
            changedBackgrounds = backgrounds;
          },
          mockBackgrounds: mockBackgrounds,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Select first two backgrounds
      await tester.tap(find.byType(CheckboxListTile).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile).at(1));
      await tester.pumpAndSettle();

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(changedBackgrounds, isNotNull);
      expect(changedBackgrounds!.length, equals(2));
    });

    testWidgets('should remove background when chip is deleted', (
      WidgetTester tester,
    ) async {
      final mockBackgrounds = MockDataFactory.createBackgroundStoreDtoList(2);
      List<BackgroundStoreDto> selectedBackgrounds = [
        mockBackgrounds[0],
        mockBackgrounds[1],
      ];
      List<BackgroundStoreDto>? changedBackgrounds;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectBackground(
          selectedBackgrounds: selectedBackgrounds,
          onChanged: (backgrounds) {
            changedBackgrounds = backgrounds;
          },
          mockBackgrounds: mockBackgrounds,
        ),
      );

      expect(find.byType(Chip), findsNWidgets(2));

      // Delete first chip by tapping the delete icon
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(changedBackgrounds, isNotNull);
      expect(changedBackgrounds!.length, equals(1));
      expect(changedBackgrounds![0].uuid, equals(mockBackgrounds[1].uuid));
    });

    testWidgets('should show Add Background button in dialog', (
      WidgetTester tester,
    ) async {
      final mockBackgrounds = MockDataFactory.createBackgroundStoreDtoList(2);
      List<BackgroundStoreDto> selectedBackgrounds = [];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectBackground(
          selectedBackgrounds: selectedBackgrounds,
          onChanged: (backgrounds) {},
          mockBackgrounds: mockBackgrounds,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('Add Background'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should open Add Background dialog and create new background', (
      WidgetTester tester,
    ) async {
      final mockBackgrounds = MockDataFactory.createBackgroundStoreDtoList(2);
      List<BackgroundStoreDto> selectedBackgrounds = [];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectBackground(
          selectedBackgrounds: selectedBackgrounds,
          onChanged: (backgrounds) {},
          mockBackgrounds: mockBackgrounds,
        ),
      );

      // Open the background picker dialog
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Tap Add Background button
      await tester.tap(find.text('Add Background'));
      await tester.pumpAndSettle();

      // Should show the Add Background sub-dialog
      expect(find.text('Background Name'), findsOneWidget);

      // Enter a name
      await tester.enterText(find.byType(TextField), 'New BG');
      await tester.pumpAndSettle();

      // Tap Add
      await tester.tap(find.text('Add').last);
      await tester.pumpAndSettle();

      // Should now show 3 checkboxes (2 original + 1 new)
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
      expect(find.text('New BG'), findsOneWidget);
    });

    testWidgets('should handle empty background list gracefully', (
      WidgetTester tester,
    ) async {
      List<BackgroundStoreDto> selectedBackgrounds = [];
      List<BackgroundStoreDto>? changedBackgrounds;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectBackground(
          selectedBackgrounds: selectedBackgrounds,
          onChanged: (backgrounds) {
            changedBackgrounds = backgrounds;
          },
          mockBackgrounds: [],
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNothing);
    });
  });
}
