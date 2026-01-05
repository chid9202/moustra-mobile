import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/animal_dto.dart';

void main() {
  group('AnimalDto Tests', () {
    test('should create AnimalDto from JSON', () {
      // Arrange
      final json = {
        'eid': 1,
        'animalId': 1,
        'animalUuid': 'test-uuid',
        'physicalTag': 'A001',
        'dateOfBirth': '2023-01-01',
        'sex': 'male',
        'genotypes': [
          {
            'id': 1,
            'gene': {'geneId': 1, 'geneUuid': 'gene-uuid', 'geneName': 'Gene1'},
            'allele': {
              'alleleId': 1,
              'alleleUuid': 'allele-uuid',
              'alleleName': 'Allele1',
              'createdDate': '2023-01-01T00:00:00Z',
            },
            'order': 1,
          },
        ],
        'weanDate': '2023-02-01',
        'endDate': '2023-12-01',
        'owner': {
          'accountId': 1,
          'accountUuid': 'account-uuid',
          'user': {
            'email': 'test@example.com',
            'firstName': 'Test',
            'lastName': 'User',
          },
        },
        'cage': {'cageId': 1, 'cageUuid': 'cage-uuid', 'cageTag': 'C001'},
        'strain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid',
          'strainName': 'C57BL/6',
        },
        'comment': 'Test comment',
        'createdDate': '2023-01-01T00:00:00Z',
        'updatedDate': '2023-01-02T00:00:00Z',
        'sire': {
          'animalId': 2,
          'animalUuid': 'sire-uuid',
          'physicalTag': 'S001',
        },
        'dam': [
          {'animalId': 3, 'animalUuid': 'dam-uuid', 'physicalTag': 'D001'},
        ],
      };

      // Act
      final animalDto = AnimalDto.fromJson(json);

      // Assert
      expect(animalDto.eid, 1);
      expect(animalDto.animalId, 1);
      expect(animalDto.animalUuid, 'test-uuid');
      expect(animalDto.physicalTag, 'A001');
      expect(animalDto.dateOfBirth, DateTime(2023, 1, 1));
      expect(animalDto.sex, 'male');
      expect(animalDto.genotypes?.length, 1);
      expect(animalDto.genotypes?.first.gene?.geneName, 'Gene1');
      expect(animalDto.weanDate, DateTime(2023, 2, 1));
      expect(animalDto.endDate, DateTime(2023, 12, 1));
      expect(animalDto.owner?.accountId, 1);
      expect(animalDto.cage?.cageTag, 'C001');
      expect(animalDto.strain?.strainName, 'C57BL/6');
      expect(animalDto.comment, 'Test comment');
      expect(animalDto.createdDate, DateTime.parse('2023-01-01T00:00:00Z'));
      expect(animalDto.updatedDate, DateTime.parse('2023-01-02T00:00:00Z'));
      expect(animalDto.sire?.physicalTag, 'S001');
      expect(animalDto.dam?.length, 1);
      expect(animalDto.dam?.first.physicalTag, 'D001');
    });

    test('should create AnimalDto with minimal required fields', () {
      // Arrange
      final json = {'eid': 1, 'animalId': 1, 'animalUuid': 'test-uuid'};

      // Act
      final animalDto = AnimalDto.fromJson(json);

      // Assert
      expect(animalDto.eid, 1);
      expect(animalDto.animalId, 1);
      expect(animalDto.animalUuid, 'test-uuid');
      expect(animalDto.physicalTag, null);
      expect(animalDto.dateOfBirth, null);
      expect(animalDto.sex, null);
      expect(animalDto.genotypes, []);
      expect(animalDto.weanDate, null);
      expect(animalDto.endDate, null);
      expect(animalDto.owner, null);
      expect(animalDto.cage, null);
      expect(animalDto.strain, null);
      expect(animalDto.comment, null);
      expect(animalDto.createdDate, null);
      expect(animalDto.updatedDate, null);
      expect(animalDto.sire, null);
      expect(animalDto.dam, []);
    });

    test('should convert AnimalDto to JSON', () {
      // Arrange
      final animalDto = AnimalDto(
        eid: 1,
        animalId: 1,
        animalUuid: 'test-uuid',
        physicalTag: 'A001',
        dateOfBirth: DateTime(2023, 1, 1),
        sex: 'male',
        comment: 'Test comment',
      );

      // Act
      final json = animalDto.toJson();

      // Assert
      expect(json['eid'], 1);
      expect(json['animalId'], 1);
      expect(json['animalUuid'], 'test-uuid');
      expect(json['physicalTag'], 'A001');
      expect(json['dateOfBirth'], '2023-01-01T00:00:00.000');
      expect(json['sex'], 'male');
      expect(json['comment'], 'Test comment');
    });

    test('should handle null optional fields in JSON', () {
      // Arrange
      final json = {
        'eid': 1,
        'animalId': 1,
        'animalUuid': 'test-uuid',
        'physicalTag': null,
        'dateOfBirth': null,
        'sex': null,
        'genotypes': null,
        'weanDate': null,
        'endDate': null,
        'owner': null,
        'cage': null,
        'strain': null,
        'comment': null,
        'createdDate': null,
        'updatedDate': null,
        'sire': null,
        'dam': null,
      };

      // Act
      final animalDto = AnimalDto.fromJson(json);

      // Assert
      expect(animalDto.eid, 1);
      expect(animalDto.animalId, 1);
      expect(animalDto.animalUuid, 'test-uuid');
      expect(animalDto.physicalTag, null);
      expect(animalDto.dateOfBirth, null);
      expect(animalDto.sex, null);
      expect(animalDto.genotypes, []);
      expect(animalDto.weanDate, null);
      expect(animalDto.endDate, null);
      expect(animalDto.owner, null);
      expect(animalDto.cage, null);
      expect(animalDto.strain, null);
      expect(animalDto.comment, null);
      expect(animalDto.createdDate, null);
      expect(animalDto.updatedDate, null);
      expect(animalDto.sire, null);
      expect(animalDto.dam, []);
    });
  });

  group('AnimalSummaryDto Tests', () {
    test('should create AnimalSummaryDto from JSON', () {
      // Arrange
      final json = {
        'animalId': 1,
        'animalUuid': 'test-uuid',
        'physicalTag': 'A001',
        'dateOfBirth': '2023-01-01',
        'sex': 'male',
      };

      // Act
      final animalSummaryDto = AnimalSummaryDto.fromJson(json);

      // Assert
      expect(animalSummaryDto.animalId, 1);
      expect(animalSummaryDto.animalUuid, 'test-uuid');
      expect(animalSummaryDto.physicalTag, 'A001');
      expect(animalSummaryDto.dateOfBirth, DateTime(2023, 1, 1));
      expect(animalSummaryDto.sex, 'male');
    });

    test('should create AnimalSummaryDto with minimal required fields', () {
      // Arrange
      final json = {'animalId': 1, 'animalUuid': 'test-uuid'};

      // Act
      final animalSummaryDto = AnimalSummaryDto.fromJson(json);

      // Assert
      expect(animalSummaryDto.animalId, 1);
      expect(animalSummaryDto.animalUuid, 'test-uuid');
      expect(animalSummaryDto.physicalTag, null);
      expect(animalSummaryDto.dateOfBirth, null);
      expect(animalSummaryDto.sex, null);
    });

    test('should convert AnimalSummaryDto to JSON', () {
      // Arrange
      final animalSummaryDto = AnimalSummaryDto(
        animalId: 1,
        animalUuid: 'test-uuid',
        physicalTag: 'A001',
        dateOfBirth: DateTime(2023, 1, 1),
        sex: 'male',
      );

      // Act
      final json = animalSummaryDto.toJson();

      // Assert
      expect(json['animalId'], 1);
      expect(json['animalUuid'], 'test-uuid');
      expect(json['physicalTag'], 'A001');
      expect(json['dateOfBirth'], '2023-01-01T00:00:00.000');
      expect(json['sex'], 'male');
    });
  });

  group('PostAnimalDto Tests', () {
    test('should create PostAnimalDto from JSON', () {
      // Arrange
      final json = {
        'animals': [
          {
            'idx': '0',
            'dateOfBirth': '2023-01-01',
            'genotypes': [],
            'physicalTag': 'A001',
            'sex': 'male',
          },
        ],
      };

      // Act
      final postAnimalDto = PostAnimalDto.fromJson(json);

      // Assert
      expect(postAnimalDto.animals.length, 1);
      expect(postAnimalDto.animals.first.idx, '0');
      expect(postAnimalDto.animals.first.dateOfBirth, DateTime(2023, 1, 1));
      expect(postAnimalDto.animals.first.genotypes, []);
      expect(postAnimalDto.animals.first.physicalTag, 'A001');
      expect(postAnimalDto.animals.first.sex, 'male');
    });

    test('should convert PostAnimalDto to JSON', () {
      // Arrange
      final postAnimalDto = PostAnimalDto(
        animals: [
          PostAnimalData(
            idx: '0',
            dateOfBirth: DateTime(2023, 1, 1),
            genotypes: [],
            physicalTag: 'A001',
            sex: 'male',
          ),
        ],
      );

      // Act
      final json = postAnimalDto.toJson();

      // Assert
      expect(json['animals'], isA<List>());
      expect(json['animals'].length, 1);
      expect(json['animals'][0]['idx'], '0');
      expect(json['animals'][0]['dateOfBirth'], '2023-01-01T00:00:00.000');
      expect(json['animals'][0]['genotypes'], []);
      expect(json['animals'][0]['physicalTag'], 'A001');
      expect(json['animals'][0]['sex'], 'male');
    });
  });

  group('PostAnimalData Tests', () {
    test('should create PostAnimalData from JSON', () {
      // Arrange
      final json = {
        'idx': '0',
        'dateOfBirth': '2023-01-01',
        'genotypes': [],
        'physicalTag': 'A001',
        'sex': 'male',
      };

      // Act
      final postAnimalData = PostAnimalData.fromJson(json);

      // Assert
      expect(postAnimalData.idx, '0');
      expect(postAnimalData.dateOfBirth, DateTime(2023, 1, 1));
      expect(postAnimalData.genotypes, []);
      expect(postAnimalData.physicalTag, 'A001');
      expect(postAnimalData.sex, 'male');
    });

    test('should convert PostAnimalData to JSON', () {
      // Arrange
      final postAnimalData = PostAnimalData(
        idx: '0',
        dateOfBirth: DateTime(2023, 1, 1),
        genotypes: [],
        physicalTag: 'A001',
        sex: 'male',
      );

      // Act
      final json = postAnimalData.toJson();

      // Assert
      expect(json['idx'], '0');
      expect(json['dateOfBirth'], '2023-01-01T00:00:00.000');
      expect(json['genotypes'], []);
      expect(json['physicalTag'], 'A001');
      expect(json['sex'], 'male');
    });
  });
}
