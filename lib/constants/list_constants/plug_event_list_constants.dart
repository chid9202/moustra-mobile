import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum PlugEventListColumn implements ListColumn<PlugEventDto> {
  edit('Edit', 'edit'),
  femaleTag('Female Tag', 'female_tag'),
  currentEday('E-Day', 'current_eday'),
  targetEday('Target E-Day', 'target_eday'),
  expectedDelivery('Expected Delivery', 'expected_delivery'),
  outcome('Outcome', 'outcome'),
  plugDate('Plug Date', 'plug_date'),
  owner('Owner', 'owner'),
  created('Created Date', 'created_date');

  const PlugEventListColumn(this.label, this.field);
  @override
  final String label;
  @override
  final String field;
  @override
  String get enumName => name;

  static List<GridColumn> getColumns() {
    return [
      GridColumn(
        columnName: PlugEventListColumn.edit.field,
        width: editColumnWidth,
        label: Center(child: Text(PlugEventListColumn.edit.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: PlugEventListColumn.femaleTag.field,
        width: 140,
        label: Center(child: Text(PlugEventListColumn.femaleTag.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: PlugEventListColumn.currentEday.field,
        width: 100,
        label: Center(child: Text(PlugEventListColumn.currentEday.label)),
        allowSorting: true,
      ),
      GridColumn(
        columnName: PlugEventListColumn.targetEday.field,
        width: 120,
        label: Center(child: Text(PlugEventListColumn.targetEday.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: PlugEventListColumn.expectedDelivery.field,
        width: 180,
        label: Center(child: Text(PlugEventListColumn.expectedDelivery.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: PlugEventListColumn.outcome.field,
        width: 140,
        label: Center(child: Text(PlugEventListColumn.outcome.label)),
        allowSorting: false,
      ),
      GridColumn(
        columnName: PlugEventListColumn.plugDate.field,
        width: 140,
        label: Center(child: Text(PlugEventListColumn.plugDate.label)),
        allowSorting: true,
      ),
      GridColumn(
        columnName: PlugEventListColumn.owner.field,
        width: ownerColumnWidth,
        label: Center(child: Text(PlugEventListColumn.owner.label)),
        allowSorting: true,
      ),
      GridColumn(
        columnName: PlugEventListColumn.created.field,
        width: 180,
        label: Center(child: Text(PlugEventListColumn.created.label)),
        allowSorting: true,
      ),
    ];
  }

  static DataGridRow getDataGridRow(PlugEventDto p) {
    final String femaleTag = (p.female?.physicalTag ?? '').toString();
    final String currentEday =
        p.currentEday != null ? p.currentEday!.toStringAsFixed(1) : '';
    final String targetEday =
        p.targetEday != null ? p.targetEday!.toStringAsFixed(1) : '';
    final String expectedDelivery = _formatDeliveryRange(
      p.expectedDeliveryStart,
      p.expectedDeliveryEnd,
    );
    final String outcome = _formatOutcome(p.outcome);
    final String plugDate = DateTimeHelper.parseIsoToDate(p.plugDate);
    final String owner = AccountHelper.getOwnerName(p.owner);
    final String created = DateTimeHelper.parseIsoToDateTime(p.createdDate);

    return DataGridRow(
      cells: [
        DataGridCell<String>(
          columnName: PlugEventListColumn.edit.name,
          value: p.plugEventUuid,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.femaleTag.name,
          value: femaleTag,
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
          columnName: PlugEventListColumn.expectedDelivery.name,
          value: expectedDelivery,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.outcome.name,
          value: outcome,
        ),
        DataGridCell<String>(
          columnName: PlugEventListColumn.plugDate.name,
          value: plugDate,
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

  static String _formatDeliveryRange(String? start, String? end) {
    if (start == null && end == null) return '';
    final s = DateTimeHelper.parseIsoToDate(start);
    final e = DateTimeHelper.parseIsoToDate(end);
    return '${s.isNotEmpty ? s : '?'} - ${e.isNotEmpty ? e : '?'}';
  }

  static String _formatOutcome(String? outcome) {
    if (outcome == null || outcome.isEmpty) return 'Active';
    return outcome
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
