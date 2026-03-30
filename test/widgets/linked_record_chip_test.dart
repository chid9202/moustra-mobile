import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/linked_record_chip.dart';

void main() {
  group('LinkedRecordChip', () {
    testWidgets('shows label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LinkedRecordChip(label: 'Strain A'),
          ),
        ),
      );
      expect(find.text('Strain A'), findsOneWidget);
    });

    testWidgets('onTap fires when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkedRecordChip(
              label: 'Tap me',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });
  });

  group('LinkedRecordChipList', () {
    testWidgets('empty list renders no chips', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LinkedRecordChipList(chips: []),
          ),
        ),
      );
      expect(find.byType(LinkedRecordChip), findsNothing);
    });

    testWidgets('shows overflow when more than maxVisible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkedRecordChipList(
              maxVisible: 2,
              chips: const [
                LinkedRecordChipData(label: 'A'),
                LinkedRecordChipData(label: 'B'),
                LinkedRecordChipData(label: 'C'),
              ],
            ),
          ),
        ),
      );
      expect(find.text('+1'), findsOneWidget);
    });
  });
}
