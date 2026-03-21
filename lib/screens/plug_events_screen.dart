import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/constants/list_constants/plug_event_filter_config.dart';
import 'package:moustra/constants/list_constants/plug_event_list_constants.dart';
import 'package:moustra/services/clients/plug_api.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/stores/table_setting_store.dart';
import 'package:moustra/widgets/column_settings_sheet.dart';
import 'package:moustra/widgets/filter_panel.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra_api/moustra_api.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum _PreparedTab { active, completed, all }

class PlugEventsScreen extends StatefulWidget {
  const PlugEventsScreen({super.key});

  @override
  State<PlugEventsScreen> createState() => _PlugEventsScreenState();
}

class _PlugEventsScreenState extends State<PlugEventsScreen> {
  final PaginatedGridController _controller = PaginatedGridController();
  final MovableFabMenuController _fabController = MovableFabMenuController();

  _PreparedTab _selectedTab = _PreparedTab.active;
  List<FilterParam> _activeFilters = [];
  String? _activeName;
  SortParam? _activeSort = const SortParam(
    field: 'plug_date',
    order: SortOrder.desc,
  );

  // Table settings
  TableSettingSLR? _tableSetting;

  @override
  void initState() {
    super.initState();
    _applyTabFilters(_selectedTab);
    _loadTableSetting();
  }

  Future<void> _loadTableSetting() async {
    final setting = await getTableSetting('PlugEventList');
    if (mounted && setting != null) {
      setState(() => _tableSetting = setting);
    }
  }

  void _applyTabFilters(_PreparedTab tab) {
    switch (tab) {
      case _PreparedTab.active:
        _activeName = 'active';
        _activeFilters = [
          FilterParam(
            field: 'outcome',
            operator: FilterOperators.isEmpty,
            value: '',
          ),
        ];
        _activeSort = const SortParam(
          field: 'plug_date',
          order: SortOrder.desc,
        );
        break;
      case _PreparedTab.completed:
        _activeName = 'completed';
        _activeFilters = [
          FilterParam(
            field: 'outcome',
            operator: FilterOperators.isNotEmpty,
            value: '',
          ),
        ];
        _activeSort = const SortParam(
          field: 'plug_date',
          order: SortOrder.desc,
        );
        break;
      case _PreparedTab.all:
        _activeName = 'all';
        _activeFilters = [];
        _activeSort = PlugEventFilterConfig.defaultSort;
        break;
    }
  }

  void _onTabChanged(_PreparedTab tab) {
    setState(() {
      _selectedTab = tab;
      _applyTabFilters(tab);
    });
    _controller.reload();
  }

  void _onFiltersApplied(List<FilterParam> filters, SortParam? sort) {
    setState(() {
      _activeFilters = filters;
      _activeSort = sort;
    });
    _controller.reload();
  }

  void _onFiltersClear() {
    setState(() {
      _applyTabFilters(_selectedTab);
    });
    _controller.reload();
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
      name: _activeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Prepared filter tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Active'),
                selected: _selectedTab == _PreparedTab.active,
                onSelected: (_) => _onTabChanged(_PreparedTab.active),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Completed'),
                selected: _selectedTab == _PreparedTab.completed,
                onSelected: (_) => _onTabChanged(_PreparedTab.completed),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('All'),
                selected: _selectedTab == _PreparedTab.all,
                onSelected: (_) => _onTabChanged(_PreparedTab.all),
              ),
            ],
          ),
        ),
        FilterPanel(
          filterFields: PlugEventFilterConfig.filterFields,
          sortFields: PlugEventFilterConfig.sortFields,
          initialFilters: _activeFilters,
          initialSort: _activeSort,
          onApply: _onFiltersApplied,
          onClear: _onFiltersClear,
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
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              Builder(builder: (context) {
                final plugColumns = PlugEventListColumn.getColumns(
                  settingFields: _tableSetting?.tableSettingFields.toList(),
                );
                return PaginatedDataGrid<PlugEventDto>(
                controller: _controller,
                searchPlaceholder: 'Search by female tag...',
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
                sourceBuilder: (rows) =>
                    _PlugEventGridSource(records: rows, context: context, columns: plugColumns),
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
    final String uuid = (values[PlugEventListColumn.edit.name] as String?) ?? '';
    final String currentEday = (values[PlugEventListColumn.currentEday.name] as String?) ?? '';
    final String targetEday = (values[PlugEventListColumn.targetEday.name] as String?) ?? '';

    Widget buildCell(String columnName) {
      switch (columnName) {
        case 'edit':
          return Center(
            child: Semantics(
              label: 'View Plug Event',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.visibility),
                tooltip: 'View',
                onPressed: () {
                  context.go('/plug-event/$uuid');
                },
              ),
            ),
          );
        case 'current_eday':
          return _edayCellText(currentEday, targetEday);
        default:
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
