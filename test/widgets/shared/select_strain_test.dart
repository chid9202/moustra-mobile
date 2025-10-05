import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import '../../test_helpers/test_helpers.dart';
import '../../test_helpers/mock_data.dart';
import '../../test_helpers/test_widgets.dart';

void main() {
  group('SelectStrain Widget Tests', () {
    testWidgets('should render with default state', (
      WidgetTester tester,
    ) async {
      StrainStoreDto? selectedStrain;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectStrain(
          selectedStrain: selectedStrain,
          onChanged: (value) => selectedStrain = value,
          label: 'Strains',
          mockStrains: MockDataFactory.createStrainStoreDtoList(3),
        ),
      );

      expect(find.text('Strains'), findsOneWidget);
      expect(find.text('Select strain'), findsOneWidget);
    });

    testWidgets('should display selected strain name', (
      WidgetTester tester,
    ) async {
      final strains = MockDataFactory.createStrainStoreDtoList(3);
      final selectedStrain = strains.first;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectStrain(
          selectedStrain: selectedStrain,
          onChanged: (value) {},
          label: 'Strains',
          mockStrains: strains,
        ),
      );

      expect(find.text('Strains'), findsOneWidget);
      expect(find.text(selectedStrain.strainName), findsOneWidget);
    });

    testWidgets('should show clear button when strain is selected', (
      WidgetTester tester,
    ) async {
      final strains = MockDataFactory.createStrainStoreDtoList(3);
      final selectedStrain = strains.first;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectStrain(
          selectedStrain: selectedStrain,
          onChanged: (value) {},
          label: 'Strains',
          mockStrains: strains,
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byTooltip('Clear selection'), findsOneWidget);
    });

    testWidgets('should not show clear button when no strain is selected', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectStrain(
          selectedStrain: null,
          onChanged: (value) {},
          label: 'Strains',
          mockStrains: MockDataFactory.createStrainStoreDtoList(3),
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('should open dialog when tapped', (WidgetTester tester) async {
      final strains = MockDataFactory.createStrainStoreDtoList(3);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectStrain(
          selectedStrain: null,
          onChanged: (value) {},
          label: 'Strains',
          mockStrains: strains,
        ),
      );

      // Tap the widget to open dialog
      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('Select Strains'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should display strain options in dialog', (
      WidgetTester tester,
    ) async {
      final strains = MockDataFactory.createStrainStoreDtoList(3);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectStrain(
          selectedStrain: null,
          onChanged: (value) {},
          label: 'Strains',
          mockStrains: strains,
        ),
      );

      // Open dialog
      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pumpAndSettle();

      // Check that strain options are displayed
      for (final strain in strains) {
        expect(find.text(strain.strainName), findsOneWidget);
      }
    });

    testWidgets('should call onChanged when strain is selected', (
      WidgetTester tester,
    ) async {
      final strains = MockDataFactory.createStrainStoreDtoList(3);
      StrainStoreDto? selectedStrain;
      StrainStoreDto? changedValue;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectStrain(
          selectedStrain: selectedStrain,
          onChanged: (value) => changedValue = value,
          label: 'Strains',
          mockStrains: strains,
        ),
      );

      // Open dialog
      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pumpAndSettle();

      // Select first strain
      await TestHelpers.tapAndWait(
        tester,
        find.byType(RadioListTile<StrainStoreDto?>).first,
      );
      await tester.pumpAndSettle();

      // Tap OK button
      await TestHelpers.tapAndWait(tester, find.text('OK'));
      await tester.pumpAndSettle();

      expect(changedValue, equals(strains.first));
    });

    testWidgets('should call onChanged with null when clear button is tapped', (
      WidgetTester tester,
    ) async {
      final strains = MockDataFactory.createStrainStoreDtoList(3);
      final selectedStrain = strains.first;
      StrainStoreDto? changedValue;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectStrain(
          selectedStrain: selectedStrain,
          onChanged: (value) => changedValue = value,
          label: 'Strains',
          mockStrains: strains,
        ),
      );

      // Tap the clear button
      await TestHelpers.tapAndWait(tester, find.byIcon(Icons.clear));

      expect(changedValue, isNull);
    });

    testWidgets('should cancel dialog without changes', (
      WidgetTester tester,
    ) async {
      final strains = MockDataFactory.createStrainStoreDtoList(3);
      StrainStoreDto? selectedStrain;
      StrainStoreDto? changedValue;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectStrain(
          selectedStrain: selectedStrain,
          onChanged: (value) => changedValue = value,
          label: 'Strains',
          mockStrains: strains,
        ),
      );

      // Open dialog
      await TestHelpers.tapAndWait(tester, find.byType(InkWell));
      await tester.pumpAndSettle();

      // Select a strain
      await TestHelpers.tapAndWait(
        tester,
        find.byType(RadioListTile<StrainStoreDto?>).first,
      );
      await tester.pumpAndSettle();

      // Tap Cancel button
      await TestHelpers.tapAndWait(tester, find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should not have changed the value
      expect(changedValue, isNull);
    });

    testWidgets('should use default label when not provided', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        TestSelectStrain(
          selectedStrain: null,
          onChanged: (value) {},
          label: null,
          mockStrains: MockDataFactory.createStrainStoreDtoList(3),
        ),
      );

      expect(find.text('Strains'), findsOneWidget);
    });
  });
}
