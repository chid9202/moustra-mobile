import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/plug_event_new_screen.dart';
import 'package:moustra/widgets/shared/select_animal.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/widgets/shared/select_mating.dart';
import '../test_helpers/test_helpers.dart';

/// Helper to pump the PlugEventNewScreen and ignore async API errors
/// that occur in the test environment (HTTP calls return 400 with empty body).
Future<void> pumpPlugEventNewScreen(
  WidgetTester tester, {
  String? matingUuid,
  String? femaleUuid,
}) async {
  await runZonedGuarded(
    () async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        PlugEventNewScreen(matingUuid: matingUuid, femaleUuid: femaleUuid),
      );
      await tester.pump();
    },
    (error, stack) {
      // Suppress FormatException from API calls in test environment
    },
  );
}

void main() {
  setUpAll(() async {
    installNoOpDioApiClient();
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      dotenv.loadFromString(envString: '', isOptional: true);
    }
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  group('PlugEventNewScreen', () {
    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventNewScreen(tester);

      // Screen should render
      expect(find.byType(PlugEventNewScreen), findsOneWidget);
    });

    testWidgets('shows AppBar with correct title', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventNewScreen(tester);

      // Verify AppBar and title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Record Plug Event'), findsOneWidget);
    });

    testWidgets('shows back button in AppBar', (WidgetTester tester) async {
      await pumpPlugEventNewScreen(tester);

      // Verify back button icon
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('has Form widget', (WidgetTester tester) async {
      await pumpPlugEventNewScreen(tester);

      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('has SelectMating widget', (WidgetTester tester) async {
      await pumpPlugEventNewScreen(tester);

      expect(find.byType(SelectMating), findsOneWidget);
    });

    testWidgets('has SelectAnimal widgets for female and male', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventNewScreen(tester);

      // Two SelectAnimal widgets: one for female, one for male
      expect(find.byType(SelectAnimal), findsNWidgets(2));
    });

    testWidgets('has SelectDate widget for plug date', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventNewScreen(tester);

      expect(find.byType(SelectDate), findsOneWidget);
    });

    testWidgets('has Target E-Day text field', (WidgetTester tester) async {
      await pumpPlugEventNewScreen(tester);

      expect(find.text('Target E-Day'), findsOneWidget);
    });

    testWidgets('has Comment text field', (WidgetTester tester) async {
      await pumpPlugEventNewScreen(tester);

      expect(find.text('Comment'), findsOneWidget);
    });

    testWidgets('has Save button', (WidgetTester tester) async {
      await pumpPlugEventNewScreen(tester);

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Save Plug Event'), findsOneWidget);
    });

    testWidgets('Save button is enabled initially', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventNewScreen(tester);

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await pumpPlugEventNewScreen(tester);

      // Check for Scaffold, SingleChildScrollView, and Column
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('handles screen lifecycle correctly', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventNewScreen(tester);

      // Verify the screen can be built
      expect(find.byType(PlugEventNewScreen), findsOneWidget);

      // Test that the screen can be rebuilt
      await tester.pump();
      expect(find.byType(PlugEventNewScreen), findsOneWidget);
    });

    testWidgets('accepts optional matingUuid parameter', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventNewScreen(tester, matingUuid: 'test-mating-uuid');

      expect(find.byType(PlugEventNewScreen), findsOneWidget);
    });

    testWidgets('accepts optional femaleUuid parameter', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventNewScreen(tester, femaleUuid: 'test-female-uuid');

      expect(find.byType(PlugEventNewScreen), findsOneWidget);
    });

    testWidgets('has proper accessibility structure', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventNewScreen(tester);

      // Check for semantic structure
      expect(find.byType(Semantics), findsAtLeastNWidgets(1));
    });

    testWidgets('has TextFormField widgets for input', (
      WidgetTester tester,
    ) async {
      await pumpPlugEventNewScreen(tester);

      // Target E-Day and Comment text fields
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });
}
