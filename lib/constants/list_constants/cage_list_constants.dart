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
  numberOfAnimals('Number of Animals', 'number_of_animals'),
  animalTags('Animal Tags', 'animal_tags'),
  genotypes('Genotypes', 'genotypes'),
  rack('Rack', 'rack'),
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
          columnName: CageListColumn.rack.name,
          value: cage.rack?.rackName ?? '',
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
