import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/compliance_summary_dto.dart';

void main() {
  group('ComplianceSummaryDto', () {
    test('fromJson with complete data', () {
      final json = {
        'totalActive': 10,
        'expiring30d': 2,
        'expiring60d': 3,
        'expiring90d': 5,
        'expiredUnresolved': 1,
        'overAnimalLimit': 0,
        'nearAnimalLimit': 4,
        'animalsWithoutProtocol': 7,
        'unacknowledgedAlerts': 3,
      };

      final dto = ComplianceSummaryDto.fromJson(json);

      expect(dto.totalActive, equals(10));
      expect(dto.expiring30d, equals(2));
      expect(dto.expiring60d, equals(3));
      expect(dto.expiring90d, equals(5));
      expect(dto.expiredUnresolved, equals(1));
      expect(dto.overAnimalLimit, equals(0));
      expect(dto.nearAnimalLimit, equals(4));
      expect(dto.animalsWithoutProtocol, equals(7));
      expect(dto.unacknowledgedAlerts, equals(3));
    });

    test('toJson round-trip', () {
      final json = {
        'totalActive': 10,
        'expiring30d': 2,
        'expiring60d': 3,
        'expiring90d': 5,
        'expiredUnresolved': 1,
        'overAnimalLimit': 0,
        'nearAnimalLimit': 4,
        'animalsWithoutProtocol': 7,
        'unacknowledgedAlerts': 3,
      };

      final dto = ComplianceSummaryDto.fromJson(json);
      final output = dto.toJson();

      expect(output['totalActive'], equals(json['totalActive']));
      expect(output['expiring30d'], equals(json['expiring30d']));
      expect(output['expiring60d'], equals(json['expiring60d']));
      expect(output['expiring90d'], equals(json['expiring90d']));
      expect(output['expiredUnresolved'], equals(json['expiredUnresolved']));
      expect(output['overAnimalLimit'], equals(json['overAnimalLimit']));
      expect(output['nearAnimalLimit'], equals(json['nearAnimalLimit']));
      expect(
        output['animalsWithoutProtocol'],
        equals(json['animalsWithoutProtocol']),
      );
      expect(
        output['unacknowledgedAlerts'],
        equals(json['unacknowledgedAlerts']),
      );
    });

    test('toJson produces all fields', () {
      final dto = ComplianceSummaryDto(
        totalActive: 0,
        expiring30d: 0,
        expiring60d: 0,
        expiring90d: 0,
        expiredUnresolved: 0,
        overAnimalLimit: 0,
        nearAnimalLimit: 0,
        animalsWithoutProtocol: 0,
        unacknowledgedAlerts: 0,
      );

      final output = dto.toJson();

      expect(output.keys.length, equals(9));
    });
  });
}
