import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/widgets/cage/cage_animals_list.dart';
import '../../test_helpers/test_helpers.dart';

AnimalSummaryDto _createTestAnimal({
  String? animalUuid,
  String? physicalTag = 'A001',
  String? sex = 'M',
  DateTime? dateOfBirth,
  StrainSummaryDto? strain,
}) {
  return AnimalSummaryDto(
    animalId: 1,
    animalUuid: animalUuid ?? 'animal-uuid-1',
    physicalTag: physicalTag,
    sex: sex,
    dateOfBirth: dateOfBirth,
    strain: strain,
  );
}

void main() {
  group('CageAnimalsList', () {
    testWidgets('renders header with animal count', (
      WidgetTester tester,
    ) async {
      final animals = [
        _createTestAnimal(animalUuid: 'a1', physicalTag: 'A001'),
        _createTestAnimal(animalUuid: 'a2', physicalTag: 'A002'),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageAnimalsList(animals: animals, cageUuid: 'cage-uuid'),
      );

      expect(find.text('Animals (2)'), findsOneWidget);
    });

    testWidgets('renders Add button', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CageAnimalsList(animals: [], cageUuid: 'cage-uuid'),
      );

      expect(find.text('Add'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows empty message when no animals', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CageAnimalsList(animals: [], cageUuid: 'cage-uuid'),
      );

      expect(find.text('No animals in this cage'), findsOneWidget);
    });

    testWidgets('renders animal list tiles when animals present', (
      WidgetTester tester,
    ) async {
      final animals = [
        _createTestAnimal(animalUuid: 'a1', physicalTag: 'A001', sex: 'M'),
        _createTestAnimal(animalUuid: 'a2', physicalTag: 'A002', sex: 'F'),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageAnimalsList(animals: animals, cageUuid: 'cage-uuid'),
      );

      expect(find.text('A001'), findsOneWidget);
      expect(find.text('A002'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('shows correct sex icons', (WidgetTester tester) async {
      final animals = [
        _createTestAnimal(animalUuid: 'a1', physicalTag: 'Male1', sex: 'M'),
        _createTestAnimal(animalUuid: 'a2', physicalTag: 'Female1', sex: 'F'),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageAnimalsList(animals: animals, cageUuid: 'cage-uuid'),
      );

      expect(find.byIcon(Icons.male), findsOneWidget);
      expect(find.byIcon(Icons.female), findsOneWidget);
    });

    testWidgets('shows "No tag" when physicalTag is null', (
      WidgetTester tester,
    ) async {
      final animals = [
        _createTestAnimal(animalUuid: 'a1', physicalTag: null),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageAnimalsList(animals: animals, cageUuid: 'cage-uuid'),
      );

      expect(find.text('No tag'), findsOneWidget);
    });

    testWidgets('shows question mark icon for unknown sex', (
      WidgetTester tester,
    ) async {
      final animals = [
        _createTestAnimal(animalUuid: 'a1', sex: null),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageAnimalsList(animals: animals, cageUuid: 'cage-uuid'),
      );

      expect(find.byIcon(Icons.question_mark), findsOneWidget);
    });

    testWidgets('shows chevron right trailing icon', (
      WidgetTester tester,
    ) async {
      final animals = [
        _createTestAnimal(animalUuid: 'a1'),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageAnimalsList(animals: animals, cageUuid: 'cage-uuid'),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows strain name in subtitle when provided', (
      WidgetTester tester,
    ) async {
      final animals = [
        _createTestAnimal(
          animalUuid: 'a1',
          sex: 'M',
          strain: StrainSummaryDto(
            strainId: 1,
            strainUuid: 'strain-uuid',
            strainName: 'B6-Cre',
          ),
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageAnimalsList(animals: animals, cageUuid: 'cage-uuid'),
      );

      // Subtitle should contain the strain name
      expect(find.textContaining('B6-Cre'), findsOneWidget);
    });

    testWidgets('shows sex in subtitle', (WidgetTester tester) async {
      final animals = [
        _createTestAnimal(animalUuid: 'a1', sex: 'M'),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageAnimalsList(animals: animals, cageUuid: 'cage-uuid'),
      );

      expect(find.textContaining('Male'), findsOneWidget);
    });

    testWidgets('renders zero animals count correctly', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CageAnimalsList(animals: [], cageUuid: 'cage-uuid'),
      );

      expect(find.text('Animals (0)'), findsOneWidget);
    });
  });
}
