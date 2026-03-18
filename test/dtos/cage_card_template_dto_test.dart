import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/cage_card_template_dto.dart';

void main() {
  group('CageCardTemplateDto', () {
    test('fromJson with complete data', () {
      final json = {
        'cageCardTemplateUuid': 'template-uuid-1',
        'name': 'Default Template',
        'cardSize': '3x5',
        'enabledFields': ['cageTag', 'strain', 'sex'],
        'fieldOrder': ['cageTag', 'strain', 'sex'],
        'codeConfig': {
          'type': 'qr',
          'position': 'top-right',
          'size': 'medium',
        },
        'style': {
          'fontSize': '12pt',
          'brandingText': 'Lab Name',
        },
        'isDefault': true,
        'owner': {
          'accountUuid': 'owner-uuid-1',
          'user': {'firstName': 'John', 'lastName': 'Doe'},
        },
        'createdDate': '2024-01-01T00:00:00Z',
        'updatedDate': '2024-06-01T00:00:00Z',
      };

      final dto = CageCardTemplateDto.fromJson(json);

      expect(dto.cageCardTemplateUuid, equals('template-uuid-1'));
      expect(dto.name, equals('Default Template'));
      expect(dto.cardSize, equals('3x5'));
      expect(dto.enabledFields, equals(['cageTag', 'strain', 'sex']));
      expect(dto.fieldOrder, equals(['cageTag', 'strain', 'sex']));
      expect(dto.codeConfig!.type, equals('qr'));
      expect(dto.codeConfig!.position, equals('top-right'));
      expect(dto.codeConfig!.size, equals('medium'));
      expect(dto.style!.fontSize, equals('12pt'));
      expect(dto.style!.brandingText, equals('Lab Name'));
      expect(dto.isDefault, isTrue);
      expect(dto.owner!.accountUuid, equals('owner-uuid-1'));
      expect(dto.createdDate, equals('2024-01-01T00:00:00Z'));
      expect(dto.updatedDate, equals('2024-06-01T00:00:00Z'));
    });

    test('fromJson with minimal data', () {
      final json = {
        'cageCardTemplateUuid': 'template-uuid-1',
        'name': 'Template',
        'cardSize': '3x5',
        'enabledFields': <String>[],
        'fieldOrder': <String>[],
        'isDefault': false,
      };

      final dto = CageCardTemplateDto.fromJson(json);

      expect(dto.codeConfig, isNull);
      expect(dto.style, isNull);
      expect(dto.owner, isNull);
      expect(dto.createdDate, isNull);
      expect(dto.updatedDate, isNull);
      expect(dto.enabledFields, isEmpty);
      expect(dto.fieldOrder, isEmpty);
    });

    test('toJson round-trip', () {
      final json = {
        'cageCardTemplateUuid': 'template-uuid-1',
        'name': 'Default Template',
        'cardSize': '3x5',
        'enabledFields': ['cageTag', 'strain'],
        'fieldOrder': ['cageTag', 'strain'],
        'codeConfig': {
          'type': 'qr',
          'position': 'top-right',
          'size': 'medium',
        },
        'isDefault': true,
      };

      final dto = CageCardTemplateDto.fromJson(json);
      final output = dto.toJson();

      expect(output['cageCardTemplateUuid'], equals('template-uuid-1'));
      expect(output['name'], equals('Default Template'));
      expect(output['enabledFields'], equals(['cageTag', 'strain']));
      expect((output['codeConfig'] as Map)['type'], equals('qr'));
    });
  });

  group('CageCardCodeConfigDto', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        'type': 'barcode',
        'position': 'bottom-left',
        'size': 'small',
      };

      final dto = CageCardCodeConfigDto.fromJson(json);

      expect(dto.type, equals('barcode'));
      expect(dto.position, equals('bottom-left'));
      expect(dto.size, equals('small'));

      final output = dto.toJson();

      expect(output['type'], equals('barcode'));
      expect(output['position'], equals('bottom-left'));
      expect(output['size'], equals('small'));
    });
  });

  group('CageCardStyleDto', () {
    test('fromJson with null optional fields', () {
      final json = <String, dynamic>{};

      final dto = CageCardStyleDto.fromJson(json);

      expect(dto.fontSize, isNull);
      expect(dto.brandingText, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'fontSize': '14pt',
        'brandingText': 'My Lab',
      };

      final dto = CageCardStyleDto.fromJson(json);
      final output = dto.toJson();

      expect(output['fontSize'], equals('14pt'));
      expect(output['brandingText'], equals('My Lab'));
    });
  });

  group('CageCardTemplateOwnerDto', () {
    test('fromJson with user map', () {
      final json = {
        'accountUuid': 'owner-uuid-1',
        'user': {'firstName': 'Jane', 'lastName': 'Smith'},
      };

      final dto = CageCardTemplateOwnerDto.fromJson(json);

      expect(dto.accountUuid, equals('owner-uuid-1'));
      expect(dto.user, isNotNull);
      expect(dto.user!['firstName'], equals('Jane'));
    });

    test('fromJson with null user', () {
      final json = {
        'accountUuid': 'owner-uuid-1',
      };

      final dto = CageCardTemplateOwnerDto.fromJson(json);

      expect(dto.accountUuid, equals('owner-uuid-1'));
      expect(dto.user, isNull);
    });
  });
}
