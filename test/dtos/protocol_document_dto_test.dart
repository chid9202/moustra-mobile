import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/protocol_document_dto.dart';

void main() {
  group('ProtocolDocumentDto', () {
    test('fromJson with complete data', () {
      final json = {
        'documentUuid': 'doc-uuid-1',
        'documentType': 'approval_letter',
        'fileLink': 'https://example.com/doc.pdf',
        'filename': 'approval.pdf',
        'uploadedBy': 'user-uuid-1',
        'uploadedAt': '2024-01-01T00:00:00Z',
        'description': 'Approval letter from IACUC',
      };

      final dto = ProtocolDocumentDto.fromJson(json);

      expect(dto.documentUuid, equals('doc-uuid-1'));
      expect(dto.documentType, equals('approval_letter'));
      expect(dto.fileLink, equals('https://example.com/doc.pdf'));
      expect(dto.filename, equals('approval.pdf'));
      expect(dto.uploadedBy, equals('user-uuid-1'));
      expect(dto.uploadedAt, equals('2024-01-01T00:00:00Z'));
      expect(dto.description, equals('Approval letter from IACUC'));
    });

    test('fromJson with minimal data', () {
      final json = {
        'documentUuid': 'doc-uuid-1',
      };

      final dto = ProtocolDocumentDto.fromJson(json);

      expect(dto.documentUuid, equals('doc-uuid-1'));
      expect(dto.documentType, isNull);
      expect(dto.fileLink, isNull);
      expect(dto.filename, isNull);
      expect(dto.uploadedBy, isNull);
      expect(dto.uploadedAt, isNull);
      expect(dto.description, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'documentUuid': 'doc-uuid-1',
        'documentType': 'approval_letter',
        'fileLink': 'https://example.com/doc.pdf',
        'filename': 'approval.pdf',
        'uploadedBy': 'user-uuid-1',
        'uploadedAt': '2024-01-01T00:00:00Z',
        'description': 'Approval letter from IACUC',
      };

      final dto = ProtocolDocumentDto.fromJson(json);
      final output = dto.toJson();

      expect(output['documentUuid'], equals(json['documentUuid']));
      expect(output['documentType'], equals(json['documentType']));
      expect(output['fileLink'], equals(json['fileLink']));
      expect(output['filename'], equals(json['filename']));
    });
  });
}
