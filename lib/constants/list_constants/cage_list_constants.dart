import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum CageListColumn implements ListColumn {
  eid('EID', 'eid'),
  cageTag('Cage Tag', 'cage_tag'),
  strain('Strain', 'strain'),
  numberOfAnimals('Number of Animals', 'num'),
  animalTags('Animal Tags', 'tags'),
  genotypes('Genotypes', 'genotypes'),
  status('Status', 'status'),
  endDate('End Date', 'end_date'),
  owner('Owner', 'owner'),
  created('Created Date', 'created_date');

  const CageListColumn(this.label, this.field);
  @override
  final String label;
  @override
  final String field;
  @override
  String get enumName => name;
}

List<GridColumn> cageListColumns() {
  return [
    GridColumn(
      columnName: CageListColumn.eid.field,
      width: 80,
      label: Center(child: Text(CageListColumn.eid.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: CageListColumn.cageTag.field,
      width: 140,
      label: Center(child: Text(CageListColumn.cageTag.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: CageListColumn.strain.field,
      width: 200,
      label: Center(child: Text(CageListColumn.strain.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: CageListColumn.numberOfAnimals.field,
      width: 140,
      label: Center(child: Text(CageListColumn.numberOfAnimals.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: CageListColumn.animalTags.field,
      width: 240,
      label: Center(child: Text(CageListColumn.animalTags.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: CageListColumn.genotypes.field,
      width: 260,
      label: Center(child: Text(CageListColumn.genotypes.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: CageListColumn.status.field,
      width: 120,
      label: Center(child: Text(CageListColumn.status.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: CageListColumn.endDate.field,
      width: 160,
      label: Center(child: Text(CageListColumn.endDate.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: CageListColumn.owner.field,
      width: 220,
      label: Center(child: Text(CageListColumn.owner.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: CageListColumn.created.field,
      width: 180,
      label: Center(child: Text(CageListColumn.created.label)),
      allowSorting: true,
    ),
  ];
}
