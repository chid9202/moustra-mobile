import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/entity_picker_sheet.dart';

void main() {
  group('showEntityPickerSheet', () {
    testWidgets('selecting an option pops with value', (tester) async {
      String? picked;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    picked = await showEntityPickerSheet<String>(
                      context: context,
                      options: const ['alpha', 'beta'],
                      getLabel: (s) => s,
                      getKey: (s) => s,
                      title: 'Pick',
                      showSearch: true,
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
      await tester.tap(find.text('beta'));
      await tester.pumpAndSettle();
      expect(picked, 'beta');
    });
  });
}
