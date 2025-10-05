import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import '../../test_helpers/test_helpers.dart';
import '../../test_helpers/test_widgets.dart';
import '../../test_helpers/mock_data.dart';

void main() {
  group('TestSelectMating Widget Tests', () {
    testWidgets('should render with basic properties', (
      WidgetTester tester,
    ) async {
      MatingDto? selectedMating;
      MatingDto? changedMating;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectMating(
          selectedMating: selectedMating,
          onChanged: (mating) {
            changedMating = mating;
          },
          label: 'Mating',
          placeholderText: 'Select mating',
        ),
      );

      expect(find.text('Mating'), findsOneWidget);
      expect(find.text('Select mating'), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(InputDecorator), findsOneWidget);
    });

    testWidgets('should display selected mating information', (
      WidgetTester tester,
    ) async {
      final mockMatings = MockDataFactory.createMatingDtoList(2);
      final selectedMating = mockMatings[0];
      MatingDto? changedMating;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectMating(
          selectedMating: selectedMating,
          onChanged: (mating) {
            changedMating = mating;
          },
          label: 'Mating',
          placeholderText: 'Select mating',
          mockMatings: mockMatings,
        ),
      );

      expect(find.text('Mating'), findsOneWidget);
      expect(
        find.text(
          selectedMating.matingTag ?? 'Mating ${selectedMating.matingId}',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Animals: ${selectedMating.animals?.length ?? 0}'),
        findsOneWidget,
      );
    });

    testWidgets('should open dialog when tapped', (WidgetTester tester) async {
      final mockMatings = MockDataFactory.createMatingDtoList(3);
      MatingDto? selectedMating;
      MatingDto? changedMating;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectMating(
          selectedMating: selectedMating,
          onChanged: (mating) {
            changedMating = mating;
          },
          label: 'Mating',
          placeholderText: 'Select mating',
          mockMatings: mockMatings,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Select Mating'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('should show Clear and Cancel buttons in dialog', (
      WidgetTester tester,
    ) async {
      final mockMatings = MockDataFactory.createMatingDtoList(2);
      MatingDto? selectedMating;
      MatingDto? changedMating;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectMating(
          selectedMating: selectedMating,
          onChanged: (mating) {
            changedMating = mating;
          },
          label: 'Mating',
          placeholderText: 'Select mating',
          mockMatings: mockMatings,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should close dialog when Cancel is tapped', (
      WidgetTester tester,
    ) async {
      final mockMatings = MockDataFactory.createMatingDtoList(2);
      MatingDto? selectedMating;
      MatingDto? changedMating;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectMating(
          selectedMating: selectedMating,
          onChanged: (mating) {
            changedMating = mating;
          },
          label: 'Mating',
          placeholderText: 'Select mating',
          mockMatings: mockMatings,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should call onChanged when mating is selected', (
      WidgetTester tester,
    ) async {
      final mockMatings = MockDataFactory.createMatingDtoList(3);
      MatingDto? selectedMating;
      MatingDto? changedMating;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectMating(
          selectedMating: selectedMating,
          onChanged: (mating) {
            changedMating = mating;
          },
          label: 'Mating',
          placeholderText: 'Select mating',
          mockMatings: mockMatings,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Select first mating
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      expect(changedMating, isNotNull);
      expect(changedMating!.matingUuid, equals(mockMatings[0].matingUuid));
    });

    testWidgets('should call onChanged with null when Clear is tapped', (
      WidgetTester tester,
    ) async {
      final mockMatings = MockDataFactory.createMatingDtoList(2);
      final selectedMating = mockMatings[0];
      MatingDto? changedMating;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectMating(
          selectedMating: selectedMating,
          onChanged: (mating) {
            changedMating = mating;
          },
          label: 'Mating',
          placeholderText: 'Select mating',
          mockMatings: mockMatings,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Tap Clear
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(changedMating, isNull);
    });

    testWidgets('should show check icon for selected mating in dialog', (
      WidgetTester tester,
    ) async {
      final mockMatings = MockDataFactory.createMatingDtoList(3);
      final selectedMating = mockMatings[1]; // Select second mating
      MatingDto? changedMating;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectMating(
          selectedMating: selectedMating,
          onChanged: (mating) {
            changedMating = mating;
          },
          label: 'Mating',
          placeholderText: 'Select mating',
          mockMatings: mockMatings,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should handle disabled state correctly', (
      WidgetTester tester,
    ) async {
      final mockMatings = MockDataFactory.createMatingDtoList(2);
      MatingDto? selectedMating;
      MatingDto? changedMating;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectMating(
          selectedMating: selectedMating,
          onChanged: (mating) {
            changedMating = mating;
          },
          label: 'Mating',
          placeholderText: 'Select mating',
          disabled: true,
          mockMatings: mockMatings,
        ),
      );

      // Try to tap the disabled widget
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Dialog should not open
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should handle empty mating list gracefully', (
      WidgetTester tester,
    ) async {
      MatingDto? selectedMating;
      MatingDto? changedMating;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectMating(
          selectedMating: selectedMating,
          onChanged: (mating) {
            changedMating = mating;
          },
          label: 'Mating',
          placeholderText: 'Select mating',
          mockMatings: [],
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });
  });
}
