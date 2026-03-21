import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart' hide SortOrder;
import 'package:moustra/helpers/animal_helper.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra_api/moustra_api.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum AnimalListColumn implements ListColumn<AnimalDto> {
  select('', 'select'),
  // eid('EID', 'eid'),
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

  static List<GridColumn> getColumns({
    bool includeSelect = true,
    required ValueNotifier<SortParam?> sortNotifier,
    List<TableSettingFieldSLR>? settingFields,
  }) {
    Widget sortableLabel(String text, String field, {double leftPadding = 4}) {
      return ValueListenableBuilder<SortParam?>(
        valueListenable: sortNotifier,
        builder: (context, activeSort, _) {
          final isActive = activeSort?.field == field;
          final isAsc = activeSort?.order == SortOrder.asc;
          return Padding(
            padding: EdgeInsets.only(left: leftPadding, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 2),
                Opacity(
                  opacity: isActive ? 1.0 : 0.35,
                  child: Icon(
                    isActive
                        ? (isAsc ? Icons.arrow_upward : Icons.arrow_downward)
                        : Icons.unfold_more,
                    size: 12,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    final columns = [
      GridColumn(
        columnName: AnimalListColumn.select.field,
        width: selectColumnWidth,
        label: const SizedBox.shrink(),
        allowSorting: false,
        visible: includeSelect,
      ),
      // GridColumn(
      //   columnName: AnimalListColumn.eid.field,
      //   width: 80,
      //   label: Center(child: Text(AnimalListColumn.eid.label)),
      //   allowSorting: false,
      // ),
      GridColumn(
        columnName: AnimalListColumn.physicalTag.field,
        width: 120,
        label: sortableLabel(
          AnimalListColumn.physicalTag.label,
          AnimalListColumn.physicalTag.field,
          leftPadding: 12,
        ),
        allowSorting: true,
      ),
      GridColumn(
        columnName: AnimalListColumn.sex.field,
        width: 48,
        label: sortableLabel(
          AnimalListColumn.sex.label,
          AnimalListColumn.sex.field,
        ),
        allowSorting: true,
      ),
      GridColumn(
        columnName: AnimalListColumn.dob.field,
        width: 110,
        label: sortableLabel(
          AnimalListColumn.dob.label,
          AnimalListColumn.dob.field,
        ),
        allowSorting: true,
      ),
      GridColumn(
        columnName: AnimalListColumn.genotypes.field,
        width: 240,
        label: Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 4), child: Text(AnimalListColumn.genotypes.label))),
        allowSorting: false,
      ),
      GridColumn(
        columnName: AnimalListColumn.status.field,
        width: 100,
        label: sortableLabel(
          AnimalListColumn.status.label,
          AnimalListColumn.status.field,
        ),
        allowSorting: true,
      ),
      GridColumn(
        columnName: AnimalListColumn.age.field,
        width: 80,
        label: Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 4), child: Text(AnimalListColumn.age.label))),
        allowSorting: false,
      ),
      GridColumn(
        columnName: AnimalListColumn.wean.field,
        width: 140,
        label: sortableLabel(
          AnimalListColumn.wean.label,
          AnimalListColumn.wean.field,
        ),
        allowSorting: true,
      ),
      GridColumn(
        columnName: AnimalListColumn.cage.field,
        width: 120,
        label: sortableLabel(
          AnimalListColumn.cage.label,
          AnimalListColumn.cage.field,
        ),
        allowSorting: true,
      ),
      GridColumn(
        columnName: AnimalListColumn.strain.field,
        width: 200,
        label: sortableLabel(
          AnimalListColumn.strain.label,
          AnimalListColumn.strain.field,
        ),
        allowSorting: true,
      ),
      GridColumn(
        columnName: AnimalListColumn.sire.field,
        width: 160,
        label: Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 4), child: Text(AnimalListColumn.sire.label))),
        allowSorting: false,
      ),
      GridColumn(
        columnName: AnimalListColumn.dam.field,
        width: 160,
        label: Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 4), child: Text(AnimalListColumn.dam.label))),
        allowSorting: false,
      ),
      GridColumn(
        columnName: AnimalListColumn.owner.field,
        width: ownerColumnWidth,
        label: sortableLabel(
          AnimalListColumn.owner.label,
          AnimalListColumn.owner.field,
        ),
        allowSorting: true,
      ),
      GridColumn(
        columnName: AnimalListColumn.created.field,
        width: 180,
        label: sortableLabel(
          AnimalListColumn.created.label,
          AnimalListColumn.created.field,
        ),
        allowSorting: true,
      ),
    ];
    return applyTableSettings(columns, settingFields);
  }

  static DataGridRow getDataGridRow(AnimalDto a) {
    return DataGridRow(
      cells: [
        DataGridCell<String>(
          columnName: AnimalListColumn.select.name,
          value: a.animalUuid,
        ),
        // DataGridCell<int>(columnName: AnimalListColumn.eid.name, value: a.eid),
        DataGridCell<String>(
          columnName: AnimalListColumn.physicalTag.name,
          value: a.physicalTag,
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
          columnName: AnimalListColumn.genotypes.name,
          value: GenotypeHelper.formatGenotypes(a.genotypes),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.status.name,
          value: a.cage?.status,
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
