import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/shared/select_sex.dart';
import 'package:moustra/constants/animal_constants.dart';
import '../../test_helpers/test_helpers.dart';

void main() {
  group('SelectSex Widget Tests', () {
    testWidgets('should render with default state', (
      WidgetTester tester,
    ) async {
      String? selectedSex;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectSex(
          selectedSex: selectedSex,
          onChanged: (value) => selectedSex = value,
        ),
      );

      expect(find.text('Sex'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('should display selected sex value', (
      WidgetTester tester,
    ) async {
      String? selectedSex = SexConstants.male;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectSex(
          selectedSex: selectedSex,
          onChanged: (value) => selectedSex = value,
        ),
      );

      expect(find.text('Sex'), findsOneWidget);
      expect(find.text(SexConstants.male), findsOneWidget);
    });

    testWidgets('should show clear button when sex is selected', (
      WidgetTester tester,
    ) async {
      String? selectedSex = SexConstants.female;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectSex(
          selectedSex: selectedSex,
          onChanged: (value) => selectedSex = value,
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byTooltip('Clear selection'), findsOneWidget);
    });

    testWidgets('should not show clear button when no sex is selected', (
      WidgetTester tester,
    ) async {
      String? selectedSex;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectSex(
          selectedSex: selectedSex,
          onChanged: (value) => selectedSex = value,
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('should call onChanged when sex is selected', (
      WidgetTester tester,
    ) async {
      String? selectedSex;
      String? changedValue;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectSex(
          selectedSex: selectedSex,
          onChanged: (value) => changedValue = value,
        ),
      );

      // Tap the dropdown
      await TestHelpers.tapAndWait(
        tester,
        find.byType(DropdownButtonFormField<String>),
      );
      await tester.pumpAndSettle();

      // Select male
      await TestHelpers.tapAndWait(tester, find.text(SexConstants.male));
      await tester.pumpAndSettle();

      expect(changedValue, equals(SexConstants.male));
    });

    testWidgets('should call onChanged with null when clear button is tapped', (
      WidgetTester tester,
    ) async {
      String? selectedSex = SexConstants.male;
      String? changedValue;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectSex(
          selectedSex: selectedSex,
          onChanged: (value) => changedValue = value,
        ),
      );

      // Tap the clear button
      await TestHelpers.tapAndWait(tester, find.byIcon(Icons.clear));

      expect(changedValue, isNull);
    });

    testWidgets('should have all sex options available', (
      WidgetTester tester,
    ) async {
      String? selectedSex;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectSex(
          selectedSex: selectedSex,
          onChanged: (value) => selectedSex = value,
        ),
      );

      // Tap the dropdown
      await TestHelpers.tapAndWait(
        tester,
        find.byType(DropdownButtonFormField<String>),
      );
      await tester.pumpAndSettle();

      // Check that all sex options are available
      expect(find.text(SexConstants.male), findsOneWidget);
      expect(find.text(SexConstants.female), findsOneWidget);
      expect(find.text(SexConstants.unknown), findsOneWidget);
    });

    testWidgets('should handle sex selection changes correctly', (
      WidgetTester tester,
    ) async {
      String? selectedSex = SexConstants.male; // Start with a selected value
      List<String?> changes = [];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectSex(
          selectedSex: selectedSex,
          onChanged: (value) {
            selectedSex = value;
            changes.add(value);
          },
        ),
      );

      // Clear selection using the clear button
      await TestHelpers.tapAndWait(tester, find.byIcon(Icons.clear));

      // Select female
      await TestHelpers.tapAndWait(
        tester,
        find.byType(DropdownButtonFormField<String>),
      );
      await tester.pumpAndSettle();
      await TestHelpers.tapAndWait(tester, find.text(SexConstants.female));
      await tester.pumpAndSettle();

      // Select male
      await TestHelpers.tapAndWait(
        tester,
        find.byType(DropdownButtonFormField<String>),
      );
      await tester.pumpAndSettle();
      await TestHelpers.tapAndWait(tester, find.text(SexConstants.male));
      await tester.pumpAndSettle();

      expect(changes, equals([null, SexConstants.female, SexConstants.male]));
    });
  });
}
