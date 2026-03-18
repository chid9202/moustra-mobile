import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/protocol_dto.dart';

void main() {
  group('ProtocolDto', () {
    test('fromJson with complete data', () {
      final json = {
        'protocolId': 1,
        'protocolUuid': 'protocol-uuid-1',
        'protocolNumber': 'PROTO-001',
        'title': 'Test Protocol',
        'pi': {
          'accountId': 1,
          'accountUuid': 'pi-uuid-1',
          'user': {'firstName': 'Jane', 'lastName': 'Smith'},
          'role': 'PI',
          'isActive': true,
        },
        'status': 'active',
        'approvalDate': '2024-01-01',
        'effectiveDate': '2024-01-15',
        'expirationDate': '2025-01-15',
        'painCategory': 'C',
        'maxAnimalCount': 100,
        'currentAnimalCount': 42,
        'animalCountPct': 42.0,
        'daysUntilExpiry': 365,
        'alertStatus': 'green',
        'species': 'Mouse',
        'description': 'A test protocol',
        'fundingSource': 'NIH',
        'alertThresholdPct': 80,
        'alertDays': [30, 60, 90],
        'eid': 123,
      };

      final dto = ProtocolDto.fromJson(json);

      expect(dto.protocolId, equals(1));
      expect(dto.protocolUuid, equals('protocol-uuid-1'));
      expect(dto.protocolNumber, equals('PROTO-001'));
      expect(dto.title, equals('Test Protocol'));
      expect(dto.pi!.accountUuid, equals('pi-uuid-1'));
      expect(dto.pi!.user!.firstName, equals('Jane'));
      expect(dto.status, equals('active'));
      expect(dto.approvalDate, equals('2024-01-01'));
      expect(dto.expirationDate, equals('2025-01-15'));
      expect(dto.painCategory, equals('C'));
      expect(dto.maxAnimalCount, equals(100));
      expect(dto.currentAnimalCount, equals(42));
      expect(dto.animalCountPct, equals(42.0));
      expect(dto.daysUntilExpiry, equals(365));
      expect(dto.alertStatus, equals('green'));
      expect(dto.species, equals('Mouse'));
      expect(dto.description, equals('A test protocol'));
      expect(dto.fundingSource, equals('NIH'));
      expect(dto.alertThresholdPct, equals(80));
      expect(dto.alertDays, equals([30, 60, 90]));
      expect(dto.eid, equals(123));
    });

    test('fromJson with minimal data', () {
      final json = {
        'protocolNumber': 'PROTO-001',
        'title': 'Test Protocol',
      };

      final dto = ProtocolDto.fromJson(json);

      expect(dto.protocolId, isNull);
      expect(dto.protocolUuid, isNull);
      expect(dto.pi, isNull);
      expect(dto.status, isNull);
      expect(dto.maxAnimalCount, isNull);
      expect(dto.alertDays, isNull);
      expect(dto.eid, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'protocolNumber': 'PROTO-001',
        'title': 'Test Protocol',
        'status': 'active',
        'maxAnimalCount': 100,
        'alertDays': [30, 60, 90],
      };

      final dto = ProtocolDto.fromJson(json);
      final output = dto.toJson();

      expect(output['protocolNumber'], equals('PROTO-001'));
      expect(output['title'], equals('Test Protocol'));
      expect(output['status'], equals('active'));
      expect(output['maxAnimalCount'], equals(100));
      expect(output['alertDays'], equals([30, 60, 90]));
    });

    test('fromJson with empty alertDays list', () {
      final json = {
        'protocolNumber': 'PROTO-001',
        'title': 'Test Protocol',
        'alertDays': <int>[],
      };

      final dto = ProtocolDto.fromJson(json);

      expect(dto.alertDays, isEmpty);
    });
  });
}
