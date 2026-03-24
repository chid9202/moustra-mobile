import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/tasks_screen.dart';
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

  group('TasksScreen', () {
    testWidgets('renders and shows loading or content', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const TasksScreen());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(TasksScreen), findsOneWidget);
      // After load: loading indicator, error message, or task content
      final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasError = find.text('Error loading tasks').evaluate().isNotEmpty;
      final hasNoTasks = find.text('No tasks found').evaluate().isNotEmpty;
      final hasContent = find.byType(Column).evaluate().isNotEmpty;
      expect(hasLoading || hasError || hasNoTasks || hasContent, isTrue);
    });

    testWidgets('has scaffold or column structure', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const TasksScreen());
      await tester.pump();

      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('can be built and disposed', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const TasksScreen());
      await tester.pump();
      expect(find.byType(TasksScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(TasksScreen), findsOneWidget);
    });
  });
}
