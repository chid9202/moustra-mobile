import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/family_tree_widget.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  group('FamilyTreeWidget', () {
    testWidgets('renders loading indicator initially', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const FamilyTreeWidget(animalUuid: 'test-uuid'),
      );

      // The FutureBuilder starts in waiting state, showing a progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when API call fails', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const FamilyTreeWidget(animalUuid: 'test-uuid'),
      );

      // Pump to let the future complete with error (NoOpDioApiClient throws)
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('Failed to load family tree'), findsOneWidget);
    });

    testWidgets('is a StatefulWidget', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const FamilyTreeWidget(animalUuid: 'test-uuid'),
      );

      expect(find.byType(FamilyTreeWidget), findsOneWidget);
    });

    testWidgets('accepts required animalUuid parameter', (
      WidgetTester tester,
    ) async {
      const widget = FamilyTreeWidget(animalUuid: 'my-animal-uuid');
      expect(widget.animalUuid, 'my-animal-uuid');
    });
  });
}
