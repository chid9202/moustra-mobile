import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/feedback_screen.dart';
import '../test_helpers/test_helpers.dart';

Future<void> pumpFeedbackScreen(WidgetTester tester) async {
  await runZonedGuarded(
    () async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const FeedbackScreen(),
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
      dotenv.env.clear();
    }
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  group('FeedbackScreen', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpFeedbackScreen(tester);

      expect(find.byType(FeedbackScreen), findsOneWidget);
    });

    testWidgets('shows Send Feedback title', (WidgetTester tester) async {
      await pumpFeedbackScreen(tester);

      expect(find.text('Send Feedback'), findsOneWidget);
    });

    testWidgets('has subject and message text fields', (
      WidgetTester tester,
    ) async {
      await pumpFeedbackScreen(tester);

      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
      expect(find.text('Subject (optional)'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('has submit button', (WidgetTester tester) async {
      await pumpFeedbackScreen(tester);

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await pumpFeedbackScreen(tester);

      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('has proper accessibility structure', (
      WidgetTester tester,
    ) async {
      await pumpFeedbackScreen(tester);

      expect(find.byType(Semantics), findsAtLeastNWidgets(1));
    });

    testWidgets('handles screen lifecycle correctly', (
      WidgetTester tester,
    ) async {
      await pumpFeedbackScreen(tester);

      expect(find.byType(FeedbackScreen), findsOneWidget);

      await tester.pump();
      expect(find.byType(FeedbackScreen), findsOneWidget);
    });
  });
}
