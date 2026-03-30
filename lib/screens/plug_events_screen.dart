import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/constants/list_constants/plug_event_filter_config.dart';
import 'package:moustra/constants/list_constants/common.dart' hide SortOrder;
import 'package:moustra/constants/list_constants/plug_event_list_constants.dart';
import 'package:moustra/models/cell_edit_state.dart';
import 'package:moustra/services/clients/plug_api.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';
import 'package:moustra/services/dtos/put_plug_event_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/stores/table_setting_store.dart';
import 'package:moustra/widgets/cell_edit_modal.dart';
import 'package:moustra/widgets/column_settings_sheet.dart';
import 'package:moustra/widgets/filter_panel.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra_api/moustra_api.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/services/clients/event_api.dart';
import 'package:moustra/helpers/snackbar_helper.dart';

class PlugEventsScreen extends StatefulWidget {
  const PlugEventsScreen({super.key});

  @override
  State<PlugEventsScreen> createState() => _PlugEventsScreenState();
}

class _PlugEventsScreenState extends State<PlugEventsScreen> {
  final PaginatedGridController _controller = PaginatedGridController();
  final MovableFabMenuController _fabController = MovableFabMenuController();

  // Start with "Active" preset (index 0)
  int _selectedPresetIndex = 0;
  List<FilterParam> _activeFilters = PlugEventFilterConfig.preparedFilters[0].filters;
  SortParam? _activeSort = PlugEventFilterConfig.preparedFilters[0].sort;

  List<PlugEventDto> _currentRows = [];

  static final Map<String, EditFieldConfig> _editConfigs = {
    'plug_date': const EditFieldConfig(
      field: 'plug_date',
      type: EditFieldType.date,
    ),
    'target_eday': const EditFieldConfig(
      field: 'target_eday',
      type: EditFieldType.text,
    ),
  };

  // Table settings
  TableSettingSLR? _tableSetting;

  @override
  void initState() {
    super.initState();
    eventApi.trackEvent('view_plug_events');
    _loadTableSetting();
  }

  Future<void> _loadTableSetting() async {
    final setting = await getTableSetting('PlugEventList');
    if (mounted && setting != null) {
      setState(() => _tableSetting = setting);
    }
  }

  void _onPresetSelected(int index) {
    final preset = PlugEventFilterConfig.preparedFilters[index];
    setState(() {
      _selectedPresetIndex = index;
      _activeFilters = List.from(preset.filters);
      _activeSort = preset.sort;
    });
    _controller.reload();
  }

  void _onFiltersApplied(List<FilterParam> filters, SortParam? sort) {
    setState(() {
      _activeFilters = filters;
      _activeSort = sort;
      _selectedPresetIndex = -1;
    });
    _controller.reload();
  }

  void _onFiltersClear() {
    // Reset to "Active" preset
    _onPresetSelected(0);
  }

  ListQueryParams _buildQueryParams({
    required int page,
    required int pageSize,
    String? searchTerm,
  }) {
    List<FilterParam> filters = List.from(_activeFilters);

    if (searchTerm != null && searchTerm.isNotEmpty) {
      filters.add(FilterParam(
        field: 'female_tag',
        operator: FilterOperators.contains,
        value: searchTerm,
      ));
    }

    List<SortParam> sorts = [];
    if (_activeSort != null) {
      sorts.add(_activeSort!);
    }

    return ListQueryParams(
      page: page,
      pageSize: pageSize,
      filters: filters,
      sorts: sorts,
    );
  }

  void _onCellEditTap(PlugEventDto plugEvent, String columnName) async {
    final config = _editConfigs[columnName];
    if (config == null) return;

    if (!mounted) return;

    dynamic currentValue;
    String fieldLabel = columnName;

    switch (columnName) {
      case 'plug_date':
        currentValue = plugEvent.plugDate;
        fieldLabel = 'Plug Date';
        break;
      case 'target_eday':
        currentValue = plugEvent.targetEday?.toString();
        fieldLabel = 'Target E-Day';
        break;
    }

    final result = await showCellEditModal(
      context: context,
      fieldLabel: fieldLabel,
      config: config,
      currentValue: currentValue,
    );

    if (result != null) {
      _onCellEditCommit(plugEvent.plugEventUuid, columnName, result);
    }
  }

