import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/mating_list_constants.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

void main() {
  group('MatingListColumn', () {
    group('enum values', () {
      test('all columns have non-empty field names', () {
        for (final col in MatingListColumn.values) {
          expect(col.field, isNotEmpty, reason: '${col.name} should have a non-empty field');
        }
      });

      test('enumName returns the dart enum name', () {
        expect(MatingListColumn.matingTag.enumName, 'matingTag');
        expect(MatingListColumn.cageTag.enumName, 'cageTag');
        expect(MatingListColumn.setUpDate.enumName, 'setUpDate');
      });

      test('matingTag column has correct field and label', () {
        expect(MatingListColumn.matingTag.field, 'mating_tag');
        expect(MatingListColumn.matingTag.label, 'Mating Tag');
      });

      test('litterStrain column has correct field and label', () {
        expect(MatingListColumn.litterStrain.field, 'litter_strain');
        expect(MatingListColumn.litterStrain.label, 'Litter Strain');
      });
    });

    group('getColumns', () {
      test('should return 11 columns', () {
        final columns = MatingListColumn.getColumns();
        expect(columns.length, 11);
      });

      test('matingTag column should allow sorting', () {
        final columns = MatingListColumn.getColumns();
        final col = columns.firstWhere(
          (c) => c.columnName == MatingListColumn.matingTag.field,
        );
        expect(col.allowSorting, true);
      });

      test('maleTag column should not allow sorting', () {
        final columns = MatingListColumn.getColumns();
        final col = columns.firstWhere(
          (c) => c.columnName == MatingListColumn.maleTag.field,
        );
        expect(col.allowSorting, false);
      });

      test('femaleTag column should not allow sorting', () {
        final columns = MatingListColumn.getColumns();
        final col = columns.firstWhere(
          (c) => c.columnName == MatingListColumn.femaleTag.field,
        );
        expect(col.allowSorting, false);
      });
    });

    group('getDataGridRow', () {
      test('produces correct number of cells with full data', () {
        final mating = MatingDto(
          matingId: 1,
          matingUuid: 'mating-uuid-1',
          matingTag: 'MAT-001',
          setUpDate: DateTime(2024, 1, 10),
          disbandedDate: DateTime(2024, 3, 10),
          createdDate: DateTime(2024, 1, 10),
          cage: CageSummaryDto(
            cageId: 1,
            cageUuid: 'cage-uuid-1',
            cageTag: 'CAGE-01',
          ),
          litterStrain: StrainSummaryDto(
            strainId: 1,
            strainUuid: 'strain-uuid-1',
            strainName: 'C57BL/6',
          ),
          animals: [
            AnimalSummaryDto(
              animalId: 10,
              animalUuid: 'male-uuid',
              physicalTag: 'M-01',
              sex: 'M',
            ),
            AnimalSummaryDto(
              animalId: 11,
              animalUuid: 'female-uuid-1',
              physicalTag: 'F-01',
              sex: 'F',
            ),
            AnimalSummaryDto(
              animalId: 12,
              animalUuid: 'female-uuid-2',
              physicalTag: 'F-02',
              sex: 'F',
            ),
          ],
          owner: AccountDto(
            accountUuid: 'owner-uuid',
            user: UserDto(firstName: 'Jane', lastName: 'Smith'),
          ),
        );

        final row = MatingListColumn.getDataGridRow(mating);
        // 12 cells: edit, matingTag, cageTag, litterStrain, maleTag, maleGenotypes,
        //           femaleTag, femaleGenotypes, setUpDate, disbandedDate, owner, created
        expect(row.getCells().length, 12);
      });

      test('produces correct number of cells with minimal data', () {
        final mating = MatingDto(
          matingId: 2,
          matingUuid: 'mating-uuid-2',
        );

        final row = MatingListColumn.getDataGridRow(mating);
        expect(row.getCells().length, 12);
      });

      test('cell values are set correctly for key fields', () {
        final mating = MatingDto(
          matingId: 3,
          matingUuid: 'mating-uuid-3',
          matingTag: 'MY-MATING',
          cage: CageSummaryDto(
            cageId: 1,
            cageUuid: 'cage-uuid-1',
            cageTag: 'CAGE-99',
          ),
          litterStrain: StrainSummaryDto(
            strainId: 1,
            strainUuid: 'strain-uuid-1',
            strainName: 'BALB/c',
          ),
        );

        final row = MatingListColumn.getDataGridRow(mating);
        final cells = row.getCells();

        final editCell = cells.firstWhere((c) => c.columnName == 'edit');
        expect(editCell.value, 'mating-uuid-3');

        final tagCell = cells.firstWhere((c) => c.columnName == 'matingTag');
        expect(tagCell.value, 'MY-MATING');

        final cageCell = cells.firstWhere((c) => c.columnName == 'cageTag');
        expect(cageCell.value, 'CAGE-99');

        final strainCell = cells.firstWhere((c) => c.columnName == 'litterStrain');
        expect(strainCell.value, 'BALB/c');
      });

      test('handles null animals list gracefully', () {
        final mating = MatingDto(
          matingId: 4,
          matingUuid: 'mating-uuid-4',
          animals: null,
        );

        final row = MatingListColumn.getDataGridRow(mating);
        final cells = row.getCells();
        final maleTagCell = cells.firstWhere((c) => c.columnName == 'maleTag');
        expect(maleTagCell.value, '');

        final femaleTagCell = cells.firstWhere((c) => c.columnName == 'femaleTag');
        expect(femaleTagCell.value, isA<List<String>>());
        expect((femaleTagCell.value as List<String>), isEmpty);
      });

      test('correctly separates male and female animals', () {
        final mating = MatingDto(
          matingId: 5,
          matingUuid: 'mating-uuid-5',
          animals: [
            AnimalSummaryDto(
              animalId: 20,
              animalUuid: 'male-uuid',
              physicalTag: 'MALE-TAG',
              sex: 'M',
            ),
            AnimalSummaryDto(
              animalId: 21,
              animalUuid: 'female-uuid-1',
              physicalTag: 'FEM-TAG-1',
              sex: 'F',
            ),
            AnimalSummaryDto(
              animalId: 22,
              animalUuid: 'female-uuid-2',
              physicalTag: 'FEM-TAG-2',
              sex: 'F',
            ),
          ],
        );

        final row = MatingListColumn.getDataGridRow(mating);
        final cells = row.getCells();

        final maleTagCell = cells.firstWhere((c) => c.columnName == 'maleTag');
        expect(maleTagCell.value, 'MALE-TAG');

        final femaleTagCell = cells.firstWhere((c) => c.columnName == 'femaleTag');
        expect(femaleTagCell.value, ['FEM-TAG-1', 'FEM-TAG-2']);
      });

      test('handles null cage gracefully', () {
        final mating = MatingDto(
          matingId: 6,
          matingUuid: 'mating-uuid-6',
          cage: null,
        );

        final row = MatingListColumn.getDataGridRow(mating);
        final cells = row.getCells();
        final cageCell = cells.firstWhere((c) => c.columnName == 'cageTag');
        expect(cageCell.value, '');
      });

      test('handles null litterStrain gracefully', () {
        final mating = MatingDto(
          matingId: 7,
          matingUuid: 'mating-uuid-7',
          litterStrain: null,
        );

        final row = MatingListColumn.getDataGridRow(mating);
        final cells = row.getCells();
        final strainCell = cells.firstWhere((c) => c.columnName == 'litterStrain');
        expect(strainCell.value, '');
      });
    });
  });
}
