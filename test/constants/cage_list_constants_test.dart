import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/cage_list_constants.dart';

void main() {
  group('CageListColumn', () {
    group('enum values', () {
      test('select column should have correct field name', () {
        expect(CageListColumn.select.field, 'select');
      });

      test('edit column should have correct field and label', () {
        expect(CageListColumn.edit.field, 'edit');
        expect(CageListColumn.edit.label, 'Edit');
      });

      test('eid column should have correct field and label', () {
        expect(CageListColumn.eid.field, 'eid');
        expect(CageListColumn.eid.label, 'EID');
      });

      test('rack column should have correct field and label', () {
        expect(CageListColumn.rack.field, 'rack');
        expect(CageListColumn.rack.label, 'Rack');
      });
    });
  });
}
