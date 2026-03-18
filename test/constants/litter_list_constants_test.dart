import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/litter_list_constants.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

void main() {
  group('LitterListColumn', () {
    group('enum values', () {
      test('all columns have non-empty field names except numberOfPups', () {
        for (final col in LitterListColumn.values) {
          if (col == LitterListColumn.numberOfPups) {
            // numberOfPups has an empty field name (computed column)
            expect(col.field, isEmpty);
          } else {
            expect(col.field, isNotEmpty, reason: '${col.name} should have a non-empty field');
          }
        }
      });

      test('enumName returns the dart enum name', () {
        expect(LitterListColumn.litterTag.enumName, 'litterTag');
        expect(LitterListColumn.strain.enumName, 'strain');
        expect(LitterListColumn.wean.enumName, 'wean');
      });

      test('select column has empty label', () {
        expect(LitterListColumn.select.label, '');
        expect(LitterListColumn.select.field, 'select');
      });

      test('edit column has correct field and label', () {
        expect(LitterListColumn.edit.field, 'edit');
        expect(LitterListColumn.edit.label, 'Edit');
      });

      test('litterTag column has correct field and label', () {
        expect(LitterListColumn.litterTag.field, 'litter_tag');
        expect(LitterListColumn.litterTag.label, 'Litter Tag');
      });

      test('numberOfPups column has correct label', () {
        expect(LitterListColumn.numberOfPups.label, 'Number of Pups');
      });
    });

    group('getColumns', () {
      test('should return 9 columns', () {
        final columns = LitterListColumn.getColumns();
        expect(columns.length, 9);
      });

      test('select column should be hidden by default', () {
        final columns = LitterListColumn.getColumns();
        final selectColumn = columns.firstWhere(
          (c) => c.columnName == LitterListColumn.select.field,
        );
        expect(selectColumn.visible, false);
      });

      test('select column should be visible when includeSelect is true', () {
        final columns = LitterListColumn.getColumns(includeSelect: true);
        final selectColumn = columns.firstWhere(
          (c) => c.columnName == LitterListColumn.select.field,
        );
        expect(selectColumn.visible, true);
      });

      test('edit column should not allow sorting', () {
        final columns = LitterListColumn.getColumns();
        final editColumn = columns.firstWhere(
          (c) => c.columnName == LitterListColumn.edit.field,
        );
        expect(editColumn.allowSorting, false);
      });

      test('litterTag column should allow sorting', () {
        final columns = LitterListColumn.getColumns();
        final col = columns.firstWhere(
          (c) => c.columnName == LitterListColumn.litterTag.field,
        );
        expect(col.allowSorting, true);
      });

      test('numberOfPups column should not allow sorting', () {
        final columns = LitterListColumn.getColumns();
        final col = columns.firstWhere(
          (c) => c.columnName == LitterListColumn.numberOfPups.field,
        );
        expect(col.allowSorting, false);
      });
    });

    group('getDataGridRow', () {
      test('produces correct number of cells with full data', () {
        final litter = LitterDto(
          litterUuid: 'litter-uuid-1',
          litterTag: 'LIT-001',
          weanDate: DateTime(2024, 3, 1),
          dateOfBirth: DateTime(2024, 2, 1),
          createdDate: DateTime(2024, 2, 1),
          strain: StrainSummaryDto(
            strainId: 1,
            strainUuid: 'strain-uuid-1',
            strainName: 'C57BL/6',
          ),
          owner: AccountDto(
            accountUuid: 'owner-uuid',
            user: UserDto(firstName: 'Jane', lastName: 'Doe'),
          ),
          animals: [
            LitterAnimalDto(animalId: 1, animalUuid: 'a1'),
            LitterAnimalDto(animalId: 2, animalUuid: 'a2'),
          ],
        );

        final row = LitterListColumn.getDataGridRow(litter);
        // 9 cells: select, edit, litterTag, strain, numberOfPups, wean, dob, owner, created
        expect(row.getCells().length, 9);
      });

      test('produces correct number of cells with minimal data', () {
        final litter = LitterDto(
          litterUuid: 'litter-uuid-2',
        );

        final row = LitterListColumn.getDataGridRow(litter);
        expect(row.getCells().length, 9);
      });

      test('cell values are set correctly for key fields', () {
        final litter = LitterDto(
          litterUuid: 'litter-uuid-3',
          litterTag: 'MY-LITTER',
          animals: [
            LitterAnimalDto(animalId: 1, animalUuid: 'a1'),
            LitterAnimalDto(animalId: 2, animalUuid: 'a2'),
            LitterAnimalDto(animalId: 3, animalUuid: 'a3'),
          ],
        );

        final row = LitterListColumn.getDataGridRow(litter);
        final cells = row.getCells();

        // select cell has litterUuid
        final selectCell = cells.firstWhere((c) => c.columnName == 'select');
        expect(selectCell.value, 'litter-uuid-3');

        // litterTag cell
        final tagCell = cells.firstWhere((c) => c.columnName == 'litterTag');
        expect(tagCell.value, 'MY-LITTER');

        // numberOfPups cell
        final pupsCell = cells.firstWhere((c) => c.columnName == 'numberOfPups');
        expect(pupsCell.value, 3);
      });

      test('handles null strain gracefully', () {
        final litter = LitterDto(
          litterUuid: 'litter-uuid-4',
          strain: null,
        );

        final row = LitterListColumn.getDataGridRow(litter);
        final cells = row.getCells();
        final strainCell = cells.firstWhere((c) => c.columnName == 'strain');
        expect(strainCell.value, isNull);
      });

      test('empty animals list gives zero pups', () {
        final litter = LitterDto(
          litterUuid: 'litter-uuid-5',
          animals: [],
        );

        final row = LitterListColumn.getDataGridRow(litter);
        final cells = row.getCells();
        final pupsCell = cells.firstWhere((c) => c.columnName == 'numberOfPups');
        expect(pupsCell.value, 0);
      });
    });
  });
}
