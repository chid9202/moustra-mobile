import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/safe_text.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  group('SafeText Widget Tests', () {
    testWidgets('should render with provided text', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SafeText('Hello World'),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should render with empty string when text is null', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const SafeText(null));

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('should render with empty string when text is empty', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const SafeText(''));

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('should apply custom style', (WidgetTester tester) async {
      const customStyle = TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SafeText('Styled Text', style: customStyle),
      );

      expect(find.text('Styled Text'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Styled Text'));
      expect(textWidget.style, equals(customStyle));
    });

    testWidgets('should apply text alignment', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SafeText('Centered Text', textAlign: TextAlign.center),
      );

      expect(find.text('Centered Text'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Centered Text'));
      expect(textWidget.textAlign, equals(TextAlign.center));
    });

    testWidgets('should handle text overflow', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SafeText(
          'Very long text that might overflow',
          overflow: TextOverflow.ellipsis,
        ),
      );

      expect(find.text('Very long text that might overflow'), findsOneWidget);
      final textWidget = tester.widget<Text>(
        find.text('Very long text that might overflow'),
      );
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should handle max lines', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SafeText('Text with max lines', maxLines: 2),
      );

      expect(find.text('Text with max lines'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Text with max lines'));
      expect(textWidget.maxLines, equals(2));
    });

    testWidgets('should handle soft wrap', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SafeText('Text with soft wrap disabled', softWrap: false),
      );

      expect(find.text('Text with soft wrap disabled'), findsOneWidget);
      final textWidget = tester.widget<Text>(
        find.text('Text with soft wrap disabled'),
      );
      expect(textWidget.softWrap, equals(false));
    });

    testWidgets('should handle text direction', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SafeText('RTL Text', textDirection: TextDirection.rtl),
      );

      expect(find.text('RTL Text'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('RTL Text'));
      expect(textWidget.textDirection, equals(TextDirection.rtl));
    });

    testWidgets('should handle text scale factor', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SafeText('Scaled Text', textScaleFactor: 1.5),
      );

      expect(find.text('Scaled Text'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Scaled Text'));
      expect(textWidget.textScaleFactor, equals(1.5));
    });

    testWidgets('should handle semantics label', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SafeText(
          'Accessible Text',
          semanticsLabel: 'This is accessible text',
        ),
      );

      expect(find.text('Accessible Text'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Accessible Text'));
      expect(textWidget.semanticsLabel, equals('This is accessible text'));
    });

    testWidgets('should handle all parameters together', (
      WidgetTester tester,
    ) async {
      const customStyle = TextStyle(fontSize: 16, color: Colors.blue);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SafeText(
          'Complete Text',
          style: customStyle,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          softWrap: true,
          textDirection: TextDirection.ltr,
          textScaleFactor: 1.2,
          semanticsLabel: 'Complete text widget',
        ),
      );

      expect(find.text('Complete Text'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Complete Text'));
      expect(textWidget.style, equals(customStyle));
      expect(textWidget.textAlign, equals(TextAlign.center));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      expect(textWidget.maxLines, equals(3));
      expect(textWidget.softWrap, equals(true));
      expect(textWidget.textDirection, equals(TextDirection.ltr));
      expect(textWidget.textScaleFactor, equals(1.2));
      expect(textWidget.semanticsLabel, equals('Complete text widget'));
    });

    testWidgets('should handle null text with all parameters', (
      WidgetTester tester,
    ) async {
      const customStyle = TextStyle(fontSize: 16, color: Colors.blue);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const SafeText(
          null,
          style: customStyle,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          softWrap: true,
          textDirection: TextDirection.ltr,
          textScaleFactor: 1.2,
          semanticsLabel: 'Null text widget',
        ),
      );

      expect(find.text(''), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text(''));
      expect(textWidget.style, equals(customStyle));
      expect(textWidget.textAlign, equals(TextAlign.center));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      expect(textWidget.maxLines, equals(3));
      expect(textWidget.softWrap, equals(true));
      expect(textWidget.textDirection, equals(TextDirection.ltr));
      expect(textWidget.textScaleFactor, equals(1.2));
      expect(textWidget.semanticsLabel, equals('Null text widget'));
    });
  });
}
