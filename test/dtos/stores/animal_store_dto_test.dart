import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';

void main() {
  group('AnimalStoreDto', () {
    test('fromJson with complete data', () {
      final json = {
        'eid': 100,
        'animalId': 1,
        'animalUuid': 'animal-uuid-1',
        'physicalTag': 'A001',
        'isEnded': false,
        'sex': 'M',
        'dateOfBirth': '2024-01-01T00:00:00.000Z',
        'weanDate': '2024-01-22T00:00:00.000Z',
      };

      final dto = AnimalStoreDto.fromJson(json);

      expect(dto.eid, equals(100));
      expect(dto.animalId, equals(1));
      expect(dto.animalUuid, equals('animal-uuid-1'));
      expect(dto.physicalTag, equals('A001'));
      expect(dto.isEnded, isFalse);
      expect(dto.sex, equals('M'));
      expect(dto.dateOfBirth, isNotNull);
      expect(dto.weanDate, isNotNull);
    });

    test('fromJson with minimal data', () {
      final json = {
        'eid': 200,
        'animalId': 2,
        'animalUuid': 'animal-uuid-2',
      };

      final dto = AnimalStoreDto.fromJson(json);

      expect(dto.eid, equals(200));
      expect(dto.animalId, equals(2));
      expect(dto.physicalTag, isNull);
      expect(dto.isEnded, isNull);
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
        'isEnded': false,
        'sex': 'F',
        'dateOfBirth': '2024-01-01T00:00:00.000Z',
        'weanDate': '2024-01-22T00:00:00.000Z',
      };

      final dto = AnimalStoreDto.fromJson(json);
      final output = dto.toJson();

      expect(output['eid'], equals(100));
      expect(output['animalId'], equals(1));
      expect(output['animalUuid'], equals('animal-uuid-1'));
      expect(output['physicalTag'], equals('A001'));
      expect(output['isEnded'], isFalse);
      expect(output['sex'], equals('F'));
    });

    test('toAnimalSummaryDto converts correctly', () {
      final dto = AnimalStoreDto(
        eid: 100,
        animalId: 1,
        animalUuid: 'animal-uuid-1',
        physicalTag: 'A001',
        sex: 'M',
        dateOfBirth: DateTime(2024, 1, 1),
      );

      final summary = dto.toAnimalSummaryDto();

      expect(summary.animalId, equals(1));
      expect(summary.animalUuid, equals('animal-uuid-1'));
      expect(summary.physicalTag, equals('A001'));
      expect(summary.dateOfBirth, equals(DateTime(2024, 1, 1)));
      expect(summary.sex, equals('M'));
    });
  });
}
