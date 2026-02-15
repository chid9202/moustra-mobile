import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum CageListColumn implements ListColumn<CageDto> {
  select('', 'select'),
  edit('Edit', 'edit'),
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

  static List<GridColumn> getColumns({
    bool includeSelect = false,
    bool useEid = false,
  }) {
    return [
      GridColumn(
        columnName: CageListColumn.select.field,
        width: selectColumnWidth,
        label: const SizedBox.shrink(),
        allowSorting: false,
        visible: includeSelect,
      ),
      GridColumn(
        columnName: CageListColumn.edit.field,
        width: editColumnWidth,
        label: Center(child: Text(CageListColumn.edit.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: CageListColumn.eid.field,
        width: eidColumnWidth,
        label: Center(child: Text(CageListColumn.eid.label)),
        allowSorting: false,
        visible: useEid,
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
        width: ownerColumnWidth,
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

  static DataGridRow getDataGridRow(CageDto cage) {
    final List<dynamic> animals =
        (cage.animals as List<dynamic>? ?? <dynamic>[]);
    final int numAnimals = animals.length;
    final List<String> animalTagLines = animals
        .map((a) => (a.physicalTag ?? '').toString())
        .where((t) => t.isNotEmpty)
        .toList();
    return DataGridRow(
      cells: [
        DataGridCell<String>(
          columnName: CageListColumn.select.name,
          value: cage.cageUuid,
        ),
        DataGridCell<String>(
          columnName: CageListColumn.edit.name,
          value: cage.cageUuid,
        ),
        DataGridCell<int>(columnName: CageListColumn.eid.name, value: cage.eid),
        DataGridCell<String>(
          columnName: CageListColumn.cageTag.name,
          value: cage.cageTag,
        ),
        DataGridCell<String>(
          columnName: CageListColumn.strain.name,
          value: cage.strain?.strainName ?? '',
        ),
        DataGridCell<int>(
          columnName: CageListColumn.numberOfAnimals.name,
          value: numAnimals,
        ),
        DataGridCell<List<String>>(
          columnName: CageListColumn.animalTags.name,
          value: animalTagLines,
        ),
        DataGridCell<List<String>>(
          columnName: CageListColumn.genotypes.name,
          value: cage.animals
              .map((a) => GenotypeHelper.formatGenotypes(a.genotypes))
              .toList(),
        ),
        DataGridCell<String>(
          columnName: CageListColumn.status.name,
          value: cage.status,
        ),
        DataGridCell<String>(
          columnName: CageListColumn.endDate.name,
          value: DateTimeHelper.formatDate(cage.endDate),
        ),
        DataGridCell<String>(
          columnName: CageListColumn.owner.name,
          value: AccountHelper.getOwnerName(cage.owner),
        ),
        DataGridCell<String>(
          columnName: CageListColumn.created.name,
          value: DateTimeHelper.formatDateTime(cage.createdDate),
        ),
      ],
    );
  }
}
