import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/put_rack_dto.dart';

void main() {
  group('PutRackDto', () {
    test('fromJson with complete data', () {
      final json = {
        'rackName': 'Rack A',
        'rackWidth': 6,
        'rackHeight': 4,
      };

      final dto = PutRackDto.fromJson(json);

      expect(dto.rackName, equals('Rack A'));
      expect(dto.rackWidth, equals(6));
      expect(dto.rackHeight, equals(4));
    });

    test('toJson round-trip', () {
      final dto = PutRackDto(
        rackName: 'Updated Rack',
        rackWidth: 12,
        rackHeight: 10,
      );

      final output = dto.toJson();

      expect(output['rackName'], equals('Updated Rack'));
      expect(output['rackWidth'], equals(12));
      expect(output['rackHeight'], equals(10));
    });

    test('fromJson then toJson preserves values', () {
      final json = {
        'rackName': 'Test Rack',
        'rackWidth': 10,
        'rackHeight': 8,
      };

      final dto = PutRackDto.fromJson(json);
      final output = dto.toJson();

      expect(output['rackName'], equals(json['rackName']));
      expect(output['rackWidth'], equals(json['rackWidth']));
      expect(output['rackHeight'], equals(json['rackHeight']));
    });
  });
}
