import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/widgets/cage/animal_card.dart';
import 'package:moustra/widgets/cage/animal_drag_data.dart';
import '../../test_helpers/test_helpers.dart';

RackCageDto _createTestCage() {
  return RackCageDto(
    cageUuid: 'cage-uuid-1',
    cageTag: 'C001',
  );
}

RackCageAnimalDto _createTestAnimal({
  String? physicalTag = 'A001',
  String? sex = 'M',
  List<RackCageAnimalGenotypeDto>? genotypes,
  RackCageLitterDto? litter,
}) {
  return RackCageAnimalDto(
    animalUuid: 'animal-uuid-1',
    physicalTag: physicalTag,
    sex: sex,
    genotypes: genotypes,
    litter: litter,
  );
}

void main() {
  setUpAll(() {
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  group('AnimalCard', () {
    testWidgets('renders physical tag', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(physicalTag: 'TAG42'),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
        ),
      );

      expect(find.text('TAG42'), findsOneWidget);
    });

    testWidgets('shows "No tag" when physicalTag is null', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(physicalTag: null),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
        ),
      );

      expect(find.text('No tag'), findsOneWidget);
    });

    testWidgets('shows gender badge with sex text', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(sex: 'M'),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
        ),
      );

      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('shows female gender badge', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(sex: 'F'),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
        ),
      );

      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('shows "?" when sex is null', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(sex: null),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('shows heart icon when hasMating is true', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(),
          hasMating: true,
          cage: _createTestCage(),
          zoomLevel: 0.6,
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('does not show heart icon when hasMating is false', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
        ),
      );

      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('shows child care icon when litter is present', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(
            litter: RackCageLitterDto(litterUuid: 'litter-uuid'),
          ),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
        ),
      );

      expect(find.byIcon(Icons.child_care), findsOneWidget);
    });

    testWidgets('shows "No genotypes" when genotypes is null', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(genotypes: null),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
        ),
      );

      expect(find.text('No genotypes'), findsOneWidget);
    });

    testWidgets('shows "No genotypes" when genotypes is empty', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(genotypes: []),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
        ),
      );

      expect(find.text('No genotypes'), findsOneWidget);
    });

    testWidgets('shows formatted genotypes', (WidgetTester tester) async {
      final genotypes = [
        RackCageAnimalGenotypeDto(
          gene: RackAnimalGeneDto(geneName: 'Cre'),
          allele: RackAnimalAlleleDto(alleleName: 'het'),
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(genotypes: genotypes),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
        ),
      );

      expect(find.text('Cre/het'), findsOneWidget);
    });

    testWidgets('is draggable when zoomLevel >= 0.4', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.5,
        ),
      );

      expect(find.byType(LongPressDraggable<AnimalDragData>), findsOneWidget);
    });

    testWidgets('is not draggable when zoomLevel < 0.4', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.3,
        ),
      );

      expect(find.byType(LongPressDraggable<AnimalDragData>), findsNothing);
    });

    testWidgets('renders with search highlight when matching', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(physicalTag: 'TAG42'),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
          searchQuery: 'TAG',
        ),
      );

      // Widget should still render the tag
      expect(find.text('TAG42'), findsOneWidget);
    });

    testWidgets('renders without highlight when search does not match', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AnimalCard(
          animal: _createTestAnimal(physicalTag: 'TAG42'),
          hasMating: false,
          cage: _createTestCage(),
          zoomLevel: 0.6,
          searchQuery: 'XYZ',
        ),
      );

      expect(find.text('TAG42'), findsOneWidget);
    });
  });
}
