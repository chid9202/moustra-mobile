import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/task_create_screen.dart';
import '../test_helpers/test_helpers.dart';

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

  group('TaskCreateScreen', () {
    testWidgets('renders form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: TaskCreateScreen(),
          ),
        ),
      );

      expect(find.text('Create Task'), findsNWidgets(2)); // title + button
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Task Type'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
    });

    testWidgets('shows due date section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: TaskCreateScreen(),
          ),
        ),
      );

      expect(find.text('No due date'), findsOneWidget);
      expect(find.text('Set Date'), findsOneWidget);
    });

    testWidgets('shows task type dropdown options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: TaskCreateScreen(),
          ),
        ),
      );

      // Default task type should be Custom
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('shows priority dropdown with default medium', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: TaskCreateScreen(),
          ),
        ),
      );

      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('renders the widget type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const Scaffold(
            body: TaskCreateScreen(),
          ),
        ),
      );

      expect(find.byType(TaskCreateScreen), findsOneWidget);
    });
  });
}
