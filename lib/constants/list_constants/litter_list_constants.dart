import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum LitterListColumn implements ListColumn<LitterDto> {
  edit('Edit', 'edit'),
  eid('EID', 'eid'),
  litterTag('Litter Tag', 'litter_tag'),
  litterStrain('Litter Strain', 'litter_strain'),
  numberOfPups('Number of Pups', ''),
  wean('Wean Date', 'wean_date'),
  dob('Date of Birth', 'date_of_birth'),
  owner('Owner', 'owner'),
  created('Created Date', 'created_date');

  const LitterListColumn(this.label, this.field);
  @override
  final String label;
  @override
  final String field;
  @override
  String get enumName => name;

  static List<GridColumn> getColumns() {
    return [
      GridColumn(
        columnName: LitterListColumn.edit.field,
        width: editColumnWidth,
        label: Center(child: Text(LitterListColumn.edit.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: LitterListColumn.eid.field,
        width: eidColumnWidth,
        label: Center(child: Text(LitterListColumn.eid.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: LitterListColumn.litterTag.field,
        width: 140,
        label: Center(child: Text(LitterListColumn.litterTag.label)),
        allowSorting: true,
      ),
      GridColumn(
        columnName: LitterListColumn.litterStrain.field,
        width: 200,
        label: Center(child: Text(LitterListColumn.litterStrain.label)),
        allowSorting: true,
      ),
      GridColumn(
        columnName: LitterListColumn.numberOfPups.field,
        width: 160,
        label: Center(child: Text(LitterListColumn.numberOfPups.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: LitterListColumn.wean.field,
        width: 140,
        label: Center(child: Text(LitterListColumn.wean.label)),
        allowSorting: true,
      ),
      GridColumn(
        columnName: LitterListColumn.dob.field,
        width: 160,
        label: Center(child: Text(LitterListColumn.dob.label)),
        allowSorting: true,
      ),
      GridColumn(
        columnName: LitterListColumn.owner.field,
        width: ownerColumnWidth,
        label: Center(child: Text(LitterListColumn.owner.label)),
        allowSorting: true,
      ),
      GridColumn(
        columnName: LitterListColumn.created.field,
        width: 180,
        label: Center(child: Text(LitterListColumn.created.label)),
        allowSorting: true,
      ),
    ];
  }

  static DataGridRow getDataGridRow(LitterDto litter) {
    return DataGridRow(
      cells: [
        DataGridCell<String>(
          columnName: LitterListColumn.edit.name,
          value: litter.litterUuid,
        ),
        DataGridCell<int>(
          columnName: LitterListColumn.eid.name,
          value: litter.eid,
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.litterTag.name,
          value: litter.litterTag,
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.litterStrain.name,
          value: litter.mating?.litterStrain?.strainName,
        ),
        DataGridCell<int>(
          columnName: LitterListColumn.numberOfPups.name,
          value: litter.animals.length,
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.wean.name,
          value: DateTimeHelper.formatDate(litter.weanDate),
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.dob.name,
          value: DateTimeHelper.formatDate(litter.dateOfBirth),
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.owner.name,
          value: AccountHelper.getOwnerName(litter.owner),
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.created.name,
          value: DateTimeHelper.formatDateTime(litter.createdDate),
        ),
      ],
    );
  }
}
