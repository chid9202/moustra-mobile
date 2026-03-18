import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/post_mating_dto.dart';

void main() {
  group('PostMatingDto', () {
    test('fromJson with complete data', () {
      final json = {
        'matingTag': 'M001',
        'maleAnimal': 'male-uuid-1',
        'femaleAnimals': ['female-uuid-1', 'female-uuid-2'],
        'cage': {
          'cageId': 1,
          'cageUuid': 'cage-uuid-1',
          'cageTag': 'C001',
          'animals': <Map<String, dynamic>>[],
        },
        'litterStrain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid-1',
          'strainName': 'C57BL/6',
          'genotypes': <Map<String, dynamic>>[],
        },
        'setUpDate': '2024-01-01T00:00:00.000Z',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'comment': 'Test mating',
      };

      final dto = PostMatingDto.fromJson(json);

      expect(dto.matingTag, equals('M001'));
      expect(dto.maleAnimal, equals('male-uuid-1'));
      expect(dto.femaleAnimals, equals(['female-uuid-1', 'female-uuid-2']));
      expect(dto.cage, isNotNull);
      expect(dto.cage!.cageId, equals(1));
      expect(dto.litterStrain, isNotNull);
      expect(dto.litterStrain!.strainName, equals('C57BL/6'));
      expect(dto.setUpDate.year, equals(2024));
      expect(dto.owner.accountId, equals(1));
      expect(dto.comment, equals('Test mating'));
    });

    test('fromJson with minimal data', () {
      final json = {
        'matingTag': 'M001',
        'maleAnimal': 'male-uuid-1',
        'femaleAnimals': ['female-uuid-1'],
        'setUpDate': '2024-01-01T00:00:00.000Z',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
      };

      final dto = PostMatingDto.fromJson(json);

      expect(dto.cage, isNull);
      expect(dto.litterStrain, isNull);
      expect(dto.comment, isNull);
    });

    test('fromJson with empty femaleAnimals list', () {
      final json = {
        'matingTag': 'M001',
        'maleAnimal': 'male-uuid-1',
        'femaleAnimals': <String>[],
        'setUpDate': '2024-01-01T00:00:00.000Z',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
      };

      final dto = PostMatingDto.fromJson(json);

      expect(dto.femaleAnimals, isEmpty);
    });

    test('toJson round-trip', () {
      final json = {
        'matingTag': 'M001',
        'maleAnimal': 'male-uuid-1',
        'femaleAnimals': ['female-uuid-1'],
        'setUpDate': '2024-01-01T00:00:00.000Z',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'comment': 'Test',
      };

      final dto = PostMatingDto.fromJson(json);
      final output = dto.toJson();

      expect(output['matingTag'], equals('M001'));
      expect(output['maleAnimal'], equals('male-uuid-1'));
      expect(output['femaleAnimals'], equals(['female-uuid-1']));
      expect(output['comment'], equals('Test'));
    });
  });
}
