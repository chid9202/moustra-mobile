import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/widgets/cage/cage_header_menu.dart';
import '../../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  setUp(() {
    // Set up rack store with test data
    rackStore.value = RackStoreDto(
      rackData: RackDto(
        rackUuid: 'rack-uuid',
        rackName: 'Test Rack',
        rackWidth: 5,
        rackHeight: 4,
        cages: [
          RackCageDto(
            cageUuid: 'cage-uuid-1',
            cageTag: 'C001',
            xPosition: 0,
            yPosition: 0,
          ),
        ],
      ),
    );
  });

  tearDown(() {
    rackStore.value = null;
  });

  group('CageHeaderMenu', () {
    testWidgets('renders more_vert icon button', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CageHeaderMenu(cageUuid: 'cage-uuid-1'),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('opens menu when icon button is tapped', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CageHeaderMenu(cageUuid: 'cage-uuid-1'),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Open Cage'), findsOneWidget);
      expect(find.text('Add Animals'), findsOneWidget);
      expect(find.text('Move Cage'), findsOneWidget);
    });

    testWidgets('shows three menu items', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CageHeaderMenu(cageUuid: 'cage-uuid-1'),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.byType(MenuItemButton), findsNWidgets(3));
    });

    testWidgets('renders as MenuAnchor widget', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CageHeaderMenu(cageUuid: 'cage-uuid-1'),
      );

      expect(find.byType(MenuAnchor), findsOneWidget);
    });

    testWidgets('accepts cageUuid parameter', (WidgetTester tester) async {
      const widget = CageHeaderMenu(cageUuid: 'my-cage-uuid');
      expect(widget.cageUuid, 'my-cage-uuid');
    });
  });
}
