import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/put_cage_dto.dart';

void main() {
  group('PutCageDto', () {
    test('fromJson with complete data', () {
      final json = {
        'cageId': 1,
        'cageUuid': 'cage-uuid-1',
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
        },
        'setUpDate': '2024-01-01T00:00:00.000Z',
        'comment': 'Updated cage',
        'barcode': 'BC001',
      };

      final dto = PutCageDto.fromJson(json);

      expect(dto.cageId, equals(1));
      expect(dto.cageUuid, equals('cage-uuid-1'));
      expect(dto.cageTag, equals('C001'));
      expect(dto.owner.accountId, equals(1));
      expect(dto.strain!.strainName, equals('C57BL/6'));
      expect(dto.setUpDate, isNotNull);
      expect(dto.comment, equals('Updated cage'));
      expect(dto.barcode, equals('BC001'));
    });

    test('fromJson with minimal data', () {
      final json = {
        'cageId': 1,
        'cageUuid': 'cage-uuid-1',
        'cageTag': 'C001',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
      };

      final dto = PutCageDto.fromJson(json);

      expect(dto.strain, isNull);
      expect(dto.setUpDate, isNull);
      expect(dto.comment, isNull);
      expect(dto.barcode, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'cageId': 1,
        'cageUuid': 'cage-uuid-1',
        'cageTag': 'C001',
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'comment': 'Test',
      };

      final dto = PutCageDto.fromJson(json);
      final output = dto.toJson();

      expect(output['cageId'], equals(1));
      expect(output['cageUuid'], equals('cage-uuid-1'));
      expect(output['cageTag'], equals('C001'));
      expect(output['comment'], equals('Test'));
    });
  });
}
