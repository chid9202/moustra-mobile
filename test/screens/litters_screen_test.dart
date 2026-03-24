import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/litters_screen.dart';
import 'package:moustra/widgets/filter_panel.dart';
import '../test_helpers/test_helpers.dart';

Future<void> pumpLittersScreen(WidgetTester tester) async {
  await runZonedGuarded(
    () async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const LittersScreen(),
      );
      await tester.pump();
    },
    (error, stack) {
      // Suppress errors from API calls in test environment
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

  group('LittersScreen', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpLittersScreen(tester);

      expect(find.byType(LittersScreen), findsOneWidget);
    });

    testWidgets('has filter panel', (WidgetTester tester) async {
      await pumpLittersScreen(tester);

      expect(find.byType(FilterPanel), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await pumpLittersScreen(tester);

      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Divider), findsAtLeastNWidgets(1));
    });

    testWidgets('has proper accessibility structure', (
      WidgetTester tester,
    ) async {
      await pumpLittersScreen(tester);

      expect(find.byType(Semantics), findsAtLeastNWidgets(1));
    });

    testWidgets('handles screen lifecycle correctly', (
      WidgetTester tester,
    ) async {
      await pumpLittersScreen(tester);

      expect(find.byType(LittersScreen), findsOneWidget);

      await tester.pump();
      expect(find.byType(LittersScreen), findsOneWidget);
    });
  });
}
