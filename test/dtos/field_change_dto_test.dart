import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/field_change_dto.dart';

void main() {
  group('FieldChangeDto Tests', () {
    test('should create from JSON with all fields', () {
      final json = {
        'field': 'status',
        'label': 'Status',
        'old': 'Active',
        'new': 'Inactive',
      };

      final dto = FieldChangeDto.fromJson(json);

      expect(dto.field, 'status');
      expect(dto.label, 'Status');
      expect(dto.oldValue, 'Active');
      expect(dto.newValue, 'Inactive');
    });

    test('should create from JSON with null old/new values', () {
      final json = {
        'field': 'name',
        'label': 'Name',
      };

      final dto = FieldChangeDto.fromJson(json);

      expect(dto.field, 'name');
      expect(dto.label, 'Name');
      expect(dto.oldValue, isNull);
      expect(dto.newValue, isNull);
    });

    test('should convert to JSON', () {
      final dto = FieldChangeDto(
        field: 'status',
        label: 'Status',
        oldValue: 'Active',
        newValue: 'Inactive',
      );

      final json = dto.toJson();

      expect(json['field'], 'status');
      expect(json['label'], 'Status');
      expect(json['old'], 'Active');
      expect(json['new'], 'Inactive');
    });
  });
}
