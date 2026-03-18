import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/put_litter_dto.dart';

void main() {
  group('PutLitterDto', () {
    test('fromJson with complete data', () {
      final json = {
        'comment': 'Updated litter',
        'dateOfBirth': '2024-01-15T00:00:00.000Z',
        'weanDate': '2024-02-05T00:00:00.000Z',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'litterTag': 'L001',
        'strain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid-1',
          'strainName': 'C57BL/6',
          'genotypes': <Map<String, dynamic>>[],
        },
      };

      final dto = PutLitterDto.fromJson(json);

      expect(dto.comment, equals('Updated litter'));
      expect(dto.dateOfBirth!.year, equals(2024));
      expect(dto.weanDate, isNotNull);
      expect(dto.owner!.accountId, equals(1));
      expect(dto.litterTag, equals('L001'));
      expect(dto.strain, isNotNull);
      expect(dto.strain!.strainName, equals('C57BL/6'));
    });

    test('fromJson with all null optional fields', () {
      final json = <String, dynamic>{};

      final dto = PutLitterDto.fromJson(json);

      expect(dto.comment, isNull);
      expect(dto.dateOfBirth, isNull);
      expect(dto.weanDate, isNull);
      expect(dto.owner, isNull);
      expect(dto.litterTag, isNull);
      expect(dto.strain, isNull);
    });

    test('toJson transforms strain to backend format', () {
      final json = {
        'comment': 'Updated',
        'litterTag': 'L001',
        'strain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid-1',
          'strainName': 'C57BL/6',
          'genotypes': <Map<String, dynamic>>[],
        },
      };

      final dto = PutLitterDto.fromJson(json);
      final output = dto.toJson();

      // Custom toJson sends strain as { strain_uuid: ... }
      expect(output['strain'], isA<Map>());
      expect(
        (output['strain'] as Map)['strain_uuid'],
        equals('strain-uuid-1'),
      );
    });

    test('toJson with null strain', () {
      final json = {
        'comment': 'Updated',
        'litterTag': 'L001',
      };

      final dto = PutLitterDto.fromJson(json);
      final output = dto.toJson();

      expect(output['strain'], isNull);
    });
  });
}
