import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/litter_dto.dart';

void main() {
  group('LitterDto Tests', () {
    test('should create LitterDto from JSON with strain', () {
      // Arrange
      final json = {
        'eid': 1,
        'litterUuid': 'test-litter-uuid',
        'litterTag': 'L001',
        'weanDate': '2023-02-15',
        'dateOfBirth': '2023-01-15',
        'strain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid',
          'strainName': 'C57BL/6',
          'color': '#000000',
        },
        'mating': {
          'matingId': 1,
          'matingUuid': 'mating-uuid',
          'matingTag': 'M001',
        },
        'owner': {
          'accountId': 1,
          'accountUuid': 'account-uuid',
          'user': {
            'email': 'test@example.com',
            'firstName': 'Test',
            'lastName': 'User',
          },
        },
        'animals': [
          {
            'animalId': 1,
            'animalUuid': 'animal-uuid-1',
            'physicalTag': 'A001',
            'sex': 'male',
            'dateOfBirth': '2023-01-15',
          },
        ],
        'comment': 'Test litter',
        'createdDate': '2023-01-01T00:00:00Z',
      };

      // Act
      final litterDto = LitterDto.fromJson(json);

      // Assert
      expect(litterDto.eid, 1);
      expect(litterDto.litterUuid, 'test-litter-uuid');
      expect(litterDto.litterTag, 'L001');
      expect(litterDto.strain?.strainName, 'C57BL/6');
      expect(litterDto.strain?.strainUuid, 'strain-uuid');
      expect(litterDto.mating?.matingUuid, 'mating-uuid');
      expect(litterDto.animals.length, 1);
      expect(litterDto.animals.first.physicalTag, 'A001');
      expect(litterDto.comment, 'Test litter');
    });

    test('should create LitterDto with minimal required fields', () {
      // Arrange
      final json = {
        'litterUuid': 'test-litter-uuid',
      };

      // Act
      final litterDto = LitterDto.fromJson(json);

      // Assert
      expect(litterDto.litterUuid, 'test-litter-uuid');
      expect(litterDto.eid, null);
      expect(litterDto.litterTag, null);
      expect(litterDto.strain, null);
      expect(litterDto.mating, null);
      expect(litterDto.owner, null);
      expect(litterDto.animals, []);
    });

    test('should convert LitterDto to JSON with strain', () {
      // Arrange
      final litterDto = LitterDto(
        eid: 1,
        litterUuid: 'test-litter-uuid',
        litterTag: 'L001',
        dateOfBirth: DateTime(2023, 1, 15),
        comment: 'Test litter',
      );

      // Act
      final json = litterDto.toJson();

      // Assert
      expect(json['eid'], 1);
      expect(json['litterUuid'], 'test-litter-uuid');
      expect(json['litterTag'], 'L001');
      expect(json['comment'], 'Test litter');
    });

    test('should handle null strain field', () {
      // Arrange
      final json = {
        'litterUuid': 'test-litter-uuid',
        'strain': null,
        'mating': {
          'matingId': 1,
          'matingUuid': 'mating-uuid',
        },
      };

      // Act
      final litterDto = LitterDto.fromJson(json);

      // Assert
      expect(litterDto.litterUuid, 'test-litter-uuid');
      expect(litterDto.strain, null);
      expect(litterDto.mating?.matingUuid, 'mating-uuid');
    });

    test('should handle strain without mating', () {
      // Arrange - strain is now directly on litter, not via mating
      final json = {
        'litterUuid': 'test-litter-uuid',
        'strain': {
          'strainId': 2,
          'strainUuid': 'strain-uuid-2',
          'strainName': 'BALB/c',
        },
        'mating': null,
      };

      // Act
      final litterDto = LitterDto.fromJson(json);

      // Assert
      expect(litterDto.strain?.strainName, 'BALB/c');
      expect(litterDto.mating, null);
    });
  });

  group('LitterAnimalDto Tests', () {
    test('should create LitterAnimalDto from JSON', () {
      // Arrange
      final json = {
        'animalId': 1,
        'animalUuid': 'animal-uuid',
        'physicalTag': 'A001',
        'sex': 'female',
        'dateOfBirth': '2023-01-15',
      };

      // Act
      final animalDto = LitterAnimalDto.fromJson(json);

      // Assert
      expect(animalDto.animalId, 1);
      expect(animalDto.animalUuid, 'animal-uuid');
      expect(animalDto.physicalTag, 'A001');
      expect(animalDto.sex, 'female');
    });

    test('should handle minimal LitterAnimalDto', () {
      // Arrange
      final json = {
        'animalId': 1,
        'animalUuid': 'animal-uuid',
      };

      // Act
      final animalDto = LitterAnimalDto.fromJson(json);

      // Assert
      expect(animalDto.animalId, 1);
      expect(animalDto.animalUuid, 'animal-uuid');
      expect(animalDto.physicalTag, null);
      expect(animalDto.sex, null);
    });
  });
}
