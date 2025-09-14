import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/helpers/animal_helper.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum AnimalListColumn implements ListColumn<AnimalDto> {
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

  static List<GridColumn> getColumns() {
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

  static DataGridRow getDataGridRow(AnimalDto a) {
    return DataGridRow(
      cells: [
        DataGridCell<int>(columnName: AnimalListColumn.eid.name, value: a.eid),
        DataGridCell<String>(
          columnName: AnimalListColumn.physicalTag.name,
          value: a.physicalTag,
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.status.name,
          value: a.cage?.status,
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.sex.name,
          value: a.sex,
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.dob.name,
          value: DateTimeHelper.formatDate(a.dateOfBirth),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.age.name,
          value: AnimalHelper.getAge(a),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.wean.name,
          value: DateTimeHelper.formatDate(a.weanDate),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.cage.name,
          value: a.cage?.cageTag,
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.strain.name,
          value: a.strain?.strainName,
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.genotypes.name,
          value: GenotypeHelper.formatGenotypes(a.genotypes),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.sire.name,
          value: a.sire?.physicalTag ?? '',
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.dam.name,
          value: GenotypeHelper.getDamNames(a.dam),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.owner.name,
          value: AccountHelper.getOwnerName(a.owner),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.created.name,
          value: DateTimeHelper.formatDateTime(a.createdDate),
        ),
      ],
    );
  }
}
