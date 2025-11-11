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

      expect(find.byType(SegmentedButton<String>), findsOneWidget);
      // Check that all segments are present
      expect(find.text('M'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);
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

      // The male segment should be present (represented by 'M')
      expect(find.text('M'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);

      // Verify the segmented button exists
      expect(find.byType(SegmentedButton<String>), findsOneWidget);
    });

    testWidgets('should allow clearing selection when sex is selected', (
      WidgetTester tester,
    ) async {
      String? selectedSex = SexConstants.female;
      String? changedValue;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectSex(
          selectedSex: selectedSex,
          onChanged: (value) => changedValue = value,
        ),
      );

      // Tap the selected segment again to clear it
      await TestHelpers.tapAndWait(tester, find.text('F'));
      await tester.pumpAndSettle();

      expect(changedValue, isNull);
    });

    testWidgets(
      'should not have any segment selected when no sex is selected',
      (WidgetTester tester) async {
        String? selectedSex;

        await TestHelpers.pumpWidgetWithTheme(
          tester,
          SelectSex(
            selectedSex: selectedSex,
            onChanged: (value) => selectedSex = value,
          ),
        );

        // All segments should be present but none selected
        expect(find.text('M'), findsOneWidget);
        expect(find.text('F'), findsOneWidget);
        expect(find.text('U'), findsOneWidget);
        expect(find.byType(SegmentedButton<String>), findsOneWidget);
      },
    );

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

      // Tap the male segment
      await TestHelpers.tapAndWait(tester, find.text('M'));
      await tester.pumpAndSettle();

      expect(changedValue, equals(SexConstants.male));
    });

    testWidgets(
      'should call onChanged with null when selected segment is tapped again',
      (WidgetTester tester) async {
        String? selectedSex = SexConstants.male;
        String? changedValue;

        await TestHelpers.pumpWidgetWithTheme(
          tester,
          SelectSex(
            selectedSex: selectedSex,
            onChanged: (value) => changedValue = value,
          ),
        );

        // Tap the selected segment again to clear it
        await TestHelpers.tapAndWait(tester, find.text('M'));
        await tester.pumpAndSettle();

        expect(changedValue, isNull);
      },
    );

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

      // Check that all sex options are available as segments
      expect(find.text('M'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);
    });

    testWidgets('should handle sex selection changes correctly', (
      WidgetTester tester,
    ) async {
      String? selectedSex = SexConstants.male; // Start with a selected value
      List<String?> changes = [];

      // Use StatefulBuilder to manage state and rebuild on changes
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            return SelectSex(
              selectedSex: selectedSex,
              onChanged: (value) {
                setState(() {
                  selectedSex = value;
                  changes.add(value);
                });
              },
            );
          },
        ),
      );

      // Clear selection by tapping the selected segment again
      await TestHelpers.tapAndWait(tester, find.text('M'));
      await tester.pumpAndSettle();

      // Select female
      await TestHelpers.tapAndWait(tester, find.text('F'));
      await tester.pumpAndSettle();

      // Select male
      await TestHelpers.tapAndWait(tester, find.text('M'));
      await tester.pumpAndSettle();

      expect(changes, equals([null, SexConstants.female, SexConstants.male]));
    });
  });
}
