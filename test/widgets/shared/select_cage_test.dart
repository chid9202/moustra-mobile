import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import '../../test_helpers/test_helpers.dart';
import '../../test_helpers/mock_data.dart';
import '../../test_helpers/test_widgets.dart';

void main() {
  group('TestSelectCage', () {
    testWidgets('renders with basic properties', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: null, onChanged: (cage) {}),
      );

      expect(find.text('Cages'), findsOneWidget);
      expect(find.text('Select cage'), findsOneWidget);
      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('renders with custom label', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(
          selectedCage: null,
          onChanged: (cage) {},
          label: 'Custom Cage Label',
        ),
      );

      expect(find.text('Custom Cage Label'), findsOneWidget);
      expect(find.text('Select cage'), findsOneWidget);
    });

    testWidgets('shows selected cage when provided', (
      WidgetTester tester,
    ) async {
      final selectedCage = MockDataFactory.createCageStoreDto(cageTag: 'C001');

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: selectedCage, onChanged: (cage) {}),
      );

      expect(find.text('C001'), findsOneWidget);
      expect(find.text('Select cage'), findsNothing);
    });

    testWidgets('shows clear button when cage is selected', (
      WidgetTester tester,
    ) async {
      final selectedCage = MockDataFactory.createCageStoreDto();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: selectedCage, onChanged: (cage) {}),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('does not show clear button when no cage is selected', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: null, onChanged: (cage) {}),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('calls onChanged when clear button is tapped', (
      WidgetTester tester,
    ) async {
      final selectedCage = MockDataFactory.createCageStoreDto();
      CageStoreDto? clearedCage;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(
          selectedCage: selectedCage,
          onChanged: (cage) => clearedCage = cage,
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byIcon(Icons.clear));
      expect(clearedCage, isNull);
    });

    testWidgets('opens dialog when tapped', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: null, onChanged: (cage) {}),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));

      // Wait for dialog to appear
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Select Cages'), findsOneWidget);
    });

    testWidgets('shows disabled state correctly', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(
          selectedCage: null,
          onChanged: (cage) {},
          disabled: true,
        ),
      );

      final inkWell = TestHelpers.findWidget<InkWell>(tester);
      expect(inkWell.onTap, isNull);
    });

    testWidgets('does not open dialog when disabled', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(
          selectedCage: null,
          onChanged: (cage) {},
          disabled: true,
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));

      // Dialog should not appear
      expect(find.text('Select Cages'), findsNothing);
    });

    testWidgets('does not show clear button when disabled', (
      WidgetTester tester,
    ) async {
      final selectedCage = MockDataFactory.createCageStoreDto();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(
          selectedCage: selectedCage,
          onChanged: (cage) {},
          disabled: true,
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });
  });

  group('TestSelectCage Dialog', () {
    testWidgets('shows cage list in dialog', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: null, onChanged: (cage) {}),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Cages'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('shows OK and Cancel buttons in dialog', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: null, onChanged: (cage) {}),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('closes dialog when Cancel is tapped', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: null, onChanged: (cage) {}),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      await TestHelpers.tapAndWait(tester, find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Cages'), findsNothing);
    });

    testWidgets('closes dialog when OK is tapped', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: null, onChanged: (cage) {}),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      await TestHelpers.tapAndWait(tester, find.text('OK'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Cages'), findsNothing);
    });
  });

  group('TestSelectCage Edge Cases', () {
    testWidgets('handles null selectedCage gracefully', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: null, onChanged: (cage) {}),
      );

      expect(find.text('Select cage'), findsOneWidget);
      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('handles null label gracefully', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: null, onChanged: (cage) {}, label: null),
      );

      expect(find.text('Cages'), findsOneWidget); // Default label
      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('handles cage with null cageTag', (WidgetTester tester) async {
      final selectedCage = MockDataFactory.createCageStoreDto(cageTag: null);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: selectedCage, onChanged: (cage) {}),
      );

      expect(find.text('N/A'), findsOneWidget);
    });

    testWidgets('handles very long cageTag', (WidgetTester tester) async {
      const longCageTag =
          'This is a very long cage tag that should be handled gracefully';
      final selectedCage = MockDataFactory.createCageStoreDto(
        cageTag: longCageTag,
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(selectedCage: selectedCage, onChanged: (cage) {}),
      );

      expect(find.text(longCageTag), findsOneWidget);
    });
  });

  group('TestSelectCage Accessibility', () {
    testWidgets('has proper semantics for disabled state', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(
          selectedCage: null,
          onChanged: (cage) {},
          disabled: true,
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
      // Additional accessibility tests can be added here
    });

    testWidgets('has proper semantics for enabled state', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectCage(
          selectedCage: null,
          onChanged: (cage) {},
          disabled: false,
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });
  });
}
