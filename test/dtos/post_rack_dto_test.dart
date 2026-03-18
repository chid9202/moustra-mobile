import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/post_rack_dto.dart';

void main() {
  group('PostRackDto', () {
    test('fromJson with complete data', () {
      final json = {
        'rackName': 'Rack A',
        'rackWidth': 6,
        'rackHeight': 4,
      };

      final dto = PostRackDto.fromJson(json);

      expect(dto.rackName, equals('Rack A'));
      expect(dto.rackWidth, equals(6));
      expect(dto.rackHeight, equals(4));
    });

    test('toJson round-trip', () {
      final dto = PostRackDto(
        rackName: 'Rack B',
        rackWidth: 8,
        rackHeight: 6,
      );

      final output = dto.toJson();

      expect(output['rackName'], equals('Rack B'));
      expect(output['rackWidth'], equals(8));
      expect(output['rackHeight'], equals(6));
    });

    test('fromJson then toJson preserves values', () {
      final json = {
        'rackName': 'Test Rack',
        'rackWidth': 10,
        'rackHeight': 8,
      };

      final dto = PostRackDto.fromJson(json);
      final output = dto.toJson();

      expect(output['rackName'], equals(json['rackName']));
      expect(output['rackWidth'], equals(json['rackWidth']));
      expect(output['rackHeight'], equals(json['rackHeight']));
    });
  });
}
