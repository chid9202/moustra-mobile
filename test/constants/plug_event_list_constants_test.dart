import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/plug_event_list_constants.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

void main() {
  group('PlugEventListColumn', () {
    test('all columns have non-empty field names', () {
      for (final col in PlugEventListColumn.values) {
        expect(col.field, isNotEmpty, reason: '${col.name} field');
      }
    });

    test('enumName matches dart name', () {
      expect(PlugEventListColumn.plugDate.enumName, 'plugDate');
      expect(PlugEventListColumn.outcome.enumName, 'outcome');
    });

    group('getDataGridRow', () {
      test('cell count matches enum length', () {
        final dto = PlugEventDto(
          plugEventUuid: 'pe-1',
          plugDate: '2024-01-15T00:00:00Z',
        );
        final row = PlugEventListColumn.getDataGridRow(dto);
        expect(row.getCells().length, PlugEventListColumn.values.length);
      });

      test('edit cell carries plug event uuid', () {
        final dto = PlugEventDto(
          plugEventUuid: 'uuid-pe',
          plugDate: '2024-01-15T00:00:00Z',
        );
        final row = PlugEventListColumn.getDataGridRow(dto);
        final editCell = row.getCells().firstWhere(
              (c) => c.columnName == PlugEventListColumn.edit.name,
            )
            as DataGridCell<String>;
        expect(editCell.value, 'uuid-pe');
      });

      test('outcome null or empty displays Active', () {
        final noOutcome = PlugEventDto(
          plugEventUuid: 'a',
          plugDate: '2024-01-15T00:00:00Z',
          outcome: null,
        );
        final emptyOutcome = PlugEventDto(
          plugEventUuid: 'b',
          plugDate: '2024-01-15T00:00:00Z',
          outcome: '',
        );
        for (final dto in [noOutcome, emptyOutcome]) {
          final row = PlugEventListColumn.getDataGridRow(dto);
          final outcomeCell = row.getCells().firstWhere(
                (c) => c.columnName == PlugEventListColumn.outcome.name,
              )
              as DataGridCell<String>;
          expect(outcomeCell.value, 'Active');
        }
      });

      test('outcome snake_case is title cased', () {
        final dto = PlugEventDto(
          plugEventUuid: 'c',
          plugDate: '2024-01-15T00:00:00Z',
          outcome: 'live_birth',
        );
        final row = PlugEventListColumn.getDataGridRow(dto);
        final outcomeCell = row.getCells().firstWhere(
              (c) => c.columnName == PlugEventListColumn.outcome.name,
            )
            as DataGridCell<String>;
        expect(outcomeCell.value, 'Live Birth');
      });

      test('maps tags and owner display', () {
        final dto = PlugEventDto(
          plugEventUuid: 'pe-full',
          plugDate: '2024-02-01T12:00:00Z',
          eid: 42,
          female: AnimalSummaryDto(
            animalId: 1,
            animalUuid: 'f1',
            physicalTag: 'F99',
            dateOfBirth: DateTime(2023),
            sex: 'F',
          ),
          male: AnimalSummaryDto(
            animalId: 2,
            animalUuid: 'm1',
            physicalTag: 'M88',
            dateOfBirth: DateTime(2023),
            sex: 'M',
          ),
          mating: MatingSummaryDto(
            matingUuid: 'mat-1',
            matingTag: 'MAT-7',
          ),
          currentEday: 3.5,
          targetEday: 19,
          owner: AccountDto(
            accountUuid: 'acc',
            user: UserDto(firstName: 'Pat', lastName: 'Lee'),
          ),
          createdDate: '2024-02-01T08:00:00Z',
        );
        final row = PlugEventListColumn.getDataGridRow(dto);
        String cell(String name) {
          return (row.getCells().firstWhere((c) => c.columnName == name)
                  as DataGridCell<String>)
              .value!;
        }

        expect(cell(PlugEventListColumn.eid.name), '42');
        expect(cell(PlugEventListColumn.femaleTag.name), 'F99');
        expect(cell(PlugEventListColumn.maleTag.name), 'M88');
        expect(cell(PlugEventListColumn.matingTag.name), 'MAT-7');
        expect(cell(PlugEventListColumn.currentEday.name), '3.5');
        expect(cell(PlugEventListColumn.targetEday.name), '19.0');
        expect(cell(PlugEventListColumn.owner.name), 'Pat Lee');
      });
    });
  });
}
