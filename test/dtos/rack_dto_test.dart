import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

void main() {
  group('RackDto', () {
    test('fromJson with complete data', () {
      final json = {
        'rackId': 1,
        'rackUuid': 'rack-uuid-1',
        'rackName': 'Rack A',
        'rackWidth': 5,
        'rackHeight': 10,
        'cages': [
          {
            'cageId': 1,
            'cageTag': 'C001',
            'cageUuid': 'cage-uuid-1',
            'order': 0,
            'xPosition': 1,
            'yPosition': 2,
            'status': 'active',
          },
        ],
        'racks': [
          {
            'rackId': 2,
            'rackUuid': 'rack-uuid-2',
            'rackName': 'Rack B',
          },
        ],
      };

      final dto = RackDto.fromJson(json);

      expect(dto.rackId, equals(1));
      expect(dto.rackUuid, equals('rack-uuid-1'));
      expect(dto.rackName, equals('Rack A'));
      expect(dto.rackWidth, equals(5));
      expect(dto.rackHeight, equals(10));
      expect(dto.cages!.length, equals(1));
      expect(dto.cages![0].cageTag, equals('C001'));
      expect(dto.racks!.length, equals(1));
      expect(dto.racks![0].rackName, equals('Rack B'));
    });

    test('fromJson with minimal data', () {
      final json = <String, dynamic>{};

      final dto = RackDto.fromJson(json);

      expect(dto.rackId, isNull);
      expect(dto.rackUuid, isNull);
      expect(dto.rackName, isNull);
      expect(dto.rackWidth, isNull);
      expect(dto.rackHeight, isNull);
      expect(dto.cages, isNull);
      expect(dto.racks, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'rackId': 1,
        'rackUuid': 'rack-uuid-1',
        'rackName': 'Rack A',
        'rackWidth': 5,
        'rackHeight': 10,
        'cages': <Map<String, dynamic>>[],
        'racks': <Map<String, dynamic>>[],
      };

      final dto = RackDto.fromJson(json);
      final output = dto.toJson();

      expect(output['rackId'], equals(1));
      expect(output['rackName'], equals('Rack A'));
      expect(output['rackWidth'], equals(5));
      expect(output['cages'], isEmpty);
    });
  });

  group('RackSimpleDto', () {
    test('fromJson with complete data', () {
      final json = {
        'rackId': 1,
        'rackUuid': 'rack-uuid-1',
        'rackName': 'Rack A',
      };

      final dto = RackSimpleDto.fromJson(json);

      expect(dto.rackId, equals(1));
      expect(dto.rackUuid, equals('rack-uuid-1'));
      expect(dto.rackName, equals('Rack A'));
    });

    test('equality', () {
      final dto1 = RackSimpleDto(rackId: 1, rackUuid: 'uuid-1');
      final dto2 = RackSimpleDto(rackId: 1, rackUuid: 'uuid-1');

      expect(dto1, equals(dto2));
    });
  });

  group('RackCageAnimalDto', () {
    test('fromJson with nested objects', () {
      final json = {
        'animalId': 1,
        'animalUuid': 'animal-uuid-1',
        'physicalTag': 'A001',
        'sex': 'M',
        'dateOfBirth': '2024-01-01T00:00:00.000Z',
        'strain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid-1',
          'strainName': 'C57BL/6',
          'color': '#FF0000',
        },
        'genotypes': [
          {
            'id': 1,
            'gene': {
              'geneId': 10,
              'geneUuid': 'gene-uuid-1',
              'geneName': 'Trp53',
            },
            'allele': {
              'alleleId': 20,
              'alleleUuid': 'allele-uuid-1',
              'alleleName': 'knockout',
              'createdDate': '2024-01-01T00:00:00.000Z',
            },
            'order': 0,
          },
        ],
        'litter': {
          'litterId': 1,
          'litterUuid': 'litter-uuid-1',
          'litterTag': 'L001',
        },
      };

      final dto = RackCageAnimalDto.fromJson(json);

      expect(dto.animalId, equals(1));
      expect(dto.animalUuid, equals('animal-uuid-1'));
      expect(dto.physicalTag, equals('A001'));
      expect(dto.sex, equals('M'));
      expect(dto.strain!.strainName, equals('C57BL/6'));
      expect(dto.genotypes!.length, equals(1));
      expect(dto.genotypes![0].gene!.geneName, equals('Trp53'));
      expect(dto.genotypes![0].allele!.alleleName, equals('knockout'));
      expect(dto.litter!.litterTag, equals('L001'));
    });

    test('fromJson with null nested objects', () {
      final json = {
        'animalUuid': 'animal-uuid-1',
      };

      final dto = RackCageAnimalDto.fromJson(json);

      expect(dto.animalId, isNull);
      expect(dto.strain, isNull);
      expect(dto.genotypes, isNull);
      expect(dto.litter, isNull);
    });
  });

  group('RackCageMatingDto', () {
    test('fromJson with complete data', () {
      final json = {
        'matingId': 1,
        'matingUuid': 'mating-uuid-1',
        'matingTag': 'M001',
        'setUpDate': '2024-01-01T00:00:00.000Z',
        'pregnancyDate': '2024-01-15T00:00:00.000Z',
        'comment': 'Test mating',
        'animals': [
          {'animalUuid': 'animal-uuid-1', 'physicalTag': 'A001'},
        ],
        'litterStrain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid-1',
          'strainName': 'C57BL/6',
        },
      };

      final dto = RackCageMatingDto.fromJson(json);

      expect(dto.matingId, equals(1));
      expect(dto.matingUuid, equals('mating-uuid-1'));
      expect(dto.matingTag, equals('M001'));
      expect(dto.animals!.length, equals(1));
      expect(dto.litterStrain!.strainName, equals('C57BL/6'));
    });
  });

  group('RackCageDto', () {
    test('fromJson with complete data', () {
      final json = {
        'cageId': 1,
        'cageTag': 'C001',
        'cageUuid': 'cage-uuid-1',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': 42,
          'role': 'admin',
          'isActive': true,
        },
        'strain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid-1',
          'strainName': 'C57BL/6',
        },
        'animals': <Map<String, dynamic>>[],
        'order': 0,
        'xPosition': 1,
        'yPosition': 2,
        'status': 'active',
      };

      final dto = RackCageDto.fromJson(json);

      expect(dto.cageId, equals(1));
      expect(dto.cageTag, equals('C001'));
      expect(dto.cageUuid, equals('cage-uuid-1'));
      expect(dto.owner!.accountId, equals(1));
      expect(dto.owner!.user, equals(42));
      expect(dto.strain!.strainName, equals('C57BL/6'));
      expect(dto.animals, isEmpty);
      expect(dto.xPosition, equals(1));
      expect(dto.yPosition, equals(2));
      expect(dto.status, equals('active'));
    });

    test('toJson round-trip', () {
      final json = {
        'cageId': 1,
        'cageTag': 'C001',
        'cageUuid': 'cage-uuid-1',
        'status': 'active',
      };

      final dto = RackCageDto.fromJson(json);
      final output = dto.toJson();

      expect(output['cageId'], equals(1));
      expect(output['cageUuid'], equals('cage-uuid-1'));
      expect(output['status'], equals('active'));
    });
  });
}
