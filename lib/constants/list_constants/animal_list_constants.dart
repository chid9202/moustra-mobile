import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum AnimalListColumn implements ListColumn {
  eid('EID', 'eid'),
  physicalTag('Physical Tag', 'physical_tag'),
  status('Status', 'status'),
  sex('Sex', 'sex'),
  dob('Date of Birth', 'date_of_birth'),
  age('Age', 'age'),
  wean('Wean Date', 'wean_date'),
  cage('Cage Tag', 'cage_tag'),
  strain('Strain', 'strain'),
  genotypes('Genotypes', 'genotypes'),
  sire('Sire', 'sire'),
  dam('Dam', 'dam'),
  owner('Owner', 'owner'),
  created('Created Date', 'created_date');

  const AnimalListColumn(this.label, this.field);
  @override
  final String label;
  @override
  final String field;
  @override
  String get enumName => name;
}

List<GridColumn> animalListColumns() {
  return [
    GridColumn(
      columnName: AnimalListColumn.eid.field,
      width: 80,
      label: Center(child: Text(AnimalListColumn.eid.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: AnimalListColumn.physicalTag.field,
      width: 120,
      label: Center(child: Text(AnimalListColumn.physicalTag.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: AnimalListColumn.status.field,
      width: 100,
      label: Center(child: Text(AnimalListColumn.status.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: AnimalListColumn.sex.field,
      width: 80,
      label: Center(child: Text(AnimalListColumn.sex.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: AnimalListColumn.dob.field,
      width: 140,
      label: Center(child: Text(AnimalListColumn.dob.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: AnimalListColumn.age.field,
      width: 80,
      label: Center(child: Text(AnimalListColumn.age.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: AnimalListColumn.wean.field,
      width: 140,
      label: Center(child: Text(AnimalListColumn.wean.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: AnimalListColumn.cage.field,
      width: 120,
      label: Center(child: Text(AnimalListColumn.cage.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: AnimalListColumn.strain.field,
      width: 200,
      label: Center(child: Text(AnimalListColumn.strain.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: AnimalListColumn.genotypes.field,
      width: 240,
      label: Center(child: Text(AnimalListColumn.genotypes.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: AnimalListColumn.sire.field,
      width: 160,
      label: Center(child: Text(AnimalListColumn.sire.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: AnimalListColumn.dam.field,
      width: 160,
      label: Center(child: Text(AnimalListColumn.dam.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: AnimalListColumn.owner.field,
      width: 220,
      label: Center(child: Text(AnimalListColumn.owner.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: AnimalListColumn.created.field,
      width: 180,
      label: Center(child: Text(AnimalListColumn.created.label)),
      allowSorting: true,
    ),
  ];
}
