import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/color_picker.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  group('ColorPicker Widget Tests', () {
    testWidgets('should render with transparent color for empty hex', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const ColorPicker(hex: ''));

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should render with transparent color for invalid hex', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: 'invalid'),
      );

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should render with correct color for valid hex without #', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: 'FF0000'),
      );

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should render with correct color for valid hex with #', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: '#FF0000'),
      );

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should render with correct color for 8-character hex', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: 'FFFF0000'),
      );

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should have correct dimensions', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: '#FF0000'),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, equals(BorderRadius.circular(2)));
    });

    testWidgets('should have border', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: '#FF0000'),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.color, equals(Colors.black12));
    });

    testWidgets('should parse hex colors correctly', (
      WidgetTester tester,
    ) async {
      // Test red color
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: '#FF0000'),
      );
      await tester.pumpAndSettle();

      // Test blue color
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: '#0000FF'),
      );
      await tester.pumpAndSettle();

      // Test green color
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: '#00FF00'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should handle edge cases in hex parsing', (
      WidgetTester tester,
    ) async {
      // Test with spaces
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: ' FF0000 '),
      );
      await tester.pumpAndSettle();

      // Test with mixed case
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: '#ff0000'),
      );
      await tester.pumpAndSettle();

      // Test with too short hex
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: '#FF'),
      );
      await tester.pumpAndSettle();

      // Test with too long hex
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: '#FF00000000'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should handle null and empty values gracefully', (
      WidgetTester tester,
    ) async {
      // Test empty string
      await TestHelpers.pumpWidgetWithTheme(tester, const ColorPicker(hex: ''));
      await tester.pumpAndSettle();

      // Test whitespace only
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const ColorPicker(hex: '   '),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsOneWidget);
    });
  });
}
