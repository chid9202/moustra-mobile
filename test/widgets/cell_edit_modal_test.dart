import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/models/cell_edit_state.dart';
import 'package:moustra/widgets/cell_edit_modal.dart';

void main() {
  group('showCellEditModal', () {
    testWidgets('Cancel pops with null', (tester) async {
      dynamic result = 'pending';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    result = await showCellEditModal(
                      context: context,
                      fieldLabel: 'Name',
                      config: const EditFieldConfig(
                        field: 'name',
                        type: EditFieldType.text,
                      ),
                      currentValue: 'x',
                    );
                  },
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('Save pops with text value', (tester) async {
      dynamic result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    result = await showCellEditModal(
                      context: context,
                      fieldLabel: 'Name',
                      config: const EditFieldConfig(
                        field: 'name',
                        type: EditFieldType.text,
                      ),
                      currentValue: 'a',
                    );
                  },
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'updated');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result, 'updated');
    });
  });
}
