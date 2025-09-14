import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum MatingListColumn implements ListColumn {
  eid('EID', 'eid'),
  matingTag('Mating Tag', 'mating_tag'),
  cageTag('Cage Tag', 'cage_tag'),
  litterStrain('Litter Strain', 'litter_strain'),
  maleTag('Male Tag', 'male_tag'),
  maleGenotypes('Male Genotypes', 'male_genotypes'),
  femaleTag('Female Tag', 'female_tag'),
  femaleGenotypes('Female Genotypes', 'female_genotypes'),
  setUpDate('Set Up Date', 'set_up_date'),
  disbandedDate('Disbanded Date', 'disbanded_date'),
  owner('Owner', 'owner'),
  created('Created Date', 'created_date');

  const MatingListColumn(this.label, this.field);
  @override
  final String label;
  @override
  final String field;
  @override
  String get enumName => name;
}

List<GridColumn> matingListColumns() {
  return [
    GridColumn(
      columnName: MatingListColumn.eid.field,
      width: 80,
      label: Center(child: Text(MatingListColumn.eid.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: MatingListColumn.matingTag.field,
      width: 140,
      label: Center(child: Text(MatingListColumn.matingTag.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: MatingListColumn.cageTag.field,
      width: 140,
      label: Center(child: Text(MatingListColumn.cageTag.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: MatingListColumn.litterStrain.field,
      width: 200,
      label: Center(child: Text(MatingListColumn.litterStrain.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: MatingListColumn.maleTag.field,
      width: 140,
      label: Center(child: Text(MatingListColumn.maleTag.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: MatingListColumn.maleGenotypes.field,
      width: 260,
      label: Center(child: Text(MatingListColumn.maleGenotypes.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: MatingListColumn.femaleTag.field,
      width: 140,
      label: Center(child: Text(MatingListColumn.femaleTag.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: MatingListColumn.femaleGenotypes.field,
      width: 260,
      label: Center(child: Text(MatingListColumn.femaleGenotypes.label)),
      allowSorting: false,
    ),
    GridColumn(
      columnName: MatingListColumn.setUpDate.field,
      width: 140,
      label: Center(child: Text(MatingListColumn.setUpDate.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: MatingListColumn.disbandedDate.field,
      width: 160,
      label: Center(child: Text(MatingListColumn.disbandedDate.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: MatingListColumn.owner.field,
      width: 220,
      label: Center(child: Text(MatingListColumn.owner.label)),
      allowSorting: true,
    ),
    GridColumn(
      columnName: MatingListColumn.created.field,
      width: 180,
      label: Center(child: Text(MatingListColumn.created.label)),
      allowSorting: true,
    ),
  ];
}
