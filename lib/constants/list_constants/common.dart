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

/// Apply table setting fields to a list of GridColumns.
/// Filters by visibility and reorders by fieldOrder.
/// Control columns (select, edit, edit_stripe) are always kept as-is.
List<GridColumn> applyTableSettings(
  List<GridColumn> columns,
  List<TableSettingFieldSLR>? settingFields,
) {
  if (settingFields == null || settingFields.isEmpty) return columns;

  // Separate control columns and data columns
  final controlCols = <GridColumn>[];
  final dataCols = <GridColumn>[];
  for (final col in columns) {
    if (controlColumns.contains(col.columnName)) {
      controlCols.add(col);
    } else {
      dataCols.add(col);
    }
  }

  // Build a map of field_name -> setting
  final settingsMap = <String, TableSettingFieldSLR>{};
  for (final sf in settingFields) {
    settingsMap[sf.fieldName] = sf;
  }

  // Apply visibility (via GridColumn.visible) and collect with order.
  // We keep ALL columns so that buildRow cell count matches column count.
  final ordered = <(int, GridColumn)>[];
  for (final col in dataCols) {
    final sf = settingsMap[col.columnName];
    if (sf != null) {
      // Rebuild column with visibility from settings
      final rebuilt = GridColumn(
        columnName: col.columnName,
        label: col.label,
        visible: sf.fieldVisible,
        width: col.width,
        minimumWidth: col.minimumWidth,
        maximumWidth: col.maximumWidth,
        allowSorting: col.allowSorting,
        allowFiltering: col.allowFiltering,
        allowEditing: col.allowEditing,
        autoFitPadding: col.autoFitPadding,
        columnWidthMode: col.columnWidthMode,
        filterPopupMenuOptions: col.filterPopupMenuOptions,
        sortIconPosition: col.sortIconPosition,
        filterIconPosition: col.filterIconPosition,
        filterIconPadding: col.filterIconPadding,
      );
      ordered.add((sf.fieldOrder, rebuilt));
    } else {
      // Column not in settings — keep visible, put at end
      ordered.add((999, col));
    }
  }

  // Sort by fieldOrder
  ordered.sort((a, b) => a.$1.compareTo(b.$1));

  return [...controlCols, ...ordered.map((e) => e.$2)];
}
