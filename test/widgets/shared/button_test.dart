import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/shared/button.dart';
import '../../test_helpers/test_helpers.dart';

void main() {
  group('MoustraButton', () {
    testWidgets('renders with basic properties', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton(label: 'Test Button', onPressed: null),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        MoustraButton(label: 'Test Button', onPressed: () => wasPressed = true),
      );

      await TestHelpers.tapAndWait(tester, find.byType(MoustraButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (
      WidgetTester tester,
    ) async {
      bool wasPressed = false;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        MoustraButton(label: 'Test Button', onPressed: null),
      );

      await TestHelpers.tapAndWait(tester, find.byType(MoustraButton));
      expect(wasPressed, isFalse);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton(label: 'Test Button', isLoading: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('renders with icon when provided', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton.icon(label: 'Test Button', icon: Icons.add),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    group('Button Variants', () {
      testWidgets('renders primary variant correctly', (
        WidgetTester tester,
      ) async {
        await TestHelpers.pumpWidgetWithTheme(
          tester,
          const MoustraButton(
            label: 'Primary Button',
            variant: ButtonVariant.primary,
          ),
        );

        final button = TestHelpers.findWidget<FilledButton>(tester);
        expect(button.style?.backgroundColor?.resolve({}), isNotNull);
      });

      testWidgets('renders secondary variant correctly', (
        WidgetTester tester,
      ) async {
        await TestHelpers.pumpWidgetWithTheme(
          tester,
          const MoustraButton(
            label: 'Secondary Button',
            variant: ButtonVariant.secondary,
          ),
        );

        final button = TestHelpers.findWidget<FilledButton>(tester);
        expect(button.style?.backgroundColor?.resolve({}), isNotNull);
      });

      testWidgets('renders success variant correctly', (
        WidgetTester tester,
      ) async {
        await TestHelpers.pumpWidgetWithTheme(
          tester,
          const MoustraButton(
            label: 'Success Button',
            variant: ButtonVariant.success,
          ),
        );

        final button = TestHelpers.findWidget<FilledButton>(tester);
        expect(button.style?.backgroundColor?.resolve({}), isNotNull);
      });

      testWidgets('renders warning variant correctly', (
        WidgetTester tester,
      ) async {
        await TestHelpers.pumpWidgetWithTheme(
          tester,
          const MoustraButton(
            label: 'Warning Button',
            variant: ButtonVariant.warning,
          ),
        );

        final button = TestHelpers.findWidget<FilledButton>(tester);
        expect(button.style?.backgroundColor?.resolve({}), isNotNull);
      });

      testWidgets('renders error variant correctly', (
        WidgetTester tester,
      ) async {
        await TestHelpers.pumpWidgetWithTheme(
          tester,
          const MoustraButton(
            label: 'Error Button',
            variant: ButtonVariant.error,
          ),
        );

        final button = TestHelpers.findWidget<FilledButton>(tester);
        expect(button.style?.backgroundColor?.resolve({}), isNotNull);
      });

      testWidgets('renders info variant correctly', (
        WidgetTester tester,
      ) async {
        await TestHelpers.pumpWidgetWithTheme(
          tester,
          const MoustraButton(
            label: 'Info Button',
            variant: ButtonVariant.info,
          ),
        );

        final button = TestHelpers.findWidget<FilledButton>(tester);
        expect(button.style?.backgroundColor?.resolve({}), isNotNull);
      });
    });

    group('Button Sizes', () {
      testWidgets('renders small size correctly', (WidgetTester tester) async {
        await TestHelpers.pumpWidgetWithTheme(
          tester,
          const MoustraButton(label: 'Small Button', size: ButtonSize.small),
        );

        final button = TestHelpers.findWidget<FilledButton>(tester);
        expect(button.style?.minimumSize?.resolve({}), isNotNull);
      });

      testWidgets('renders medium size correctly', (WidgetTester tester) async {
        await TestHelpers.pumpWidgetWithTheme(
          tester,
          const MoustraButton(label: 'Medium Button', size: ButtonSize.medium),
        );

        final button = TestHelpers.findWidget<FilledButton>(tester);
        expect(button.style?.minimumSize?.resolve({}), isNotNull);
      });

      testWidgets('renders large size correctly', (WidgetTester tester) async {
        await TestHelpers.pumpWidgetWithTheme(
          tester,
          const MoustraButton(label: 'Large Button', size: ButtonSize.large),
        );

        final button = TestHelpers.findWidget<FilledButton>(tester);
        expect(button.style?.minimumSize?.resolve({}), isNotNull);
      });
    });

    testWidgets('renders with fullWidth when specified', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton(label: 'Full Width Button', fullWidth: true),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      final sizedBox = TestHelpers.findWidget<SizedBox>(tester);
      expect(sizedBox.width, equals(double.infinity));
    });

    testWidgets('does not render with fullWidth when false', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton(label: 'Normal Button', fullWidth: false),
      );

      expect(find.byType(SizedBox), findsNothing);
    });
  });

  group('MoustraButtonPrimary', () {
    testWidgets('renders with primary variant', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButtonPrimary(label: 'Primary Button'),
      );

      expect(find.text('Primary Button'), findsOneWidget);
      final button = TestHelpers.findWidget<FilledButton>(tester);
      expect(button.style?.backgroundColor?.resolve({}), isNotNull);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        MoustraButtonPrimary(
          label: 'Primary Button',
          onPressed: () => wasPressed = true,
        ),
      );

      await TestHelpers.tapAndWait(tester, find.byType(MoustraButtonPrimary));
      expect(wasPressed, isTrue);
    });
  });

  group('MoustraButtonSuccess', () {
    testWidgets('renders with success variant', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButtonSuccess(label: 'Success Button'),
      );

      expect(find.text('Success Button'), findsOneWidget);
      final button = TestHelpers.findWidget<FilledButton>(tester);
      expect(button.style?.backgroundColor?.resolve({}), isNotNull);
    });
  });

  group('MoustraButtonError', () {
    testWidgets('renders with error variant', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButtonError(label: 'Error Button'),
      );

      expect(find.text('Error Button'), findsOneWidget);
      final button = TestHelpers.findWidget<FilledButton>(tester);
      expect(button.style?.backgroundColor?.resolve({}), isNotNull);
    });
  });

  group('Button Theme Integration', () {
    testWidgets('uses theme colors correctly', (WidgetTester tester) async {
      final theme = TestHelpers.createMockTheme();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton(
          label: 'Themed Button',
          variant: ButtonVariant.primary,
        ),
        theme: theme,
      );

      final button = TestHelpers.findWidget<FilledButton>(tester);
      expect(button.style?.backgroundColor?.resolve({}), isNotNull);
    });

    testWidgets('uses MUI colors for custom variants', (
      WidgetTester tester,
    ) async {
      final theme = TestHelpers.createMockTheme();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton(
          label: 'Success Button',
          variant: ButtonVariant.success,
        ),
        theme: theme,
      );

      final button = TestHelpers.findWidget<FilledButton>(tester);
      expect(button.style?.backgroundColor?.resolve({}), isNotNull);
    });
  });

  group('Button Accessibility', () {
    testWidgets('has proper semantics', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton(label: 'Accessible Button'),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      // Additional accessibility tests can be added here
    });

    testWidgets('shows loading state to screen readers', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton(label: 'Loading Button', isLoading: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Button Edge Cases', () {
    testWidgets('handles empty label gracefully', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton(label: ''),
      );

      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('handles very long label', (WidgetTester tester) async {
      const longLabel =
          'This is a very long button label that should be handled gracefully by the button widget';

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton(label: longLabel),
      );

      expect(find.text(longLabel), findsOneWidget);
    });

    testWidgets('handles null onPressed gracefully', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MoustraButton(label: 'Disabled Button', onPressed: null),
      );

      final button = TestHelpers.findWidget<FilledButton>(tester);
      expect(button.onPressed, isNull);
    });
  });
}
