import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/widgets/dialogs/move_cage_dialog.dart';
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

    testWidgets('shows cage tag in content', (WidgetTester tester) async {
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

      expect(find.text('Cage: C001'), findsOneWidget);
    });

    testWidgets('shows "Untitled" when cageTag is null', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'cage-uuid-1',
        cageTag: null,
        xPosition: 0,
        yPosition: 0,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        MoveCageDialog(cage: cage),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cage: Untitled'), findsOneWidget);
    });

    testWidgets('shows current position', (WidgetTester tester) async {
      final cage = RackCageDto(
        cageUuid: 'cage-uuid-1',
        cageTag: 'C001',
        xPosition: 2,
        yPosition: 1,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        MoveCageDialog(cage: cage),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Position is 1-indexed: row = y+1 = 2, column = x+1 = 3
      expect(find.text('Current Position: Row 2, Column 3'), findsOneWidget);
    });

    testWidgets('shows rack size information', (WidgetTester tester) async {
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

      expect(find.textContaining('5 columns'), findsOneWidget);
      expect(find.textContaining('4 rows'), findsOneWidget);
    });

    testWidgets('shows Row and Column input fields', (
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

      expect(find.text('Row'), findsOneWidget);
      expect(find.text('Column'), findsOneWidget);
    });

    testWidgets('pre-fills row and column with current position', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'cage-uuid-1',
        cageTag: 'C001',
        xPosition: 3,
        yPosition: 2,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        MoveCageDialog(cage: cage),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // 1-indexed: row = y+1 = 3, column = x+1 = 4
      expect(find.text('3'), findsOneWidget); // row
      expect(find.text('4'), findsOneWidget); // column
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

    testWidgets('validates same position error when Move is tapped', (
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

      // Default values are already the current position (1, 1)
      // Tapping Move should show validation error
      await tester.tap(find.text('Move'));
      await tester.pump();

      expect(
        find.text('New position must be different from current position'),
        findsOneWidget,
      );
    });
  });
}
