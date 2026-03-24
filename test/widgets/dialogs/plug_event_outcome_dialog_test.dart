import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';
import 'package:moustra/widgets/dialogs/plug_event_outcome_dialog.dart';
import '../../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    // Initialize dotenv - try loading .env file if it exists, otherwise use empty initialization
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // If .env file doesn't exist or can't be loaded, initialize with empty values
      // Env class will use fallback values
      dotenv.loadFromString(envString: '', isOptional: true);
    }
  });

  group('PlugEventOutcomeDialog', () {
    final mockPlugEvent = PlugEventDto(
      plugEventId: 1,
      plugEventUuid: 'test-uuid',
      plugDate: '2023-06-15T00:00:00.000',
    );

    testWidgets('renders correctly when dialog is shown', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        PlugEventOutcomeDialog(plugEvent: mockPlugEvent),
      );

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('shows Record Outcome title', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        PlugEventOutcomeDialog(plugEvent: mockPlugEvent),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Record Outcome'), findsOneWidget);
    });

    testWidgets('shows Cancel and Save action buttons', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        PlugEventOutcomeDialog(plugEvent: mockPlugEvent),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows outcome dropdown field', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        PlugEventOutcomeDialog(plugEvent: mockPlugEvent),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check for outcome label
      expect(find.text('Outcome *'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('shows SelectDate widget for outcome date', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        PlugEventOutcomeDialog(plugEvent: mockPlugEvent),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Outcome Date *'), findsOneWidget);
    });

    testWidgets('Save button is enabled initially', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        PlugEventOutcomeDialog(plugEvent: mockPlugEvent),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save'),
      );
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('Cancel button dismisses dialog', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        PlugEventOutcomeDialog(plugEvent: mockPlugEvent),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is showing
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        PlugEventOutcomeDialog(plugEvent: mockPlugEvent),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check for dialog structure
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsAtLeastNWidgets(1));
    });

    testWidgets('has proper accessibility structure', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        PlugEventOutcomeDialog(plugEvent: mockPlugEvent),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check for semantic structure
      expect(find.byType(Semantics), findsAtLeastNWidgets(1));
    });
  });
}
