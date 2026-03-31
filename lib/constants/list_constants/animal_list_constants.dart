import 'package:moustra/constants/list_constants/common.dart' hide SortOrder;
import 'package:moustra/helpers/animal_helper.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/genotype_helper.dart';
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
  tailDate('Tail Date', 'tail_date'),
  cage('Cage Tag', 'cage_tag'),
  strain('Strain', 'strain'),
  genotypes('Genotypes', 'genotypes'),
  endDate('End Date', 'end_date'),
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
          columnName: AnimalListColumn.endDate.name,
          value: DateTimeHelper.parseIsoToDate(a.endDate?.toIso8601String()),
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
          columnName: AnimalListColumn.tailDate.name,
          value: DateTimeHelper.formatDate(a.tailDate),
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
