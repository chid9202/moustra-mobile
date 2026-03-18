import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';

void main() {
  group('CageStoreDto', () {
    test('fromJson with complete data', () {
      final json = {
        'cageId': 1,
        'cageUuid': 'cage-uuid-1',
        'cageTag': 'C001',
        'strain': {
          'strainId': 10,
          'strainUuid': 'strain-uuid-1',
          'strainName': 'C57BL/6',
          'color': '#FF0000',
        },
        'animals': [
          {
            'eid': 100,
            'animalId': 1,
            'animalUuid': 'animal-uuid-1',
            'physicalTag': 'A001',
            'sex': 'M',
            'dateOfBirth': '2024-01-01T00:00:00.000Z',
            'weanDate': '2024-01-22T00:00:00.000Z',
          },
        ],
      };

      final dto = CageStoreDto.fromJson(json);

      expect(dto.cageId, equals(1));
      expect(dto.cageUuid, equals('cage-uuid-1'));
      expect(dto.cageTag, equals('C001'));
      expect(dto.strain, isNotNull);
      expect(dto.strain!.strainId, equals(10));
      expect(dto.strain!.strainName, equals('C57BL/6'));
      expect(dto.animals.length, equals(1));
      expect(dto.animals[0].eid, equals(100));
      expect(dto.animals[0].physicalTag, equals('A001'));
    });

    test('fromJson with minimal data', () {
      final json = {
        'cageId': 2,
        'cageUuid': 'cage-uuid-2',
        'animals': <Map<String, dynamic>>[],
      };

      final dto = CageStoreDto.fromJson(json);

      expect(dto.cageId, equals(2));
      expect(dto.cageTag, isNull);
      expect(dto.strain, isNull);
      expect(dto.animals, isEmpty);
    });

    test('toJson round-trip', () {
      final json = {
        'cageId': 1,
        'cageUuid': 'cage-uuid-1',
        'cageTag': 'C001',
        'animals': <Map<String, dynamic>>[],
      };

      final dto = CageStoreDto.fromJson(json);
      final output = dto.toJson();

      expect(output['cageId'], equals(1));
      expect(output['cageUuid'], equals('cage-uuid-1'));
      expect(output['cageTag'], equals('C001'));
    });

    test('toCageSummaryDto', () {
      final dto = CageStoreDto(
        cageId: 1,
        cageUuid: 'cage-uuid-1',
        cageTag: 'C001',
      );

      final summary = dto.toCageSummaryDto();

      expect(summary.cageId, equals(1));
      expect(summary.cageUuid, equals('cage-uuid-1'));
      expect(summary.cageTag, equals('C001'));
    });
  });

  group('CageStoreStrainDto', () {
    test('fromJson with complete data', () {
      final json = {
        'strainId': 1,
        'strainUuid': 'strain-uuid-1',
        'strainName': 'C57BL/6',
        'color': '#FF0000',
      };

      final dto = CageStoreStrainDto.fromJson(json);

      expect(dto.strainId, equals(1));
      expect(dto.strainUuid, equals('strain-uuid-1'));
      expect(dto.strainName, equals('C57BL/6'));
      expect(dto.color, equals('#FF0000'));
    });

    test('fromJson with minimal data', () {
      final json = {
        'strainId': 1,
        'strainUuid': 'strain-uuid-1',
        'strainName': 'C57BL/6',
      };

      final dto = CageStoreStrainDto.fromJson(json);

      expect(dto.color, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'strainId': 1,
        'strainUuid': 'strain-uuid-1',
        'strainName': 'C57BL/6',
        'color': '#FF0000',
      };

      final dto = CageStoreStrainDto.fromJson(json);
      final output = dto.toJson();

      expect(output['strainId'], equals(1));
      expect(output['strainName'], equals('C57BL/6'));
      expect(output['color'], equals('#FF0000'));
    });
  });

  group('CageStoreAnimalDto', () {
    test('fromJson with complete data', () {
      final json = {
        'eid': 100,
        'animalId': 1,
        'animalUuid': 'animal-uuid-1',
        'physicalTag': 'A001',
        'sex': 'M',
        'dateOfBirth': '2024-01-01T00:00:00.000Z',
        'weanDate': '2024-01-22T00:00:00.000Z',
      };

      final dto = CageStoreAnimalDto.fromJson(json);

      expect(dto.eid, equals(100));
      expect(dto.animalId, equals(1));
      expect(dto.animalUuid, equals('animal-uuid-1'));
      expect(dto.physicalTag, equals('A001'));
      expect(dto.sex, equals('M'));
      expect(dto.dateOfBirth, isNotNull);
      expect(dto.weanDate, isNotNull);
    });

    test('fromJson with minimal data', () {
      final json = {
        'eid': 100,
        'animalId': 1,
        'animalUuid': 'animal-uuid-1',
      };

      final dto = CageStoreAnimalDto.fromJson(json);

      expect(dto.physicalTag, isNull);
      expect(dto.sex, isNull);
      expect(dto.dateOfBirth, isNull);
      expect(dto.weanDate, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'eid': 100,
        'animalId': 1,
        'animalUuid': 'animal-uuid-1',
        'physicalTag': 'A001',
        'sex': 'F',
      };

      final dto = CageStoreAnimalDto.fromJson(json);
      final output = dto.toJson();

      expect(output['eid'], equals(100));
      expect(output['animalId'], equals(1));
      expect(output['physicalTag'], equals('A001'));
      expect(output['sex'], equals('F'));
    });
  });
}
