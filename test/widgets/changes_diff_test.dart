import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/field_change_dto.dart';
import 'package:moustra/widgets/changes_diff.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  group('ChangesDiff Widget Tests', () {
    final sampleChanges = [
      FieldChangeDto(field: 'status', label: 'Status', oldValue: 'Active', newValue: 'Inactive'),
      FieldChangeDto(field: 'name', label: 'Name', oldValue: 'Old Name', newValue: 'New Name'),
    ];

    testWidgets('should render all changes', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        ChangesDiff(changes: sampleChanges),
      );

      expect(find.text('Status: '), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Inactive'), findsOneWidget);
      expect(find.text('Name: '), findsOneWidget);
      expect(find.text('Old Name'), findsOneWidget);
      expect(find.text('New Name'), findsOneWidget);
    });

    testWidgets('compact mode shows max 3 and +N more', (
      WidgetTester tester,
    ) async {
      final manyChanges = [
        FieldChangeDto(field: 'f1', label: 'Field 1', oldValue: 'a', newValue: 'b'),
        FieldChangeDto(field: 'f2', label: 'Field 2', oldValue: 'c', newValue: 'd'),
        FieldChangeDto(field: 'f3', label: 'Field 3', oldValue: 'e', newValue: 'f'),
        FieldChangeDto(field: 'f4', label: 'Field 4', oldValue: 'g', newValue: 'h'),
        FieldChangeDto(field: 'f5', label: 'Field 5', oldValue: 'i', newValue: 'j'),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        ChangesDiff(changes: manyChanges, compact: true),
      );

      expect(find.textContaining('Field 1'), findsOneWidget);
      expect(find.textContaining('Field 2'), findsOneWidget);
      expect(find.textContaining('Field 3'), findsOneWidget);
      expect(find.textContaining('Field 4'), findsNothing);
      expect(find.text('+2 more'), findsOneWidget);
    });

    testWidgets('renders old value with strikethrough styling', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        ChangesDiff(changes: [sampleChanges[0]]),
      );

      final oldText = tester.widget<Text>(find.text('Active'));
      expect(oldText.style?.decoration, TextDecoration.lineThrough);
      expect(oldText.style?.color, Colors.red);
    });

    testWidgets('renders new value with bold green styling', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        ChangesDiff(changes: [sampleChanges[0]]),
      );

      final newText = tester.widget<Text>(find.text('Inactive'));
      expect(newText.style?.fontWeight, FontWeight.bold);
      expect(newText.style?.color, Colors.green);
    });
  });
}
