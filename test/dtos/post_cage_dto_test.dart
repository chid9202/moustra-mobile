import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/post_cage_dto.dart';

void main() {
  group('PostCageDto', () {
    test('fromJson with complete data', () {
      final json = {
        'cageTag': 'C001',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'strain': {
          'strainId': 1,
          'strainUuid': 'strain-uuid-1',
          'strainName': 'C57BL/6',
          'color': '#FF0000',
          'weanAge': 21,
        },
        'setUpDate': '2024-01-01T00:00:00.000Z',
        'comment': 'Test cage',
        'barcode': 'BC001',
      };

      final dto = PostCageDto.fromJson(json);

      expect(dto.cageTag, equals('C001'));
      expect(dto.owner.accountId, equals(1));
      expect(dto.owner.accountUuid, equals('owner-uuid-1'));
      expect(dto.strain!.strainName, equals('C57BL/6'));
      expect(dto.setUpDate, isNotNull);
      expect(dto.comment, equals('Test cage'));
      expect(dto.barcode, equals('BC001'));
    });

    test('fromJson with minimal data', () {
      final json = {
        'cageTag': 'C001',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
      };

      final dto = PostCageDto.fromJson(json);

      expect(dto.cageTag, equals('C001'));
      expect(dto.strain, isNull);
      expect(dto.setUpDate, isNull);
      expect(dto.comment, isNull);
      expect(dto.barcode, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'cageTag': 'C001',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'comment': 'Test cage',
      };

      final dto = PostCageDto.fromJson(json);
      final output = dto.toJson();

      expect(output['cageTag'], equals('C001'));
      expect(output['comment'], equals('Test cage'));
      expect(output['strain'], isNull);
    });
  });
}
