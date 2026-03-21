import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/animal_list_constants.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';

void main() {
  group('AnimalListColumn', () {
    late ValueNotifier<SortParam?> sortNotifier;

    setUp(() {
      sortNotifier = ValueNotifier(null);
    });

    tearDown(() {
      sortNotifier.dispose();
    });

    group('enum values', () {
      test('all columns have non-empty field names', () {
        for (final col in AnimalListColumn.values) {
          expect(col.field, isNotEmpty,
              reason: '${col.name} should have a non-empty field');
        }
      });

      test('enumName returns the dart enum name', () {
        expect(AnimalListColumn.physicalTag.enumName, 'physicalTag');
        expect(AnimalListColumn.sex.enumName, 'sex');
        expect(AnimalListColumn.dob.enumName, 'dob');
      });

      test('select column has empty label', () {
        expect(AnimalListColumn.select.label, '');
        expect(AnimalListColumn.select.field, 'select');
      });

      test('physicalTag column has correct field and label', () {
        expect(AnimalListColumn.physicalTag.field, 'physical_tag');
        expect(AnimalListColumn.physicalTag.label, 'Physical Tag');
      });

      test('status column has correct field and label', () {
        expect(AnimalListColumn.status.field, 'status');
        expect(AnimalListColumn.status.label, 'Status');
      });
    });

    group('getColumns', () {
      test('should return 14 columns with default parameters', () {
        final columns = AnimalListColumn.getColumns(
          sortNotifier: sortNotifier,
        );
        expect(columns.length, 14);
      });

      test(
          'select column should be visible by default (includeSelect defaults to true)',
          () {
        final columns = AnimalListColumn.getColumns(
          sortNotifier: sortNotifier,
        );
        final selectColumn = columns.firstWhere(
          (c) => c.columnName == AnimalListColumn.select.field,
        );
        expect(selectColumn.visible, true);
      });

      test('select column should be hidden when includeSelect is false', () {
        final columns = AnimalListColumn.getColumns(
          includeSelect: false,
          sortNotifier: sortNotifier,
        );
        final selectColumn = columns.firstWhere(
          (c) => c.columnName == AnimalListColumn.select.field,
        );
        expect(selectColumn.visible, false);
      });

      test('physicalTag column should allow sorting', () {
        final columns = AnimalListColumn.getColumns(
          sortNotifier: sortNotifier,
        );
        final col = columns.firstWhere(
          (c) => c.columnName == AnimalListColumn.physicalTag.field,
        );
        expect(col.allowSorting, true);
      });

      test('genotypes column should not allow sorting', () {
        final columns = AnimalListColumn.getColumns(
          sortNotifier: sortNotifier,
        );
        final col = columns.firstWhere(
          (c) => c.columnName == AnimalListColumn.genotypes.field,
        );
        expect(col.allowSorting, false);
      });

      test('returns unmodified columns when settingFields is null', () {
        final columns = AnimalListColumn.getColumns(
          sortNotifier: sortNotifier,
          settingFields: null,
        );
        expect(columns.length, 14);
      });
    });

    group('getDataGridRow', () {
      test('produces correct number of cells with full data', () {
        final animal = AnimalDto(
          eid: 1,
          animalId: 100,
          animalUuid: 'uuid-animal-1',
          physicalTag: 'TAG-001',
          sex: 'M',
          dateOfBirth: DateTime(2024, 1, 15),
          weanDate: DateTime(2024, 2, 5),
          createdDate: DateTime(2024, 1, 15),
          genotypes: [],
          cage: CageSummaryDto(
            cageId: 1,
            cageUuid: 'cage-uuid-1',
            cageTag: 'CAGE-01',
            status: 'active',
          ),
          strain: StrainSummaryDto(
            strainId: 1,
            strainUuid: 'strain-uuid-1',
            strainName: 'C57BL/6',
          ),
          sire: AnimalSummaryDto(
            animalId: 50,
            animalUuid: 'sire-uuid',
            physicalTag: 'SIRE-01',
          ),
          dam: [
            AnimalSummaryDto(
              animalId: 51,
              animalUuid: 'dam-uuid',
              physicalTag: 'DAM-01',
            ),
          ],
          owner: AccountDto(
            accountUuid: 'owner-uuid',
            user: UserDto(firstName: 'John', lastName: 'Doe'),
          ),
        );

        final row = AnimalListColumn.getDataGridRow(animal);
        // 14 cells: select, physicalTag, sex, dob, genotypes, status, age, wean, cage, strain, sire, dam, owner, created
        expect(row.getCells().length, 14);
      });

      test(
          'produces correct number of cells with minimal data (null optional fields)',
          () {
        final animal = AnimalDto(
          eid: 2,
          animalId: 101,
          animalUuid: 'uuid-animal-2',
        );

        final row = AnimalListColumn.getDataGridRow(animal);
        expect(row.getCells().length, 14);
      });

      test('cell values are set correctly for key fields', () {
        final animal = AnimalDto(
          eid: 3,
          animalId: 102,
          animalUuid: 'uuid-animal-3',
          physicalTag: 'MY-TAG',
          sex: 'F',
        );

        final row = AnimalListColumn.getDataGridRow(animal);
        final cells = row.getCells();

        // select cell has animalUuid
        final selectCell =
            cells.firstWhere((c) => c.columnName == 'select');
        expect(selectCell.value, 'uuid-animal-3');

        // physicalTag cell
        final tagCell =
            cells.firstWhere((c) => c.columnName == 'physicalTag');
        expect(tagCell.value, 'MY-TAG');

        // sex cell
        final sexCell = cells.firstWhere((c) => c.columnName == 'sex');
        expect(sexCell.value, 'F');
      });

      test('handles null cage gracefully', () {
        final animal = AnimalDto(
          eid: 4,
          animalId: 103,
          animalUuid: 'uuid-animal-4',
          cage: null,
        );

        final row = AnimalListColumn.getDataGridRow(animal);
        final cells = row.getCells();
        final statusCell =
            cells.firstWhere((c) => c.columnName == 'status');
        expect(statusCell.value, isNull);

        final cageCell = cells.firstWhere((c) => c.columnName == 'cage');
        expect(cageCell.value, isNull);
      });

      test('handles null strain gracefully', () {
        final animal = AnimalDto(
          eid: 5,
          animalId: 104,
          animalUuid: 'uuid-animal-5',
          strain: null,
        );

        final row = AnimalListColumn.getDataGridRow(animal);
        final cells = row.getCells();
        final strainCell =
            cells.firstWhere((c) => c.columnName == 'strain');
        expect(strainCell.value, isNull);
      });

      test('handles null sire with empty string fallback', () {
        final animal = AnimalDto(
          eid: 6,
          animalId: 105,
          animalUuid: 'uuid-animal-6',
          sire: null,
        );

        final row = AnimalListColumn.getDataGridRow(animal);
        final cells = row.getCells();
        final sireCell = cells.firstWhere((c) => c.columnName == 'sire');
        expect(sireCell.value, '');
      });
    });
  });
}
