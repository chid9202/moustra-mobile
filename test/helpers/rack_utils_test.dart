import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/helpers/rack_utils.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

void main() {
  group('getRackPositionLabel', () {
    test('null position returns empty', () {
      expect(getRackPositionLabel(null), '');
    });

    test('first row/col is A1', () {
      expect(
        getRackPositionLabel(const RackGridPosition(x: 0, y: 0)),
        'A1',
      );
    });
  });

  group('getRackTotalPositions', () {
    test('returns product for positive dimensions', () {
      expect(getRackTotalPositions(5, 4), 20);
    });

    test('returns 0 for non-positive dimension', () {
      expect(getRackTotalPositions(0, 5), 0);
      expect(getRackTotalPositions(3, 0), 0);
    });
  });

  group('getRackCagesWithPosition', () {
    test('uses x/y when present on cages', () {
      final cages = [
        RackCageDto(
          cageUuid: 'c1',
          order: 1,
          xPosition: 2,
          yPosition: 1,
        ),
      ];
      final withPos = getRackCagesWithPosition(cages, 10, 10);
      expect(withPos.length, 1);
      expect(withPos.first.position?.x, 2);
      expect(withPos.first.position?.y, 1);
      expect(withPos.first.positionLabel, 'B3');
    });

    test('falls back to index order when no coordinates', () {
      final cages = [
        RackCageDto(cageUuid: 'a', order: 0),
        RackCageDto(cageUuid: 'b', order: 1),
      ];
      final withPos = getRackCagesWithPosition(cages, 2, 2);
      expect(withPos[0].position?.x, 0);
      expect(withPos[0].position?.y, 0);
      expect(withPos[1].position?.x, 1);
      expect(withPos[1].position?.y, 0);
    });
  });

  group('getRackInsights', () {
    test('null rack yields zeros', () {
      final i = getRackInsights(null);
      expect(i.occupiedCages, 0);
      expect(i.totalAnimals, 0);
      expect(i.totalPositions, 0);
      expect(i.utilizationPct, 0);
    });

    test('counts cages and animals', () {
      final rack = RackDto(
        rackWidth: 2,
        rackHeight: 2,
        cages: [
          RackCageDto(
            cageUuid: 'c1',
            animals: [
              RackCageAnimalDto(animalUuid: 'a1', animalId: 1),
            ],
          ),
          RackCageDto(
            cageUuid: 'c2',
            animals: const [],
          ),
        ],
      );
      final i = getRackInsights(rack);
      expect(i.occupiedCages, 2);
      expect(i.totalAnimals, 1);
      expect(i.totalPositions, 4);
      expect(i.emptyPositions, 2);
      expect(i.estimatedDailyCost, 2 * estimatedCageCostPerDay);
      expect(i.estimatedWeeklyCost, i.estimatedDailyCost * 7);
    });
  });

  group('generateCageTag', () {
    test('null when missing inputs', () {
      expect(generateCageTag(null, const RackGridPosition(x: 0, y: 0)), isNull);
      expect(generateCageTag('', const RackGridPosition(x: 0, y: 0)), isNull);
      expect(generateCageTag('R1', null), isNull);
    });

    test('combines rack name and position label', () {
      expect(
        generateCageTag('Rack1', const RackGridPosition(x: 0, y: 0)),
        'Rack1-A1',
      );
    });
  });

  group('getOwnerName', () {
    test('null owner returns dash', () {
      expect(getOwnerName(null), '-');
    });

    test('uses first and last name from map', () {
      final owner = RackCageOwnerDto(
        user: {'firstName': 'Ann', 'lastName': 'Bee'},
      );
      expect(getOwnerName(owner), 'Ann Bee');
    });

    test('falls back to email', () {
      final owner = RackCageOwnerDto(
        user: {'email': 'x@y.com'},
      );
      expect(getOwnerName(owner), 'x@y.com');
    });
  });
}
