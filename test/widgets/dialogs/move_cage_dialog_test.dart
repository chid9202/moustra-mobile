import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/widgets/dialogs/move_cage_dialog.dart';
import 'package:moustra/widgets/rack_cage_grid.dart';
import '../../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  setUp(() {
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
          RackCageDto(
            cageUuid: 'cage-uuid-2',
            cageTag: 'C002',
            xPosition: 1,
            yPosition: 0,
          ),
        ],
      ),
    );
  });

  tearDown(() {
    rackStore.value = null;
  });

  group('MoveCageDialog', () {
    testWidgets('renders with "Move Cage" title', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'cage-uuid-1',
        cageTag: 'C001',
        xPosition: 0,
        yPosition: 0,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        MoveCageDialog(cage: cage),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Move Cage'), findsOneWidget);
    });

    testWidgets('shows description with cage tag and rack name', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'cage-uuid-1',
        cageTag: 'C001',
        xPosition: 0,
        yPosition: 0,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        MoveCageDialog(cage: cage),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.textContaining('C001'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Test Rack'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders RackCageGrid', (WidgetTester tester) async {
      final cage = RackCageDto(
        cageUuid: 'cage-uuid-1',
        cageTag: 'C001',
        xPosition: 0,
        yPosition: 0,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        MoveCageDialog(cage: cage),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(RackCageGrid), findsOneWidget);
    });

    testWidgets('shows Cancel and Move buttons', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'cage-uuid-1',
        cageTag: 'C001',
        xPosition: 0,
        yPosition: 0,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        MoveCageDialog(cage: cage),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Move'), findsOneWidget);
    });

    testWidgets('closes dialog when Cancel is tapped', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'cage-uuid-1',
        cageTag: 'C001',
        xPosition: 0,
        yPosition: 0,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        MoveCageDialog(cage: cage),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Move button is disabled until target is selected', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'cage-uuid-1',
        cageTag: 'C001',
        xPosition: 0,
        yPosition: 0,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        MoveCageDialog(cage: cage),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Move button should be present but the onPressed should be null
      final moveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Move'),
      );
      expect(moveButton.onPressed, isNull);
    });
  });
}
