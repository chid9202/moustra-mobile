import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

void main() {
  group('StrainDto', () {
    test('fromJson with complete data', () {
      final json = {
        'strainId': 1,
        'strainUuid': 'strain-uuid-1',
        'strainName': 'C57BL/6',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'weanAge': 21,
        'tagPrefix': 'C57',
        'comment': 'A common strain',
        'createdDate': '2024-01-01T00:00:00.000Z',
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
            },
            'order': 0,
          },
        ],
        'color': '#FF0000',
        'numberOfAnimals': 42,
        'backgrounds': [
          {'id': 1, 'uuid': 'bg-uuid-1', 'name': 'C57BL/6J'},
        ],
        'isActive': true,
      };

      final dto = StrainDto.fromJson(json);

      expect(dto.strainId, equals(1));
      expect(dto.strainUuid, equals('strain-uuid-1'));
      expect(dto.strainName, equals('C57BL/6'));
      expect(dto.owner.accountUuid, equals('owner-uuid-1'));
      expect(dto.weanAge, equals(21));
      expect(dto.tagPrefix, equals('C57'));
      expect(dto.comment, equals('A common strain'));
      expect(dto.genotypes.length, equals(1));
      expect(dto.genotypes[0].gene!.geneName, equals('Trp53'));
      expect(dto.color, equals('#FF0000'));
      expect(dto.numberOfAnimals, equals(42));
      expect(dto.backgrounds.length, equals(1));
      expect(dto.backgrounds[0].name, equals('C57BL/6J'));
      expect(dto.isActive, isTrue);
    });

    test('fromJson with minimal data', () {
      final json = {
        'strainId': 1,
        'strainUuid': 'strain-uuid-1',
        'strainName': 'C57BL/6',
        'owner': {
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'createdDate': '2024-01-01T00:00:00.000Z',
        'genotypes': <Map<String, dynamic>>[],
      };

      final dto = StrainDto.fromJson(json);

      expect(dto.weanAge, isNull);
      expect(dto.tagPrefix, isNull);
      expect(dto.comment, isNull);
      expect(dto.color, isNull);
      expect(dto.numberOfAnimals, equals(0));
      expect(dto.backgrounds, isEmpty);
      expect(dto.isActive, isTrue);
    });

    test('toJson round-trip', () {
      final json = {
        'strainId': 1,
        'strainUuid': 'strain-uuid-1',
        'strainName': 'C57BL/6',
        'owner': {
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'createdDate': '2024-01-01T00:00:00.000Z',
        'genotypes': <Map<String, dynamic>>[],
        'isActive': true,
      };

      final dto = StrainDto.fromJson(json);
      final output = dto.toJson();

      expect(output['strainId'], equals(1));
      expect(output['strainUuid'], equals('strain-uuid-1'));
      expect(output['strainName'], equals('C57BL/6'));
      expect(output['isActive'], isTrue);
    });
  });

  group('StrainSummaryDto', () {
    test('fromJson with complete data', () {
      final json = {
        'strainId': 1,
        'strainUuid': 'strain-uuid-1',
        'strainName': 'C57BL/6',
        'color': '#FF0000',
        'weanAge': 21,
      };

      final dto = StrainSummaryDto.fromJson(json);

      expect(dto.strainId, equals(1));
      expect(dto.strainName, equals('C57BL/6'));
      expect(dto.color, equals('#FF0000'));
      expect(dto.weanAge, equals(21));
    });

    test('fromJson with minimal data', () {
      final json = {
        'strainId': 1,
        'strainUuid': 'strain-uuid-1',
        'strainName': 'C57BL/6',
      };

      final dto = StrainSummaryDto.fromJson(json);

      expect(dto.color, isNull);
      expect(dto.weanAge, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'strainId': 1,
        'strainUuid': 'strain-uuid-1',
        'strainName': 'C57BL/6',
        'color': '#FF0000',
        'weanAge': 21,
      };

      final dto = StrainSummaryDto.fromJson(json);
      final output = dto.toJson();

      expect(output['strainId'], equals(json['strainId']));
      expect(output['color'], equals(json['color']));
    });
  });

  group('StrainBackgroundDto', () {
    test('fromJson with complete data', () {
      final json = {'id': 1, 'uuid': 'bg-uuid-1', 'name': 'C57BL/6J'};
      final dto = StrainBackgroundDto.fromJson(json);

      expect(dto.id, equals(1));
      expect(dto.uuid, equals('bg-uuid-1'));
      expect(dto.name, equals('C57BL/6J'));
    });

    test('fromJson with missing values defaults', () {
      final json = <String, dynamic>{};
      final dto = StrainBackgroundDto.fromJson(json);

      expect(dto.id, equals(0));
      expect(dto.uuid, equals(''));
      expect(dto.name, equals(''));
    });

    test('toJson round-trip', () {
      final json = {'id': 1, 'uuid': 'bg-uuid-1', 'name': 'C57BL/6J'};
      final dto = StrainBackgroundDto.fromJson(json);
      final output = dto.toJson();

      expect(output['id'], equals(1));
      expect(output['uuid'], equals('bg-uuid-1'));
      expect(output['name'], equals('C57BL/6J'));
    });
  });
}
