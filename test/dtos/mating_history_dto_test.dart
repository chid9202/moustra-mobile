import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/mating_history_dto.dart';

void main() {
  group('MatingHistoryDto', () {
    test('should create from JSON with all fields', () {
      final json = {
        'matingUuid': 'mating-uuid-1',
        'matingTag': 'M001',
        'setUpDate': '2023-06-01T00:00:00Z',
        'disbandedDate': '2023-12-01T00:00:00Z',
        'litterStrain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid-1',
          'strainName': 'C57BL/6',
        },
        'litters': [
          {
            'litterUuid': 'litter-uuid-1',
            'litterTag': 'L001',
            'dateOfBirth': '2023-07-15T00:00:00Z',
            'animals': [
              {
                'animalId': 1,
                'animalUuid': 'animal-uuid-1',
                'physicalTag': 'A001',
                'sex': 'male',
                'dateOfBirth': '2023-07-15T00:00:00Z',
              },
            ],
          },
        ],
      };

      final dto = MatingHistoryDto.fromJson(json);

      expect(dto.matingUuid, 'mating-uuid-1');
      expect(dto.matingTag, 'M001');
      expect(dto.setUpDate, DateTime.parse('2023-06-01T00:00:00Z'));
      expect(dto.disbandedDate, DateTime.parse('2023-12-01T00:00:00Z'));
      expect(dto.litterStrain?.strainName, 'C57BL/6');
      expect(dto.litters?.length, 1);
      expect(dto.litters?.first.litterTag, 'L001');
    });

    test('should create from JSON with minimal fields', () {
      final json = {'matingUuid': 'mating-uuid-1'};

      final dto = MatingHistoryDto.fromJson(json);

      expect(dto.matingUuid, 'mating-uuid-1');
      expect(dto.matingTag, null);
      expect(dto.setUpDate, null);
      expect(dto.disbandedDate, null);
      expect(dto.litterStrain, null);
      expect(dto.litters, null);
    });

    test('should handle null optional fields', () {
      final json = {
        'matingUuid': 'mating-uuid-1',
        'matingTag': null,
        'setUpDate': null,
        'disbandedDate': null,
        'litterStrain': null,
        'litters': null,
      };

      final dto = MatingHistoryDto.fromJson(json);

      expect(dto.matingUuid, 'mating-uuid-1');
      expect(dto.matingTag, null);
      expect(dto.setUpDate, null);
      expect(dto.disbandedDate, null);
      expect(dto.litterStrain, null);
      expect(dto.litters, null);
    });

    test('should convert to JSON and back', () {
      final dto = MatingHistoryDto(
        matingUuid: 'mating-uuid-1',
        matingTag: 'M001',
        setUpDate: DateTime(2023, 6, 1),
        disbandedDate: DateTime(2023, 12, 1),
      );

      final json = dto.toJson();
      final roundTripped = MatingHistoryDto.fromJson(json);

      expect(roundTripped.matingUuid, dto.matingUuid);
      expect(roundTripped.matingTag, dto.matingTag);
      expect(roundTripped.setUpDate, dto.setUpDate);
      expect(roundTripped.disbandedDate, dto.disbandedDate);
    });
  });

  group('MatingHistoryLitterDto', () {
    test('should create from JSON with all fields', () {
      final json = {
        'litterUuid': 'litter-uuid-1',
        'litterTag': 'L001',
        'dateOfBirth': '2023-07-15T00:00:00Z',
        'animals': [
          {
            'animalId': 1,
            'animalUuid': 'animal-uuid-1',
            'physicalTag': 'A001',
            'sex': 'male',
            'dateOfBirth': '2023-07-15T00:00:00Z',
          },
          {
            'animalId': 2,
            'animalUuid': 'animal-uuid-2',
            'physicalTag': 'A002',
            'sex': 'female',
            'dateOfBirth': '2023-07-15T00:00:00Z',
          },
        ],
      };

      final dto = MatingHistoryLitterDto.fromJson(json);

      expect(dto.litterUuid, 'litter-uuid-1');
      expect(dto.litterTag, 'L001');
      expect(dto.dateOfBirth, DateTime.parse('2023-07-15T00:00:00Z'));
      expect(dto.animals?.length, 2);
      expect(dto.animals?.first.physicalTag, 'A001');
      expect(dto.animals?.last.sex, 'female');
    });

    test('should create from JSON with minimal fields', () {
      final json = {'litterUuid': 'litter-uuid-1'};

      final dto = MatingHistoryLitterDto.fromJson(json);

      expect(dto.litterUuid, 'litter-uuid-1');
      expect(dto.litterTag, null);
      expect(dto.dateOfBirth, null);
      expect(dto.animals, null);
    });

    test('should handle empty animals list', () {
      final json = {
        'litterUuid': 'litter-uuid-1',
        'animals': [],
      };

      final dto = MatingHistoryLitterDto.fromJson(json);

      expect(dto.animals, isEmpty);
    });

    test('should convert to JSON and back', () {
      final dto = MatingHistoryLitterDto(
        litterUuid: 'litter-uuid-1',
        litterTag: 'L001',
        dateOfBirth: DateTime(2023, 7, 15),
      );

      final json = dto.toJson();
      final roundTripped = MatingHistoryLitterDto.fromJson(json);

      expect(roundTripped.litterUuid, dto.litterUuid);
      expect(roundTripped.litterTag, dto.litterTag);
      expect(roundTripped.dateOfBirth, dto.dateOfBirth);
    });
  });
}
