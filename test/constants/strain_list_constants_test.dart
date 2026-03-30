import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/strain_list_constants.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/services/dtos/account_dto.dart';
void main() {
  group('StrainListColumn', () {
    group('enum values', () {
      test('all columns have non-empty field names', () {
        for (final col in StrainListColumn.values) {
          expect(col.field, isNotEmpty, reason: '${col.name} should have a non-empty field');
        }
      });

      test('enumName returns the dart enum name', () {
        expect(StrainListColumn.strainName.enumName, 'strainName');
        expect(StrainListColumn.animals.enumName, 'animals');
        expect(StrainListColumn.color.enumName, 'color');
      });

      test('select column has empty label', () {
        expect(StrainListColumn.select.label, '');
        expect(StrainListColumn.select.field, 'select');
      });

      test('strainName column has correct field and label', () {
        expect(StrainListColumn.strainName.field, 'strain_name');
        expect(StrainListColumn.strainName.label, 'Name');
      });

      test('active column has correct field and label', () {
        expect(StrainListColumn.active.field, 'is_active');
        expect(StrainListColumn.active.label, 'Active');
      });
    });

    group('getDataGridRow', () {
      test('produces correct number of cells with full data', () {
        final strain = StrainDto(
          strainId: 1,
          strainUuid: 'strain-uuid-1',
          strainName: 'C57BL/6',
          owner: AccountDto(
            accountUuid: 'owner-uuid',
            user: UserDto(firstName: 'John', lastName: 'Doe'),
          ),
          createdDate: DateTime(2024, 1, 1),
          genotypes: [],
          color: 'black',
          numberOfAnimals: 42,
          backgrounds: [
            StrainBackgroundDto(id: 1, uuid: 'bg-uuid', name: 'C57BL/6J'),
          ],
          isActive: true,
        );

        final row = StrainListColumn.getDataGridRow(strain);
        // 10 cells: select, edit, strainName, animals, color, owner, created, background, genotypes, active
        expect(row.getCells().length, 10);
      });

      test('produces correct number of cells with minimal optional data', () {
        final strain = StrainDto(
          strainId: 2,
          strainUuid: 'strain-uuid-2',
          strainName: 'BALB/c',
          owner: AccountDto(
            accountUuid: 'owner-uuid',
            user: UserDto(firstName: 'A', lastName: 'B'),
          ),
          createdDate: DateTime(2024, 6, 1),
          genotypes: [],
          isActive: false,
        );

        final row = StrainListColumn.getDataGridRow(strain);
        expect(row.getCells().length, 10);
      });

      test('cell values are set correctly for key fields', () {
        final strain = StrainDto(
          strainId: 3,
          strainUuid: 'strain-uuid-3',
          strainName: 'My Strain',
          owner: AccountDto(
            accountUuid: 'owner-uuid',
            user: UserDto(firstName: 'Jane', lastName: 'Smith'),
          ),
          createdDate: DateTime(2024, 3, 15),
          genotypes: [],
          color: 'white',
          numberOfAnimals: 10,
          isActive: true,
        );

        final row = StrainListColumn.getDataGridRow(strain);
        final cells = row.getCells();

        // select cell has strainUuid
        final selectCell = cells.firstWhere((c) => c.columnName == 'select');
        expect(selectCell.value, 'strain-uuid-3');

        // strainName cell
        final nameCell = cells.firstWhere((c) => c.columnName == 'strainName');
        expect(nameCell.value, 'My Strain');

        // animals cell
        final animalsCell = cells.firstWhere((c) => c.columnName == 'animals');
        expect(animalsCell.value, 10);

        // color cell
        final colorCell = cells.firstWhere((c) => c.columnName == 'color');
        expect(colorCell.value, 'white');

        // active cell
        final activeCell = cells.firstWhere((c) => c.columnName == 'active');
        expect(activeCell.value, true);
      });

      test('handles null color with empty string fallback', () {
        final strain = StrainDto(
          strainId: 4,
          strainUuid: 'strain-uuid-4',
          strainName: 'No Color',
          owner: AccountDto(
            accountUuid: 'owner-uuid',
            user: UserDto(firstName: 'A', lastName: 'B'),
          ),
          createdDate: DateTime(2024, 1, 1),
          genotypes: [],
          color: null,
          isActive: true,
        );

        final row = StrainListColumn.getDataGridRow(strain);
        final cells = row.getCells();
        final colorCell = cells.firstWhere((c) => c.columnName == 'color');
        expect(colorCell.value, '');
      });
    });
  });
}
