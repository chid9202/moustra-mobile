import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum LitterListColumn implements ListColumn {
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
}

List<GridColumn> litterListColumns() {
  return [
    GridColumn(
      columnName: LitterListColumn.eid.field,
      width: 80,
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
      width: 220,
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