  Future<bool> _onCellEditCommit(
    String rowId, String field, dynamic newValue,
  ) async {
    final plugEvent = _currentRows.firstWhere(
      (p) => p.plugEventUuid == rowId,
      orElse: () => throw StateError('Row not found: $rowId'),
    );

    try {
      String? comment = plugEvent.comment;
      String? plugDate = plugEvent.plugDate;
      int? targetEday = plugEvent.targetEday?.toInt();
      String? male = plugEvent.male?.animalUuid;

      switch (field) {
        case 'plug_date':
          // Date comes as DateTime from date picker
          if (newValue is DateTime) {
            plugDate = '${newValue.year}-${newValue.month.toString().padLeft(2, '0')}-${newValue.day.toString().padLeft(2, '0')}';
          } else {
            plugDate = newValue?.toString();
          }
          break;
        case 'target_eday':
          targetEday = int.tryParse(newValue.toString());
          break;
      }

      await plugService.updatePlugEvent(
        plugEvent.plugEventUuid,
        PutPlugEventDto(
          comment: comment,
          plugDate: plugDate,
          targetEday: targetEday,
          male: male,
        ),
      );

      if (mounted) {
        showAppSnackBar(context, 'Updated successfully', isSuccess: true);
      }
      _controller.reload();
      return true;
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Update failed: $e', isError: true);
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilterPanel(
          filterFields: PlugEventFilterConfig.filterFields,
          sortFields: PlugEventFilterConfig.sortFields,
          initialFilters: _activeFilters,
          initialSort: _activeSort,
          onApply: _onFiltersApplied,
          onClear: _onFiltersClear,
          preparedFilters: PlugEventFilterConfig.preparedFilters,
          selectedPresetIndex: _selectedPresetIndex,
          onPresetSelected: _onPresetSelected,
          onColumnSettingsTap: _tableSetting != null
              ? () => showColumnSettingsSheet(
                    context: context,
                    baseName: 'PlugEventList',
                    tableSetting: _tableSetting!,
                    onSettingsChanged: () {
                      final updated = tableSettingStore.value['PlugEventList'];
                      if (updated != null && mounted) {
                        setState(() => _tableSetting = updated);
                      }
                    },
                  )
              : null,
          searchPlaceholder: 'Search by female tag...',
          onSearchSubmitted: (term) => _controller.search(term),
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              Builder(builder: (context) {
                final plugColumns = buildColumnsFromSettings(
                  _tableSetting?.tableSettingFields.toList(),
                );
                return PaginatedDataGrid<PlugEventDto>(
                onRowTap: (plugEvent) {
                  context.go('/plug-event/${plugEvent.plugEventUuid}');
                },
                controller: _controller,
                onSortChanged: (columnName, ascending) {
                  setState(() {
                    _activeSort = SortParam(
                      field: columnName,
                      order: ascending ? SortOrder.asc : SortOrder.desc,
                    );
                  });
                  _controller.reload();
                },
                columns: plugColumns,
                editFieldConfigs: _editConfigs,
                getRowId: (p) => p.plugEventUuid,
                primaryColumn: 'eid',
                onCellEditTap: _onCellEditTap,
                onCellEditCommit: _onCellEditCommit,
                sourceBuilder: (rows) {
                  _currentRows = rows;
                  return _PlugEventGridSource(records: rows, context: context, columns: plugColumns);
                },
                fetchPage: (page, pageSize) async {
                  final params = _buildQueryParams(
                    page: page,
                    pageSize: pageSize,
                  );
                  final pageData = await plugService.getPlugEventsPage(
                    params: params,
                  );
                  return PaginatedResult<PlugEventDto>(
                    count: pageData.count,
                    results: pageData.results.cast<PlugEventDto>(),
                  );
                },
                onFilterChanged:
                    (page, pageSize, searchTerm, {useAiSearch}) async {
                  final params = _buildQueryParams(
                    page: page,
                    pageSize: pageSize,
                    searchTerm: searchTerm,
                  );
                  final pageData = await plugService.getPlugEventsPage(
                    params: params,
                  );
                  return PaginatedResult<PlugEventDto>(
                    count: pageData.count,
                    results: pageData.results,
                  );
                },
              );
              }),
              Positioned.fill(
                child: MovableFabMenu(
                  controller: _fabController,
                  heroTag: 'plug-events-fab-menu',
                  actions: [
                    FabMenuAction(
                      label: 'Record Plug Event',
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        context.go('/plug-event/new');
                      },
                    ),
                    FabMenuAction(
                      label: 'Record Plug Check',
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () {
                        context.go('/plug-check');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlugEventGridSource extends DataGridSource {
  final List<PlugEventDto> records;
  final BuildContext context;
  final List<GridColumn> columns;

  _PlugEventGridSource({required this.records, required this.context, required this.columns}) {
    _rows = records.map(PlugEventListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final Map<String, Object?> values = {
      for (final cell in row.getCells()) cell.columnName: cell.value,
    };
    final String currentEday = (values[PlugEventListColumn.currentEday.name] as String?) ?? '';
    final String targetEday = (values[PlugEventListColumn.targetEday.name] as String?) ?? '';

    Widget buildCell(String columnName) {
      switch (columnName) {
        case 'current_eday':
          return _edayCellText(currentEday, targetEday);
        default:
          // GridColumn uses .field (snake_case), DataGridCell uses .name (camelCase)
          final col = PlugEventListColumn.values.cast<PlugEventListColumn?>().firstWhere(
            (c) => c!.field == columnName,
            orElse: () => null,
          );
          if (col != null) {
            return cellText(values[col.name]?.toString());
          }
          return cellText(values[columnName]?.toString());
      }
    }

    return DataGridRowAdapter(
      cells: columns.map((col) => buildCell(col.columnName)).toList(),
    );
  }

  /// Color-coded E-Day cell: green < target, yellow near target, red > target
  Widget _edayCellText(String currentStr, String targetStr) {
    final current = double.tryParse(currentStr);
    final target = double.tryParse(targetStr);

    Color? textColor;
    if (current != null && target != null) {
      if (current > target) {
        textColor = Colors.red;
      } else if (current >= target - 1) {
        textColor = Colors.orange;
      } else {
        textColor = Colors.green;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          currentStr,
          style: textColor != null
              ? TextStyle(color: textColor, fontWeight: FontWeight.bold)
              : null,
        ),
      ),
    );
  }
}
