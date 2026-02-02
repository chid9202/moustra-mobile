import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/cage/empty_cage_slot.dart';
import '../../test_helpers/test_helpers.dart';

void main() {
  group('EmptyCageSlot', () {
    testWidgets('renders with add icon', (WidgetTester tester) async {
      bool tapped = false;
      
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        EmptyCageSlot(onTap: () => tapped = true),
      );

      // Verify the add icon is present
      expect(find.byIcon(Icons.add), findsOneWidget);
      
      // Verify it's a Card widget
      expect(find.byType(Card), findsOneWidget);
      
      // Verify the InkWell is present for tap handling
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        EmptyCageSlot(onTap: () => tapped = true),
      );

      // Tap the widget
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Verify the callback was called
      expect(tapped, isTrue);
    });

    testWidgets('has correct styling', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        EmptyCageSlot(onTap: () {}),
      );

      // Verify Card properties
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 0);
      expect(card.margin, const EdgeInsets.all(16.0));
      expect(card.color, Colors.grey.shade50);
      
      // Verify Card has rounded corners
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(8.0));
      
      // Verify the border style
      final borderSide = shape.side;
      expect(borderSide.color, Colors.grey.shade300);
      expect(borderSide.width, 1.5);
      expect(borderSide.style, BorderStyle.solid);
    });

    testWidgets('icon has correct size and color', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        EmptyCageSlot(onTap: () {}),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.add));
      expect(icon.size, 32);
      expect(icon.color, Colors.grey.shade400);
    });

    testWidgets('centers the icon', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        EmptyCageSlot(onTap: () {}),
      );

      // Verify there's a Center widget containing the Icon
      expect(find.ancestor(
        of: find.byIcon(Icons.add),
        matching: find.byType(Center),
      ), findsOneWidget);
    });

    testWidgets('InkWell has matching border radius', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        EmptyCageSlot(onTap: () {}),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, BorderRadius.circular(8.0));
    });
  });
}
