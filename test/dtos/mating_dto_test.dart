import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/mating_dto.dart';

void main() {
  group('MatingDto Tests', () {
    test('should create MatingDto from JSON', () {
      // Arrange
      final json = {
        'matingId': 1,
        'matingUuid': 'test-mating-uuid',
        'matingTag': 'M001',
        'animals': [
          {
            'animalId': 1,
            'animalUuid': 'animal-uuid-1',
            'physicalTag': 'A001',
            'dateOfBirth': '2023-01-01',
            'sex': 'male',
          },
          {
            'animalId': 2,
            'animalUuid': 'animal-uuid-2',
            'physicalTag': 'A002',
            'dateOfBirth': '2023-01-02',
            'sex': 'female',
          },
        ],
        'setUpDate': '2023-01-01T00:00:00Z',
        'pregnancyDate': '2023-02-01T00:00:00Z',
        'disbandedDate': '2023-12-01T00:00:00Z',
        'comment': 'Test mating comment',
        'createdDate': '2023-01-01T00:00:00Z',
      };

      // Act
      final matingDto = MatingDto.fromJson(json);

      // Assert
      expect(matingDto.matingId, 1);
      expect(matingDto.matingUuid, 'test-mating-uuid');
      expect(matingDto.matingTag, 'M001');
      expect(matingDto.animals?.length, 2);
      expect(matingDto.animals?.first.physicalTag, 'A001');
      expect(matingDto.animals?.last.physicalTag, 'A002');
      expect(matingDto.setUpDate, DateTime.parse('2023-01-01T00:00:00Z'));
      expect(matingDto.pregnancyDate, DateTime.parse('2023-02-01T00:00:00Z'));
      expect(matingDto.disbandedDate, DateTime.parse('2023-12-01T00:00:00Z'));
      expect(matingDto.comment, 'Test mating comment');
      expect(matingDto.createdDate, DateTime.parse('2023-01-01T00:00:00Z'));
    });

    test('should create MatingDto with minimal required fields', () {
      // Arrange
      final json = {'matingId': 1, 'matingUuid': 'test-mating-uuid'};

      // Act
      final matingDto = MatingDto.fromJson(json);

      // Assert
      expect(matingDto.matingId, 1);
      expect(matingDto.matingUuid, 'test-mating-uuid');
      expect(matingDto.matingTag, null);
      expect(matingDto.animals, []);
      expect(matingDto.setUpDate, null);
      expect(matingDto.pregnancyDate, null);
      expect(matingDto.disbandedDate, null);
      expect(matingDto.comment, null);
      expect(matingDto.createdDate, null);
    });

    test('should convert MatingDto to JSON', () {
      // Arrange
      final matingDto = MatingDto(
        matingId: 1,
        matingUuid: 'test-mating-uuid',
        matingTag: 'M001',
        setUpDate: DateTime(2023, 1, 1),
        comment: 'Test mating comment',
      );

      // Act
      final json = matingDto.toJson();

      // Assert
      expect(json['matingId'], 1);
      expect(json['matingUuid'], 'test-mating-uuid');
      expect(json['matingTag'], 'M001');
      expect(json['setUpDate'], '2023-01-01T00:00:00.000');
      expect(json['comment'], 'Test mating comment');
    });

    test('should handle null optional fields in JSON', () {
      // Arrange
      final json = {
        'matingId': 1,
        'matingUuid': 'test-mating-uuid',
        'matingTag': null,
        'animals': null,
        'setUpDate': null,
        'pregnancyDate': null,
        'disbandedDate': null,
        'comment': null,
        'createdDate': null,
      };

      // Act
      final matingDto = MatingDto.fromJson(json);

      // Assert
      expect(matingDto.matingId, 1);
      expect(matingDto.matingUuid, 'test-mating-uuid');
      expect(matingDto.matingTag, null);
      expect(matingDto.animals, []);
      expect(matingDto.setUpDate, null);
      expect(matingDto.pregnancyDate, null);
      expect(matingDto.disbandedDate, null);
      expect(matingDto.comment, null);
      expect(matingDto.createdDate, null);
    });

    test('should handle empty animals list', () {
      // Arrange
      final json = {
        'matingId': 1,
        'matingUuid': 'test-mating-uuid',
        'animals': [],
      };

      // Act
      final matingDto = MatingDto.fromJson(json);

      // Assert
      expect(matingDto.matingId, 1);
      expect(matingDto.matingUuid, 'test-mating-uuid');
      expect(matingDto.animals, []);
    });
  });
}
