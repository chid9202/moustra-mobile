import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/protocol_amendment_dto.dart';

void main() {
  group('ProtocolAmendmentDto', () {
    test('fromJson with complete data', () {
      final json = {
        'amendmentUuid': 'amendment-uuid-1',
        'amendmentNumber': 'AMD-001',
        'amendmentType': 'modification',
        'description': 'Increased animal count',
        'approvedDate': '2024-06-01',
        'effectiveDate': '2024-06-15',
        'status': 'approved',
      };

      final dto = ProtocolAmendmentDto.fromJson(json);

      expect(dto.amendmentUuid, equals('amendment-uuid-1'));
      expect(dto.amendmentNumber, equals('AMD-001'));
      expect(dto.amendmentType, equals('modification'));
      expect(dto.description, equals('Increased animal count'));
      expect(dto.approvedDate, equals('2024-06-01'));
      expect(dto.effectiveDate, equals('2024-06-15'));
      expect(dto.status, equals('approved'));
    });

    test('fromJson with all null optional fields', () {
      final json = <String, dynamic>{};

      final dto = ProtocolAmendmentDto.fromJson(json);

      expect(dto.amendmentUuid, isNull);
      expect(dto.amendmentNumber, isNull);
      expect(dto.amendmentType, isNull);
      expect(dto.description, isNull);
      expect(dto.approvedDate, isNull);
      expect(dto.effectiveDate, isNull);
      expect(dto.status, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'amendmentUuid': 'amendment-uuid-1',
        'amendmentNumber': 'AMD-001',
        'amendmentType': 'modification',
        'description': 'Increased animal count',
        'approvedDate': '2024-06-01',
        'effectiveDate': '2024-06-15',
        'status': 'approved',
      };

      final dto = ProtocolAmendmentDto.fromJson(json);
      final output = dto.toJson();

      expect(output['amendmentUuid'], equals(json['amendmentUuid']));
      expect(output['amendmentNumber'], equals(json['amendmentNumber']));
      expect(output['status'], equals(json['status']));
    });
  });
}
