import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/cage_list_constants.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

void main() {
  group('CageListColumn', () {
    group('getColumns', () {
      test('should return all columns with default parameters', () {
        final columns = CageListColumn.getColumns();
        expect(columns.length, 12);
      });

      test('select column should be hidden by default', () {
        final columns = CageListColumn.getColumns();
        final selectColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.select.field,
        );
        expect(selectColumn.visible, false);
      });

      test('select column should be visible when includeSelect is true', () {
        final columns = CageListColumn.getColumns(includeSelect: true);
        final selectColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.select.field,
        );
        expect(selectColumn.visible, true);
      });

      test('EID column should be hidden by default', () {
        final columns = CageListColumn.getColumns();
        final eidColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.eid.field,
        );
        expect(eidColumn.visible, false);
      });

      test('EID column should be visible when useEid is true', () {
        final columns = CageListColumn.getColumns(useEid: true);
        final eidColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.eid.field,
        );
        expect(eidColumn.visible, true);
      });

      test('EID column should be hidden when useEid is false', () {
        final columns = CageListColumn.getColumns(useEid: false);
        final eidColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.eid.field,
        );
        expect(eidColumn.visible, false);
      });

      test('edit column should always be visible', () {
        final columns = CageListColumn.getColumns();
        final editColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.edit.field,
        );
        expect(editColumn.visible, true);
      });

      test('both select and EID visibility can be controlled independently', () {
        final columns = CageListColumn.getColumns(
          includeSelect: true,
          useEid: true,
        );
        final selectColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.select.field,
        );
        final eidColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.eid.field,
        );
        expect(selectColumn.visible, true);
        expect(eidColumn.visible, true);
      });

      test('select visible but EID hidden', () {
        final columns = CageListColumn.getColumns(
          includeSelect: true,
          useEid: false,
        );
        final selectColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.select.field,
        );
        final eidColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.eid.field,
        );
        expect(selectColumn.visible, true);
        expect(eidColumn.visible, false);
      });

      test('EID column should not allow sorting', () {
        final columns = CageListColumn.getColumns(useEid: true);
        final eidColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.eid.field,
        );
        expect(eidColumn.allowSorting, false);
      });

      test('edit column should not allow sorting', () {
        final columns = CageListColumn.getColumns();
        final editColumn = columns.firstWhere(
          (c) => c.columnName == CageListColumn.edit.field,
        );
        expect(editColumn.allowSorting, false);
      });
    });

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
    });
  });
}
