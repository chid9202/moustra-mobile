import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum StrainListColumn implements ListColumn {
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
}

List<GridColumn> strainListColumns() {
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
