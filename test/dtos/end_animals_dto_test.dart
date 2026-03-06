import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/end_animals_dto.dart';

void main() {
  group('EndAnimalFormDto', () {
    test('should create from JSON with all fields', () {
      final json = {
        'endDate': '2026-03-15',
        'endType': 'euthanasia',
        'endReason': 'protocol_end',
        'endComment': 'Study complete',
        'endCage': true,
      };

      final dto = EndAnimalFormDto.fromJson(json);

      expect(dto.endDate, '2026-03-15');
      expect(dto.endType, 'euthanasia');
      expect(dto.endReason, 'protocol_end');
      expect(dto.endComment, 'Study complete');
      expect(dto.endCage, true);
    });

    test('should create from JSON with minimal fields', () {
      final json = {
        'endDate': '2026-03-15',
      };

      final dto = EndAnimalFormDto.fromJson(json);

      expect(dto.endDate, '2026-03-15');
      expect(dto.endType, isNull);
      expect(dto.endReason, isNull);
      expect(dto.endComment, isNull);
      expect(dto.endCage, false);
    });

    test('should default endCage to false when missing', () {
      final json = {'endDate': '2026-03-01'};

      final dto = EndAnimalFormDto.fromJson(json);

      expect(dto.endCage, false);
    });

    test('should convert to JSON', () {
      final dto = EndAnimalFormDto(
        endDate: '2026-03-20',
        endType: 'euthanasia',
        endCage: false,
      );

      final json = dto.toJson();

      expect(json['endDate'], '2026-03-20');
      expect(json['endType'], 'euthanasia');
      expect(json['endCage'], false);
    });
  });

  group('EndAnimalsResponseDto', () {
    test('should create from JSON with animals, endTypes, endReasons', () {
      final json = {
        'animals': [
          {
            'eid': 100,
            'animalId': 1,
            'animalUuid': 'animal-uuid-1',
            'physicalTag': 'A001',
            'sex': 'male',
            'dateOfBirth': '2024-01-01T00:00:00.000',
          },
        ],
        'endTypes': [
          {
            'endTypeId': 1,
            'endTypeUuid': 'et-uuid-1',
            'endTypeName': 'Euthanasia',
          },
        ],
        'endReasons': [
          {
            'endReasonId': 1,
            'endReasonUuid': 'er-uuid-1',
            'endReasonName': 'Protocol end',
          },
        ],
      };

      final dto = EndAnimalsResponseDto.fromJson(json);

      expect(dto.animals.length, 1);
      expect(dto.animals.first.physicalTag, 'A001');
      expect(dto.endTypes.length, 1);
      expect(dto.endTypes.first.endTypeName, 'Euthanasia');
      expect(dto.endReasons.length, 1);
      expect(dto.endReasons.first.endReasonName, 'Protocol end');
    });
  });
}
