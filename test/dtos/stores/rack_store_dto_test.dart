import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';

void main() {
  group('RackStoreDto', () {
    test('fromJson with complete data', () {
      final json = {
        'rackData': {
          'rackId': 1,
          'rackUuid': 'rack-uuid-1',
          'rackName': 'Rack A',
          'rackWidth': 5,
          'rackHeight': 10,
        },
        'transformationMatrix': [1.0, 0.0, 0.0, 1.0, 0.0, 0.0],
      };

      final dto = RackStoreDto.fromJson(json);

      expect(dto.rackData.rackId, equals(1));
      expect(dto.rackData.rackUuid, equals('rack-uuid-1'));
      expect(dto.rackData.rackName, equals('Rack A'));
      expect(dto.rackData.rackWidth, equals(5));
      expect(dto.rackData.rackHeight, equals(10));
      expect(dto.transformationMatrix, equals([1.0, 0.0, 0.0, 1.0, 0.0, 0.0]));
    });

    test('fromJson with minimal data (no transformation matrix)', () {
      final json = {
        'rackData': {
          'rackId': 2,
          'rackUuid': 'rack-uuid-2',
          'rackName': 'Rack B',
        },
      };

      final dto = RackStoreDto.fromJson(json);

      expect(dto.rackData.rackId, equals(2));
      expect(dto.transformationMatrix, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'rackData': {
          'rackId': 1,
          'rackUuid': 'rack-uuid-1',
          'rackName': 'Rack A',
          'rackWidth': 5,
          'rackHeight': 10,
        },
        'transformationMatrix': [1.0, 0.0, 0.0, 1.0, 0.0, 0.0],
      };

      final dto = RackStoreDto.fromJson(json);
      final output = dto.toJson();

      expect(output['rackData'], isA<Map<String, dynamic>>());
      expect((output['rackData'] as Map)['rackId'], equals(1));
      expect((output['rackData'] as Map)['rackName'], equals('Rack A'));
      expect(output['transformationMatrix'], equals([1.0, 0.0, 0.0, 1.0, 0.0, 0.0]));
    });
  });
}
