import 'package:flutter/material.dart';
import 'package:moustra/constants/animal_constants.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum MatingListColumn implements ListColumn<MatingDto> {
  edit('Edit', 'edit'),
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

  static List<GridColumn> getColumns() {
    return [
      GridColumn(
        columnName: MatingListColumn.edit.field,
        width: 72,
        label: Center(child: Text(MatingListColumn.edit.label)),
        allowSorting: false,
      ),
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

  static DataGridRow getDataGridRow(MatingDto m) {
    final int eid = (m.eid ?? 0);
    final String matingTag = (m.matingTag ?? '').toString();
    final String cageTag = (m.cage?.cageTag ?? '').toString();
    final String litterStrain = (m.litterStrain?.strainName ?? '').toString();
    final List<AnimalSummaryDto> animals = m.animals ?? [];
    final AnimalSummaryDto? male = animals.cast<AnimalSummaryDto?>().firstWhere(
      (a) => (a?.sex ?? '') == SexConstants.male,
      orElse: () => null,
    );
    final List<AnimalSummaryDto> females = animals
        .where((a) => (a.sex ?? '') == SexConstants.female)
        .cast<AnimalSummaryDto>()
        .toList();
    final String maleTag = (male?.physicalTag ?? '').toString();
    final List<String> femaleTags = females
        .map((f) => (f.physicalTag ?? '').toString())
        .where((t) => t.isNotEmpty)
        .toList();
    final String maleGenotypes = GenotypeHelper.formatGenotypes(
      male?.genotypes,
    );
    final List<String> femaleGenotypeLines = females
        .map((f) => GenotypeHelper.formatGenotypes(f.genotypes))
        .where((g) => g.isNotEmpty)
        .toList();
    final String setUpDate = DateTimeHelper.formatDate(m.setUpDate);
    final String disbandedDate = DateTimeHelper.formatDate(m.disbandedDate);
    final String owner = AccountHelper.getOwnerName(m.owner);
    final String created = DateTimeHelper.formatDateTime(m.createdDate);
    return DataGridRow(
      cells: [
        DataGridCell<String>(
          columnName: MatingListColumn.edit.name,
          value: m.matingUuid,
        ),
        DataGridCell<int>(columnName: MatingListColumn.eid.name, value: eid),
        DataGridCell<String>(
          columnName: MatingListColumn.matingTag.name,
          value: matingTag,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.cageTag.name,
          value: cageTag,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.litterStrain.name,
          value: litterStrain,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.maleTag.name,
          value: maleTag,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.maleGenotypes.name,
          value: maleGenotypes,
        ),
        DataGridCell<List<String>>(
          columnName: MatingListColumn.femaleTag.name,
          value: femaleTags,
        ),
        DataGridCell<List<String>>(
          columnName: MatingListColumn.femaleGenotypes.name,
          value: femaleGenotypeLines,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.setUpDate.name,
          value: setUpDate,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.disbandedDate.name,
          value: disbandedDate,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.owner.name,
          value: owner,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.created.name,
          value: created,
        ),
      ],
    );
  }
}
