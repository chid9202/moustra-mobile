import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum LitterListColumn implements ListColumn<LitterDto> {
  select('', 'select'),
  edit('Edit', 'edit'),
  // eid('EID', 'eid'),
  litterTag('Litter Tag', 'litter_tag'),
  strain('Strain', 'litter_strain'),
  numberOfPups('Number of Pups', 'number_of_pups'),
  matingTag('Mating Tag', 'mating_tag'),
  wean('Wean Date', 'wean_date'),
  dob('Date of Birth', 'date_of_birth'),
  owner('Owner', 'owner'),
  created('Created Date', 'created_date'),
  endDate('End Date', 'end_date');

  const LitterListColumn(this.label, this.field);
  @override
  final String label;
  @override
  final String field;
  @override
  String get enumName => name;

  static DataGridRow getDataGridRow(LitterDto litter) {
    return DataGridRow(
      cells: [
        DataGridCell<String>(
          columnName: LitterListColumn.select.name,
          value: litter.litterUuid,
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.edit.name,
          value: litter.litterUuid,
        ),
        // DataGridCell<int>(
        //   columnName: LitterListColumn.eid.name,
        //   value: litter.eid,
        // ),
        DataGridCell<String>(
          columnName: LitterListColumn.litterTag.name,
          value: litter.litterTag,
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.strain.name,
          value: litter.strain?.strainName,
        ),
        DataGridCell<int>(
          columnName: LitterListColumn.numberOfPups.name,
          value: litter.animals.length,
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.matingTag.name,
          value: litter.mating?.matingTag ?? '',
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.wean.name,
          value: DateTimeHelper.formatDate(litter.weanDate),
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.dob.name,
          value: DateTimeHelper.formatDate(litter.dateOfBirth),
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.owner.name,
          value: AccountHelper.getOwnerName(litter.owner),
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.created.name,
          value: DateTimeHelper.formatDateTime(litter.createdDate),
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.endDate.name,
          value: '',
        ),
      ],
    );
  }
}
