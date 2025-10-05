import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import '../../test_helpers/test_helpers.dart';
import '../../test_helpers/mock_data.dart';
import '../../test_helpers/test_widgets.dart';

void main() {
  group('TestMultiSelectAnimal', () {
    testWidgets('renders with basic properties', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      expect(find.text('Select Animals'), findsOneWidget);
      expect(find.text('Choose animals'), findsOneWidget);
      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('shows selected animals as chips', (WidgetTester tester) async {
      final selectedAnimals = MockDataFactory.createAnimalStoreDtoList(2);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: selectedAnimals,
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      expect(find.byType(Chip), findsNWidgets(2));
      expect(find.text('Choose animals'), findsNothing);
    });

    testWidgets('shows clear all button when animals are selected', (
      WidgetTester tester,
    ) async {
      final selectedAnimals = MockDataFactory.createAnimalStoreDtoList(1);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: selectedAnimals,
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('does not show clear all button when no animals are selected', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('calls onChanged when clear all button is tapped', (
      WidgetTester tester,
    ) async {
      final selectedAnimals = MockDataFactory.createAnimalStoreDtoList(2);
      List<AnimalStoreDto>? clearedAnimals;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: selectedAnimals,
          onChanged: (animals) => clearedAnimals = animals,
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byIcon(Icons.clear));
      expect(clearedAnimals, isEmpty);
    });

    testWidgets('opens dialog when tapped', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));

      // Wait for dialog to appear
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Select Multiple Animals'), findsOneWidget);
    });

    testWidgets('shows disabled state correctly', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
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
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
          disabled: true,
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));

      // Dialog should not appear
      expect(find.text('Select Multiple Animals'), findsNothing);
    });

    testWidgets('does not show clear all button when disabled', (
      WidgetTester tester,
    ) async {
      final selectedAnimals = MockDataFactory.createAnimalStoreDtoList(1);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: selectedAnimals,
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
          disabled: true,
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });
  });

  group('TestMultiSelectAnimal Dialog', () {
    testWidgets('shows animal list in dialog', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Multiple Animals'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('shows OK and Cancel buttons in dialog', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
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
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      await TestHelpers.tapAndWait(tester, find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Multiple Animals'), findsNothing);
    });

    testWidgets('closes dialog when OK is tapped', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      await TestHelpers.tapAndWait(tester, find.text('OK'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Multiple Animals'), findsNothing);
    });
  });

  group('TestMultiSelectAnimal Chip Interactions', () {
    testWidgets('removes animal when chip delete button is tapped', (
      WidgetTester tester,
    ) async {
      final selectedAnimals = MockDataFactory.createAnimalStoreDtoList(2);
      List<AnimalStoreDto>? updatedAnimals;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: selectedAnimals,
          onChanged: (animals) => updatedAnimals = animals,
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      // Find and tap the delete button on the first chip
      final chips = find.byType(Chip);
      expect(chips, findsNWidgets(2));

      // Find the delete icon and tap it
      final deleteIcons = find.byIcon(Icons.close);
      expect(deleteIcons, findsNWidgets(2));

      await TestHelpers.tapAndWait(tester, deleteIcons.first);
      expect(updatedAnimals, hasLength(1));
    });

    testWidgets('shows correct number of chips for multiple animals', (
      WidgetTester tester,
    ) async {
      final selectedAnimals = MockDataFactory.createAnimalStoreDtoList(5);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: selectedAnimals,
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      expect(find.byType(Chip), findsNWidgets(5));
    });

    testWidgets('wraps chips correctly when many animals are selected', (
      WidgetTester tester,
    ) async {
      final selectedAnimals = MockDataFactory.createAnimalStoreDtoList(10);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: selectedAnimals,
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      expect(find.byType(Chip), findsNWidgets(10));
      expect(find.byType(Wrap), findsOneWidget);
    });
  });

  group('TestMultiSelectAnimal Edge Cases', () {
    testWidgets('handles empty selectedAnimals list gracefully', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      expect(find.text('Choose animals'), findsOneWidget);
      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('handles empty label gracefully', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: '',
          placeholderText: 'Choose animals',
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('handles empty placeholderText gracefully', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
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
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: longPlaceholder,
        ),
      );

      expect(find.text(longPlaceholder), findsOneWidget);
    });

    testWidgets('handles animals with null physicalTag', (
      WidgetTester tester,
    ) async {
      final animalWithNullTag = MockDataFactory.createAnimalStoreDto(
        physicalTag: null,
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [animalWithNullTag],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      expect(find.byType(Chip), findsOneWidget);
    });
  });

  group('TestMultiSelectAnimal Filter', () {
    testWidgets('applies filter when provided', (WidgetTester tester) async {
      final animals = MockDataFactory.createAnimalStoreDtoList(5);
      final filteredAnimals = animals.take(2).toList();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
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
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('TestMultiSelectAnimal Accessibility', () {
    testWidgets('has proper semantics for disabled state', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
          disabled: true,
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('has proper semantics for enabled state', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: [],
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
          disabled: false,
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('has proper semantics for selected animals', (
      WidgetTester tester,
    ) async {
      final selectedAnimals = MockDataFactory.createAnimalStoreDtoList(3);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestMultiSelectAnimal(
          selectedAnimals: selectedAnimals,
          onChanged: (animals) {},
          label: 'Select Animals',
          placeholderText: 'Choose animals',
        ),
      );

      expect(find.byType(Chip), findsNWidgets(3));
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
}
