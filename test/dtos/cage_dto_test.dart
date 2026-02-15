import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/cage_dto.dart';

void main() {
  group('CageDto', () {
    test('should create from JSON with matingHistory', () {
      final json = {
        'cageId': 1,
        'cageTag': 'C001',
        'cageUuid': 'cage-uuid-1',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {
            'firstName': 'John',
            'lastName': 'Doe',
            'email': 'john@example.com',
          },
        },
        'status': 'active',
        'animals': [],
        'matingHistory': [
          {
            'matingUuid': 'mating-uuid-1',
            'matingTag': 'M001',
            'setUpDate': '2023-06-01T00:00:00Z',
            'litters': [
              {
                'litterUuid': 'litter-uuid-1',
                'litterTag': 'L001',
                'dateOfBirth': '2023-07-15T00:00:00Z',
              },
            ],
          },
          {
            'matingUuid': 'mating-uuid-2',
            'matingTag': 'M002',
            'disbandedDate': '2023-11-01T00:00:00Z',
          },
        ],
      };

      final cage = CageDto.fromJson(json);

      expect(cage.cageId, 1);
      expect(cage.cageTag, 'C001');
      expect(cage.matingHistory, isNotNull);
      expect(cage.matingHistory!.length, 2);
      expect(cage.matingHistory![0].matingTag, 'M001');
      expect(cage.matingHistory![0].litters?.length, 1);
      expect(cage.matingHistory![0].litters?.first.litterTag, 'L001');
      expect(cage.matingHistory![1].matingTag, 'M002');
      expect(cage.matingHistory![1].disbandedDate, isNotNull);
    });

    test('should create from JSON without matingHistory', () {
      final json = {
        'cageId': 1,
        'cageTag': 'C001',
        'cageUuid': 'cage-uuid-1',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {
            'firstName': 'John',
            'lastName': 'Doe',
            'email': 'john@example.com',
          },
        },
        'status': 'active',
        'animals': [],
      };

      final cage = CageDto.fromJson(json);

      expect(cage.matingHistory, null);
    });

    test('should create from JSON with null matingHistory', () {
      final json = {
        'cageId': 1,
        'cageTag': 'C001',
        'cageUuid': 'cage-uuid-1',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {
            'firstName': 'John',
            'lastName': 'Doe',
            'email': 'john@example.com',
          },
        },
        'status': 'active',
        'animals': [],
        'matingHistory': null,
      };

      final cage = CageDto.fromJson(json);

      expect(cage.matingHistory, null);
    });

    test('should create from JSON with empty matingHistory', () {
      final json = {
        'cageId': 1,
        'cageTag': 'C001',
        'cageUuid': 'cage-uuid-1',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {
            'firstName': 'John',
            'lastName': 'Doe',
            'email': 'john@example.com',
          },
        },
        'status': 'active',
        'animals': [],
        'matingHistory': [],
      };

      final cage = CageDto.fromJson(json);

      expect(cage.matingHistory, isNotNull);
      expect(cage.matingHistory, isEmpty);
    });

    test('should convert to JSON with matingHistory', () {
      final json = {
        'cageId': 1,
        'cageTag': 'C001',
        'cageUuid': 'cage-uuid-1',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {
            'firstName': 'John',
            'lastName': 'Doe',
            'email': 'john@example.com',
          },
        },
        'status': 'active',
        'animals': [],
        'matingHistory': [
          {
            'matingUuid': 'mating-uuid-1',
            'matingTag': 'M001',
          },
        ],
      };

      final cage = CageDto.fromJson(json);
      final outputJson = cage.toJson();

      expect(outputJson['matingHistory'], isNotNull);
      expect((outputJson['matingHistory'] as List).length, 1);
    });
  });
}
