import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra_api/moustra_api.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

TableSettingFieldSLR _makeField({
  required String fieldName,
  required int fieldOrder,
  bool fieldVisible = true,
}) {
  return (TableSettingFieldSLRBuilder()
        ..tableSettingFieldId = 1
        ..tableSettingFieldUuid = 'uuid-$fieldName'
        ..fieldName = fieldName
        ..fieldLabel = fieldName
        ..fieldType = 'string'
        ..fieldOrder = fieldOrder
        ..fieldVisible = fieldVisible
        ..fieldFilterable = 'false'
        ..fieldSortable = 'false'
        ..fieldWidth = '100'
        ..updatedDate = DateTime(2024, 1, 1)
        ..fieldEditable = 'false'
        ..fieldValueOptions = '')
      .build();
}

GridColumn _makeColumn(String name) {
  return GridColumn(
    columnName: name,
    label: const SizedBox.shrink(),
  );
}

void main() {
  group('applyTableSettings', () {
    test('returns columns unchanged when settingFields is null', () {
      final columns = [_makeColumn('a'), _makeColumn('b')];
      final result = applyTableSettings(columns, null);
      expect(result.length, 2);
      expect(result[0].columnName, 'a');
      expect(result[1].columnName, 'b');
    });

    test('returns columns unchanged when settingFields is empty', () {
      final columns = [_makeColumn('a'), _makeColumn('b')];
      final result = applyTableSettings(columns, []);
      expect(result.length, 2);
    });

    test('hides columns with fieldVisible=false', () {
      final columns = [
        _makeColumn('select'),
        _makeColumn('col_a'),
        _makeColumn('col_b'),
      ];
      final settings = [
        _makeField(fieldName: 'col_a', fieldOrder: 1, fieldVisible: true),
        _makeField(fieldName: 'col_b', fieldOrder: 2, fieldVisible: false),
      ];
      final result = applyTableSettings(columns, settings);
      // All columns kept; hidden ones have visible=false
      expect(result.length, 3);
      expect(result[0].columnName, 'select');
      expect(result[1].columnName, 'col_a');
      expect(result[1].visible, true);
      expect(result[2].columnName, 'col_b');
      expect(result[2].visible, false);
    });

    test('reorders columns by fieldOrder', () {
      final columns = [
        _makeColumn('col_a'),
        _makeColumn('col_b'),
        _makeColumn('col_c'),
      ];
      final settings = [
        _makeField(fieldName: 'col_a', fieldOrder: 3),
        _makeField(fieldName: 'col_b', fieldOrder: 1),
        _makeField(fieldName: 'col_c', fieldOrder: 2),
      ];
      final result = applyTableSettings(columns, settings);
      expect(result.length, 3);
      expect(result[0].columnName, 'col_b');
      expect(result[1].columnName, 'col_c');
      expect(result[2].columnName, 'col_a');
    });

    test('control columns (select, edit, edit_stripe) always come first', () {
      final columns = [
        _makeColumn('select'),
        _makeColumn('edit'),
        _makeColumn('col_a'),
        _makeColumn('col_b'),
      ];
      final settings = [
        _makeField(fieldName: 'col_a', fieldOrder: 2),
        _makeField(fieldName: 'col_b', fieldOrder: 1),
      ];
      final result = applyTableSettings(columns, settings);
      expect(result.length, 4);
      expect(result[0].columnName, 'select');
      expect(result[1].columnName, 'edit');
      expect(result[2].columnName, 'col_b');
      expect(result[3].columnName, 'col_a');
    });

    test('control columns are never hidden by settings', () {
      final columns = [
        _makeColumn('select'),
        _makeColumn('edit_stripe'),
        _makeColumn('col_a'),
      ];
      // No settings for select/edit_stripe — they should still appear
      final settings = [
        _makeField(fieldName: 'col_a', fieldOrder: 1),
      ];
      final result = applyTableSettings(columns, settings);
      expect(result.length, 3);
      expect(result[0].columnName, 'select');
      expect(result[1].columnName, 'edit_stripe');
    });

    test('columns not in settings are kept at end', () {
      final columns = [
        _makeColumn('col_a'),
        _makeColumn('col_unknown'),
        _makeColumn('col_b'),
      ];
      final settings = [
        _makeField(fieldName: 'col_a', fieldOrder: 2),
        _makeField(fieldName: 'col_b', fieldOrder: 1),
      ];
      final result = applyTableSettings(columns, settings);
      expect(result.length, 3);
      expect(result[0].columnName, 'col_b');
      expect(result[1].columnName, 'col_a');
      expect(result[2].columnName, 'col_unknown');
    });

    test('all data columns hidden leaves only control columns visible', () {
      final columns = [
        _makeColumn('select'),
        _makeColumn('col_a'),
        _makeColumn('col_b'),
      ];
      final settings = [
        _makeField(fieldName: 'col_a', fieldOrder: 1, fieldVisible: false),
        _makeField(fieldName: 'col_b', fieldOrder: 2, fieldVisible: false),
      ];
      final result = applyTableSettings(columns, settings);
      // All columns kept; hidden data columns have visible=false
      expect(result.length, 3);
      expect(result[0].columnName, 'select');
      expect(result[1].visible, false);
      expect(result[2].visible, false);
    });

    test('combined visibility and ordering', () {
      final columns = [
        _makeColumn('edit'),
        _makeColumn('col_a'),
        _makeColumn('col_b'),
        _makeColumn('col_c'),
        _makeColumn('col_d'),
      ];
      final settings = [
        _makeField(fieldName: 'col_a', fieldOrder: 4, fieldVisible: true),
        _makeField(fieldName: 'col_b', fieldOrder: 1, fieldVisible: false),
        _makeField(fieldName: 'col_c', fieldOrder: 2, fieldVisible: true),
        _makeField(fieldName: 'col_d', fieldOrder: 3, fieldVisible: true),
      ];
      final result = applyTableSettings(columns, settings);
      // All 5 columns kept; col_b hidden via visible=false, ordered by fieldOrder
      expect(result.length, 5);
      expect(result[0].columnName, 'edit');
      expect(result[1].columnName, 'col_b');
      expect(result[1].visible, false);
      expect(result[2].columnName, 'col_c');
      expect(result[2].visible, true);
      expect(result[3].columnName, 'col_d');
      expect(result[4].columnName, 'col_a');
    });
  });

  group('controlColumns constant', () {
    test('contains expected control column names', () {
      expect(controlColumns, contains('select'));
      expect(controlColumns, contains('edit'));
      expect(controlColumns, contains('edit_stripe'));
      expect(controlColumns.length, 3);
    });
  });
}
