import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum PlugEventListColumn implements ListColumn<PlugEventDto> {
  edit('Edit', 'edit'),
  eid('Plug ID', 'eid'),
  femaleTag('Female Tag', 'female_tag'),
  maleTag('Male Tag', 'male_tag'),
  matingTag('Mating Tag', 'mating_tag'),
  plugDate('Plug Date', 'plug_date'),
  currentEday('Current E-Day', 'current_eday'),
  targetEday('Target E-Day', 'target_eday'),
  expectedDeliveryStart('Expected Delivery Start', 'expected_delivery_start'),
  expectedDeliveryEnd('Expected Delivery End', 'expected_delivery_end'),
  outcome('Outcome', 'outcome'),
  owner('Owner', 'owner'),
  created('Created Date', 'created_date');

  const PlugEventListColumn(this.label, this.field);
  @override
  final String label;
  @override
  final String field;
  @override
  String get enumName => name;

  static DataGridRow getDataGridRow(PlugEventDto p) {
    final String femaleTag = (p.female?.physicalTag ?? '').toString();
    final String maleTag = (p.male?.physicalTag ?? '').toString();
    final String matingTag = (p.mating?.matingTag ?? '').toString();
    final String plugDate = DateTimeHelper.parseIsoToDate(p.plugDate);
    final String currentEday =
        p.currentEday != null ? p.currentEday!.toStringAsFixed(1) : '';
    final String targetEday =
        p.targetEday != null ? p.targetEday!.toStringAsFixed(1) : '';
    final String expectedDeliveryStart =
        DateTimeHelper.parseIsoToDate(p.expectedDeliveryStart);
    final String expectedDeliveryEnd =
        DateTimeHelper.parseIsoToDate(p.expectedDeliveryEnd);
    final String outcome = _formatOutcome(p.outcome);
    final String owner = AccountHelper.getOwnerName(p.owner);
    final String created = DateTimeHelper.parseIsoToDateTime(p.createdDate);

    return DataGridRow(
      cells: [
        DataGridCell<String>(
          columnName: PlugEventListColumn.edit.name,
          value: p.plugEventUuid,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.eid.name,
          value: p.eid?.toString() ?? '',
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.femaleTag.name,
          value: femaleTag,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.maleTag.name,
          value: maleTag,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.matingTag.name,
          value: matingTag,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.plugDate.name,
          value: plugDate,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.currentEday.name,
          value: currentEday,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.targetEday.name,
          value: targetEday,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.expectedDeliveryStart.name,
          value: expectedDeliveryStart,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.expectedDeliveryEnd.name,
          value: expectedDeliveryEnd,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.outcome.name,
          value: outcome,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.owner.name,
          value: owner,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.created.name,
          value: created,
        ),
      ],
    );
  }

  static String _formatOutcome(String? outcome) {
    if (outcome == null || outcome.isEmpty) return 'Active';
    return outcome
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
