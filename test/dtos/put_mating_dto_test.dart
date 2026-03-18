import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/put_mating_dto.dart';

void main() {
  group('PutMatingDto', () {
    test('fromJson with complete data', () {
      final json = {
        'matingId': 1,
        'matingUuid': 'mating-uuid-1',
        'matingTag': 'M001',
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
        'comment': 'Updated mating',
        'disbandedDate': '2024-06-01T00:00:00.000Z',
        'disbandedBy': {
          'accountId': 2,
          'accountUuid': 'disbander-uuid-1',
          'user': {'firstName': 'Jane', 'lastName': 'Smith'},
        },
      };

      final dto = PutMatingDto.fromJson(json);

      expect(dto.matingId, equals(1));
      expect(dto.matingUuid, equals('mating-uuid-1'));
      expect(dto.matingTag, equals('M001'));
      expect(dto.litterStrain, isNotNull);
      expect(dto.litterStrain!.strainName, equals('C57BL/6'));
      expect(dto.setUpDate.year, equals(2024));
      expect(dto.owner.accountId, equals(1));
      expect(dto.comment, equals('Updated mating'));
      expect(dto.disbandedDate, isNotNull);
      expect(dto.disbandedDate!.month, equals(6));
      expect(dto.disbandedBy, isNotNull);
      expect(dto.disbandedBy!.accountId, equals(2));
    });

    test('fromJson with minimal data', () {
      final json = {
        'matingId': 1,
        'matingUuid': 'mating-uuid-1',
        'matingTag': 'M001',
        'setUpDate': '2024-01-01T00:00:00.000Z',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
      };

      final dto = PutMatingDto.fromJson(json);

      expect(dto.litterStrain, isNull);
      expect(dto.comment, isNull);
      expect(dto.disbandedDate, isNull);
      expect(dto.disbandedBy, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'matingId': 1,
        'matingUuid': 'mating-uuid-1',
        'matingTag': 'M001',
        'setUpDate': '2024-01-01T00:00:00.000Z',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'comment': 'Test',
      };

      final dto = PutMatingDto.fromJson(json);
      final output = dto.toJson();

      expect(output['matingId'], equals(1));
      expect(output['matingUuid'], equals('mating-uuid-1'));
      expect(output['matingTag'], equals('M001'));
      expect(output['comment'], equals('Test'));
      expect(output['litterStrain'], isNull);
      expect(output['disbandedDate'], isNull);
      expect(output['disbandedBy'], isNull);
    });
  });
}
