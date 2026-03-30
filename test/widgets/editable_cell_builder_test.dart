import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/models/cell_edit_state.dart';
import 'package:moustra/widgets/editable_cell_builder.dart';

void main() {
  group('EditableCellBuilder', () {
    testWidgets('text type shows TextField and commits on done', (
      tester,
    ) async {
      Object? committed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableCellBuilder.build(
              config: const EditFieldConfig(
                field: 'name',
                type: EditFieldType.text,
              ),
              value: 'old',
              onCommit: (v) => committed = v,
              onCancel: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'new');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(committed, 'new');
    });

    testWidgets('boolean type shows Switch', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableCellBuilder.build(
              config: const EditFieldConfig(
                field: 'active',
                type: EditFieldType.boolean,
              ),
              value: true,
              onCommit: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('select type shows dropdown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableCellBuilder.build(
              config: EditFieldConfig(
                field: 'role',
                type: EditFieldType.select,
                options: const [
                  SelectOption(value: 'a', label: 'A'),
                  SelectOption(value: 'b', label: 'B'),
                ],
              ),
              value: 'a',
              onCommit: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('autocomplete returns empty box', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableCellBuilder.build(
              config: const EditFieldConfig(
                field: 'owner',
                type: EditFieldType.autocomplete,
              ),
              value: null,
              onCommit: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}
