import 'package:flutter/material.dart';
import 'package:moustra_api/moustra_api.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum SortOrder { asc, desc }

enum SortQueryParamKey { sort, order }

enum SearchQueryParamKey { filter, op, value }

abstract class ListColumn<T> {
  String get label;
  String get field;
  String get enumName; // expose enum name
}

const double selectColumnWidth = 42;
const double editColumnWidth = 42;
const double eidColumnWidth = 64;
const double ownerColumnWidth = 160;

/// Columns that are controlled by the screen, not by table settings.
const Set<String> controlColumns = {'select', 'edit'};

/// Build GridColumns directly from table setting fields.
/// Columns are ordered by fieldOrder and visibility is applied.
/// Optional [controlCols] are prepended (e.g., select checkbox).
List<GridColumn> buildColumnsFromSettings(
  List<TableSettingFieldSLR>? settingFields, {
  List<GridColumn>? controlCols,
}) {
  if (settingFields == null || settingFields.isEmpty) return [];

  final sorted = settingFields.toList()
    ..sort((a, b) => a.fieldOrder.compareTo(b.fieldOrder));

  final columns = sorted.map((sf) {
    return GridColumn(
      columnName: sf.fieldName,
      width: double.tryParse(sf.fieldWidth) ?? 150,
      label: Center(child: Text(sf.fieldLabel)),
      visible: sf.fieldVisible,
      allowSorting: sf.fieldSortable == 'true',
    );
  }).toList();

  if (controlCols != null && controlCols.isNotEmpty) {
    return [...controlCols, ...columns];
  }

  return columns;
}
