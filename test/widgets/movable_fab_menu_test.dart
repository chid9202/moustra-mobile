import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  group('MovableFabMenu', () {
    List<FabMenuAction> createTestActions() {
      return [
        FabMenuAction(
          label: 'Action One',
          icon: const Icon(Icons.add),
          onPressed: () {},
        ),
        FabMenuAction(
          label: 'Action Two',
          icon: const Icon(Icons.edit),
          onPressed: () {},
        ),
      ];
    }

    testWidgets('renders FAB button', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        MovableFabMenu(
          actions: createTestActions(),
          heroTag: 'test-fab',
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows menu icon initially', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        MovableFabMenu(
          actions: createTestActions(),
          heroTag: 'test-fab',
          menuIcon: const Icon(Icons.menu),
          closeIcon: const Icon(Icons.close),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('menu items appear when FAB is tapped', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        MovableFabMenu(
          actions: createTestActions(),
          heroTag: 'test-fab',
        ),
      );

      // Initially no action labels visible
      expect(find.text('Action One'), findsNothing);
      expect(find.text('Action Two'), findsNothing);

      // Tap FAB to open menu
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Actions should now be visible
      expect(find.text('Action One'), findsOneWidget);
      expect(find.text('Action Two'), findsOneWidget);
    });

    testWidgets('shows close icon when menu is open', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        MovableFabMenu(
          actions: createTestActions(),
          heroTag: 'test-fab',
          menuIcon: const Icon(Icons.menu),
          closeIcon: const Icon(Icons.close),
        ),
      );

      // Tap FAB to open
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsNothing);
    });

    testWidgets('menu closes when FAB is tapped again', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        MovableFabMenu(
          actions: createTestActions(),
          heroTag: 'test-fab',
        ),
      );

      // Open
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text('Action One'), findsOneWidget);

      // Close
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text('Action One'), findsNothing);
    });

    testWidgets('tapping action with closeOnTap closes menu', (
      WidgetTester tester,
    ) async {
      bool actionCalled = false;
      final actions = [
        FabMenuAction(
          label: 'Close Action',
          icon: const Icon(Icons.check),
          onPressed: () => actionCalled = true,
          closeOnTap: true,
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        MovableFabMenu(
          actions: actions,
          heroTag: 'test-fab',
        ),
      );

      // Open menu
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Tap the action
      await tester.tap(find.text('Close Action'));
      await tester.pump();

      expect(actionCalled, isTrue);
      // Menu should be closed
      expect(find.text('Close Action'), findsNothing);
    });

    testWidgets('disabled action button is not tappable', (
      WidgetTester tester,
    ) async {
      bool actionCalled = false;
      final actions = [
        FabMenuAction(
          label: 'Disabled Action',
          icon: const Icon(Icons.block),
          onPressed: () => actionCalled = true,
          enabled: false,
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        MovableFabMenu(
          actions: actions,
          heroTag: 'test-fab',
        ),
      );

      // Open menu
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('Disabled Action'), findsOneWidget);

      // Tap the disabled action
      await tester.tap(find.text('Disabled Action'));
      await tester.pump();

      expect(actionCalled, isFalse);
    });

    group('MovableFabMenuController', () {
      testWidgets('controller attach/detach lifecycle', (
        WidgetTester tester,
      ) async {
        final controller = MovableFabMenuController();

        await TestHelpers.pumpWidgetWithTheme(
          tester,
          MovableFabMenu(
            actions: createTestActions(),
            heroTag: 'test-fab',
            controller: controller,
          ),
        );

        // Controller is attached, initially closed
        expect(controller.isOpen, isFalse);

        // Open via controller
        controller.open();
        await tester.pump();
        expect(controller.isOpen, isTrue);
        expect(find.text('Action One'), findsOneWidget);

        // Close via controller
        controller.close();
        await tester.pump();
        expect(controller.isOpen, isFalse);
        expect(find.text('Action One'), findsNothing);
      });

      testWidgets('controller toggle works', (WidgetTester tester) async {
        final controller = MovableFabMenuController();

        await TestHelpers.pumpWidgetWithTheme(
          tester,
          MovableFabMenu(
            actions: createTestActions(),
            heroTag: 'test-fab',
            controller: controller,
          ),
        );

        expect(controller.isOpen, isFalse);

        controller.toggle();
        await tester.pump();
        expect(controller.isOpen, isTrue);

        controller.toggle();
        await tester.pump();
        expect(controller.isOpen, isFalse);
      });

      testWidgets('controller detaches on dispose', (
        WidgetTester tester,
      ) async {
        final controller = MovableFabMenuController();

        await TestHelpers.pumpWidgetWithTheme(
          tester,
          MovableFabMenu(
            actions: createTestActions(),
            heroTag: 'test-fab',
            controller: controller,
          ),
        );

        expect(controller.isOpen, isFalse);

        // Replace the widget to trigger dispose
        await TestHelpers.pumpWidgetWithTheme(
          tester,
          const SizedBox(),
        );
        await tester.pump();

        // Controller should be detached; isOpen returns false (no state)
        expect(controller.isOpen, isFalse);
      });
    });

    testWidgets('renders with empty actions list', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const MovableFabMenu(
          actions: [],
          heroTag: 'test-fab-empty',
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Tap FAB - no actions should appear
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // FAB still renders, no crash
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
