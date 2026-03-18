import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/post_litter_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';

void main() {
  group('PostLitterDto', () {
    test('fromJson with complete data', () {
      final json = {
        'mating': 'mating-uuid-1',
        'numberOfMale': 3,
        'numberOfFemale': 4,
        'numberOfUnknown': 1,
        'litterTag': 'L001',
        'dateOfBirth': '2024-01-15T00:00:00.000Z',
        'weanDate': '2024-02-05T00:00:00.000Z',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'comment': 'Healthy litter',
        'strain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid-1',
          'strainName': 'C57BL/6',
          'genotypes': <Map<String, dynamic>>[],
        },
      };

      final dto = PostLitterDto.fromJson(json);

      expect(dto.mating, equals('mating-uuid-1'));
      expect(dto.numberOfMale, equals(3));
      expect(dto.numberOfFemale, equals(4));
      expect(dto.numberOfUnknown, equals(1));
      expect(dto.litterTag, equals('L001'));
      expect(dto.dateOfBirth.year, equals(2024));
      expect(dto.weanDate, isNotNull);
      expect(dto.owner.accountId, equals(1));
      expect(dto.comment, equals('Healthy litter'));
      expect(dto.strain, isNotNull);
      expect(dto.strain!.strainName, equals('C57BL/6'));
    });

    test('fromJson with minimal data', () {
      final json = {
        'mating': 'mating-uuid-1',
        'numberOfMale': 0,
        'numberOfFemale': 0,
        'numberOfUnknown': 5,
        'litterTag': 'L002',
        'dateOfBirth': '2024-01-15T00:00:00.000Z',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
      };

      final dto = PostLitterDto.fromJson(json);

      expect(dto.weanDate, isNull);
      expect(dto.comment, isNull);
      expect(dto.strain, isNull);
    });

    test('toJson transforms strain to UUID', () {
      final strain = StrainStoreDto(
        strainId: 1,
        strainUuid: 'strain-uuid-1',
        strainName: 'C57BL/6',
        genotypes: [],
      );

      final json = {
        'mating': 'mating-uuid-1',
        'numberOfMale': 3,
        'numberOfFemale': 4,
        'numberOfUnknown': 0,
        'litterTag': 'L001',
        'dateOfBirth': '2024-01-15T00:00:00.000Z',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'strain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid-1',
          'strainName': 'C57BL/6',
          'genotypes': <Map<String, dynamic>>[],
        },
      };

      final dto = PostLitterDto.fromJson(json);
      final output = dto.toJson();

      // The custom toJson sends strain as just the UUID string
      expect(output['strain'], equals('strain-uuid-1'));
      expect(output['mating'], equals('mating-uuid-1'));
      expect(output['numberOfMale'], equals(3));
    });

    test('toJson with null strain', () {
      final json = {
        'mating': 'mating-uuid-1',
        'numberOfMale': 0,
        'numberOfFemale': 0,
        'numberOfUnknown': 5,
        'litterTag': 'L002',
        'dateOfBirth': '2024-01-15T00:00:00.000Z',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
      };

      final dto = PostLitterDto.fromJson(json);
      final output = dto.toJson();

      expect(output['strain'], isNull);
    });
  });
}
