import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:moustra/helpers/strain_helper.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum StrainListColumn implements ListColumn<StrainDto> {
  select('', 'select'),
  edit('Edit', 'edit'),
  strainName('Name', 'strain_name'),
  animals('Animals', 'number_of_animals'),
  color('Color', 'color'),
  owner('Owner', 'owner'),
  created('Created Date', 'created_date'),
  background('Background', 'background'),
  genotypes('Genotypes', 'genotypes'),
  active('Active', 'is_active');

  const StrainListColumn(this.label, this.field);
  @override
  final String label;
  @override
  final String field;
  @override
  String get enumName => name;

  static DataGridRow getDataGridRow(StrainDto strain) {
    return DataGridRow(
      cells: [
        DataGridCell<String>(
          columnName: StrainListColumn.select.name,
          value: strain.strainUuid,
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.edit.name,
          value: strain.strainUuid,
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.strainName.name,
          value: strain.strainName,
        ),
        DataGridCell<int>(
          columnName: StrainListColumn.animals.name,
          value: strain.numberOfAnimals,
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.color.name,
          value: strain.color ?? '',
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.owner.name,
          value: AccountHelper.getOwnerName(strain.owner),
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.created.name,
          value: DateTimeHelper.formatDateTime(strain.createdDate),
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.background.name,
          value: StrainHelper.getBackgroundNames(strain.backgrounds),
        ),
        DataGridCell<String>(
          columnName: StrainListColumn.genotypes.name,
          value: GenotypeHelper.formatGenotypes(strain.genotypes),
        ),
        DataGridCell<bool>(
          columnName: StrainListColumn.active.name,
          value: strain.isActive,
        ),
      ],
    );
  }
}
