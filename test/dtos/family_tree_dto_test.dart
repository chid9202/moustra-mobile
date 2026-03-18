import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/family_tree_dto.dart';

void main() {
  group('FamilyTreeDto', () {
    test('fromJson with complete data', () {
      final json = {
        'parent': {
          'litterUuid': 'parent-litter-uuid',
          'litterTag': 'L001',
          'animals': <Map<String, dynamic>>[],
        },
        'children': {
          'litterUuid': 'child-litter-uuid',
          'litterTag': 'L002',
          'animals': <Map<String, dynamic>>[],
        },
      };

      final dto = FamilyTreeDto.fromJson(json);

      expect(dto.parent, isNotNull);
      expect(dto.parent!.litterUuid, equals('parent-litter-uuid'));
      expect(dto.parent!.litterTag, equals('L001'));
      expect(dto.children, isNotNull);
      expect(dto.children!.litterUuid, equals('child-litter-uuid'));
      expect(dto.children!.litterTag, equals('L002'));
    });

    test('fromJson with null parent and children', () {
      final json = <String, dynamic>{};

      final dto = FamilyTreeDto.fromJson(json);

      expect(dto.parent, isNull);
      expect(dto.children, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'parent': {
          'litterUuid': 'parent-litter-uuid',
          'litterTag': 'L001',
          'animals': <Map<String, dynamic>>[],
        },
      };

      final dto = FamilyTreeDto.fromJson(json);
      final output = dto.toJson();

      expect(
        (output['parent'] as Map<String, dynamic>)['litterUuid'],
        equals('parent-litter-uuid'),
      );
      expect(output['children'], isNull);
    });
  });
}
