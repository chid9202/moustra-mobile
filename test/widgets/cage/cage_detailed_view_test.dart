import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/widgets/cage/cage_detailed_view.dart';
import 'package:moustra/widgets/cage/animal_card.dart';
import '../../test_helpers/test_helpers.dart';

void main() {
  group('CageDetailedView', () {
    testWidgets('shows "No animals" when cage has no animals', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'uuid-1',
        cageTag: 'C001',
        animals: [],
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageDetailedView(cage: cage, zoomLevel: 0.6),
      );

      expect(find.text('No animals'), findsOneWidget);
    });

    testWidgets('shows "No animals" when animals is null', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'uuid-1',
        cageTag: 'C001',
        animals: null,
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageDetailedView(cage: cage, zoomLevel: 0.6),
      );

      expect(find.text('No animals'), findsOneWidget);
    });

    testWidgets('renders animal cards when animals are present', (
      WidgetTester tester,
    ) async {
      final animals = [
        RackCageAnimalDto(
          animalUuid: 'animal-1',
          physicalTag: 'A001',
          sex: 'M',
        ),
        RackCageAnimalDto(
          animalUuid: 'animal-2',
          physicalTag: 'A002',
          sex: 'F',
        ),
      ];

      final cage = RackCageDto(
        cageUuid: 'uuid-1',
        cageTag: 'C001',
        animals: animals,
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageDetailedView(cage: cage, zoomLevel: 0.6),
      );

      expect(find.byType(AnimalCard), findsNWidgets(2));
      expect(find.text('A001'), findsOneWidget);
      expect(find.text('A002'), findsOneWidget);
    });

    testWidgets('does not show "No animals" when animals are present', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'uuid-1',
        cageTag: 'C001',
        animals: [
          RackCageAnimalDto(
            animalUuid: 'animal-1',
            physicalTag: 'A001',
            sex: 'M',
          ),
        ],
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageDetailedView(cage: cage, zoomLevel: 0.6),
      );

      expect(find.text('No animals'), findsNothing);
    });

    testWidgets('renders single animal card correctly', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'uuid-1',
        cageTag: 'C001',
        animals: [
          RackCageAnimalDto(
            animalUuid: 'animal-1',
            physicalTag: 'Solo',
            sex: 'F',
          ),
        ],
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageDetailedView(cage: cage, zoomLevel: 0.6),
      );

      expect(find.byType(AnimalCard), findsOneWidget);
      expect(find.text('Solo'), findsOneWidget);
    });
  });
}
