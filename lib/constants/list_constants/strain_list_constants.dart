import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/helpers/strain_helper.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum StrainListColumn implements ListColumn<StrainDto> {
  select('', 'select'),
  edit('Edit', 'edit'),
  strainName('Name', 'name'),
  animals('Animals', 'animals'),
  color('Color', 'color'),
  owner('Owner', 'owner'),
  created('Created Date', 'created_date'),
  background('Background', 'background'),
  active('Active', 'active');

  const StrainListColumn(this.label, this.field);
  @override
  final String label;
  @override
  final String field;
  @override
  String get enumName => name;

  static List<GridColumn> getColumns() {
    return [
      GridColumn(
        columnName: StrainListColumn.select.field,
        width: 56,
        label: const SizedBox.shrink(),
        allowSorting: false,
      ),
      GridColumn(
        columnName: StrainListColumn.edit.field,
        width: 72,
        label: Center(child: Text(StrainListColumn.edit.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: StrainListColumn.strainName.field,
        width: 240,
        label: Center(child: Text(StrainListColumn.strainName.label)),
        allowSorting: true,
      ),
      GridColumn(
        columnName: StrainListColumn.animals.field,
        width: 100,
        label: Center(child: Text(StrainListColumn.animals.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: StrainListColumn.color.field,
        width: 80,
        label: Center(child: Text(StrainListColumn.color.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: StrainListColumn.owner.field,
        width: 220,
        label: Center(child: Text(StrainListColumn.owner.label)),
        allowSorting: true,
      ),
      GridColumn(
        columnName: StrainListColumn.created.field,
        width: 180,
        label: Center(child: Text(StrainListColumn.created.label)),
        allowSorting: true,
      ),
      GridColumn(
        columnName: StrainListColumn.background.field,
        width: 200,
        label: Center(child: Text(StrainListColumn.background.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: StrainListColumn.active.field,
        width: 100,
        label: Center(child: Text(StrainListColumn.active.label)),
      ),
    ];
  }

  static DataGridRow getDataGridRow(StrainDto strain) {
    return DataGridRow(
      cells: [
        DataGridCell<String>(
          columnName: StrainListColumn.select.name,
          value: strain.strainUuid,
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.edit.name,
          value: strain.strainUuid,
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.strainName.name,
          value: strain.strainName,
        ),
        DataGridCell<int>(
          columnName: StrainListColumn.animals.name,
          value: strain.numberOfAnimals,
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.color.name,
          value: strain.color ?? '',
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.owner.name,
          value: AccountHelper.getOwnerName(strain.owner),
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.created.name,
          value: DateTimeHelper.formatDateTime(strain.createdDate),
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.background.name,
          value: StrainHelper.getBackgroundNames(strain.backgrounds),
        ),
        DataGridCell<bool>(
          columnName: StrainListColumn.active.name,
          value: strain.isActive,
        ),
      ],
    );
  }
}
