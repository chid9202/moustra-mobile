import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/protocol_alert_dto.dart';

void main() {
  group('ProtocolAlertDto', () {
    test('fromJson with complete data', () {
      final json = {
        'id': 1,
        'alertUuid': 'alert-uuid-1',
        'alertType': 'expiration',
        'message': 'Protocol expiring in 30 days',
        'triggeredAt': '2024-01-01T00:00:00Z',
        'acknowledgedAt': '2024-01-02T00:00:00Z',
        'isResolved': true,
      };

      final dto = ProtocolAlertDto.fromJson(json);

      expect(dto.id, equals(1));
      expect(dto.alertUuid, equals('alert-uuid-1'));
      expect(dto.alertType, equals('expiration'));
      expect(dto.message, equals('Protocol expiring in 30 days'));
      expect(dto.triggeredAt, equals('2024-01-01T00:00:00Z'));
      expect(dto.acknowledgedAt, equals('2024-01-02T00:00:00Z'));
      expect(dto.isResolved, isTrue);
    });

    test('fromJson with minimal data', () {
      final json = {
        'alertType': 'expiration',
        'message': 'Alert message',
        'triggeredAt': '2024-01-01T00:00:00Z',
      };

      final dto = ProtocolAlertDto.fromJson(json);

      expect(dto.id, isNull);
      expect(dto.alertUuid, isNull);
      expect(dto.acknowledgedAt, isNull);
      expect(dto.isResolved, isFalse);
    });

    test('toJson round-trip', () {
      final json = {
        'id': 1,
        'alertUuid': 'alert-uuid-1',
        'alertType': 'expiration',
        'message': 'Protocol expiring in 30 days',
        'triggeredAt': '2024-01-01T00:00:00Z',
        'acknowledgedAt': '2024-01-02T00:00:00Z',
        'isResolved': true,
      };

      final dto = ProtocolAlertDto.fromJson(json);
      final output = dto.toJson();

      expect(output['alertType'], equals(json['alertType']));
      expect(output['message'], equals(json['message']));
      expect(output['triggeredAt'], equals(json['triggeredAt']));
      expect(output['isResolved'], equals(json['isResolved']));
    });
  });
}
