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
/// Pass [activeSortField] and [activeSortAscending] to show sort direction icons.
List<GridColumn> buildColumnsFromSettings(
  List<TableSettingFieldSLR>? settingFields, {
  List<GridColumn>? controlCols,
  String? activeSortField,
  bool activeSortAscending = true,
}) {
  if (settingFields == null || settingFields.isEmpty) return [];

  final sorted = settingFields.toList()
    ..sort((a, b) => a.fieldOrder.compareTo(b.fieldOrder));

  final columns = sorted.map((sf) {
    final isSortable = sf.fieldSortable == 'true';
    final isActiveSort = isSortable && activeSortField == sf.fieldName;

    final Widget labelContent = isSortable
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(sf.fieldLabel, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 2),
              Icon(
                isActiveSort
                    ? (activeSortAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward)
                    : Icons.unfold_more,
                size: 14,
                color: isActiveSort ? null : Colors.grey.shade400,
              ),
            ],
          )
        : Text(sf.fieldLabel, overflow: TextOverflow.ellipsis);

    return GridColumn(
      columnName: sf.fieldName,
      width: double.tryParse(sf.fieldWidth) ?? 150,
      label: Center(child: labelContent),
      visible: sf.fieldVisible,
      allowSorting: isSortable,
    );
  }).toList();

  if (controlCols != null && controlCols.isNotEmpty) {
    return [...controlCols, ...columns];
  }

  return columns;
}
