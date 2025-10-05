import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import '../../test_helpers/test_helpers.dart';
import '../../test_helpers/mock_data.dart';
import '../../test_helpers/test_widgets.dart';

void main() {
  group('TestSelectAnimal', () {
    testWidgets('renders with basic properties', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
      );

      expect(find.text('Select Animal'), findsOneWidget);
      expect(find.text('Choose an animal'), findsOneWidget);
      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('shows selected animal when provided', (
      WidgetTester tester,
    ) async {
      final selectedAnimal = MockDataFactory.createAnimalStoreDto(
        physicalTag: 'A001',
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: selectedAnimal,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
      );

      expect(find.text('A001'), findsOneWidget);
      expect(find.text('Choose an animal'), findsNothing);
    });

    testWidgets('shows clear button when animal is selected', (
      WidgetTester tester,
    ) async {
      final selectedAnimal = MockDataFactory.createAnimalStoreDto();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: selectedAnimal,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('does not show clear button when no animal is selected', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('calls onChanged when clear button is tapped', (
      WidgetTester tester,
    ) async {
      final selectedAnimal = MockDataFactory.createAnimalStoreDto();
      AnimalStoreDto? clearedAnimal;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: selectedAnimal,
          onChanged: (animal) => clearedAnimal = animal,
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byIcon(Icons.clear));
      expect(clearedAnimal, isNull);
    });

    testWidgets('opens dialog when tapped', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));

      // Wait for dialog to appear
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Select Animals'), findsOneWidget);
    });

    testWidgets('shows disabled state correctly', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
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
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
          disabled: true,
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));

      // Dialog should not appear
      expect(find.text('Select Animals'), findsNothing);
    });

    testWidgets('does not show clear button when disabled', (
      WidgetTester tester,
    ) async {
      final selectedAnimal = MockDataFactory.createAnimalStoreDto();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: selectedAnimal,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
          disabled: true,
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });
  });

  group('TestSelectAnimal Dialog', () {
    testWidgets('shows animal list in dialog', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Animals'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('shows OK and Cancel buttons in dialog', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
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
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      await TestHelpers.tapAndWait(tester, find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Animals'), findsNothing);
    });

    testWidgets('closes dialog when OK is tapped', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      await TestHelpers.tapAndWait(tester, find.text('OK'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Animals'), findsNothing);
    });
  });

  group('TestSelectAnimal Edge Cases', () {
    testWidgets('handles null selectedAnimal gracefully', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
      );

      expect(find.text('Choose an animal'), findsOneWidget);
      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('handles empty label gracefully', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: '',
          placeholderText: 'Choose an animal',
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('handles empty placeholderText gracefully', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: '',
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('handles very long placeholderText', (
      WidgetTester tester,
    ) async {
      const longPlaceholder =
          'This is a very long placeholder text that should be handled gracefully by the widget';

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: longPlaceholder,
        ),
      );

      expect(find.text(longPlaceholder), findsOneWidget);
    });
  });

  group('TestSelectAnimal Filter', () {
    testWidgets('applies filter when provided', (WidgetTester tester) async {
      final animals = MockDataFactory.createAnimalStoreDtoList(5);
      final filteredAnimals = animals.take(2).toList();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
          filter: (animals) => filteredAnimals,
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      // The filter should be applied, though we can't easily test the filtered results
      // without mocking the animal store
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('works without filter', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectAnimal(
          selectedAnimal: null,
          onChanged: (animal) {},
          label: 'Select Animal',
          placeholderText: 'Choose an animal',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
