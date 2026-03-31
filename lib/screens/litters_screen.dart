import 'package:flutter/material.dart';
import 'package:moustra/services/clients/event_api.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/constants/list_constants/litter_filter_config.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/clients/litter_api.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/constants/list_constants/common.dart' hide SortOrder;
import 'package:moustra/constants/list_constants/litter_list_constants.dart';
import 'package:moustra/stores/table_setting_store.dart';
import 'package:moustra/widgets/column_settings_sheet.dart';
import 'package:moustra/widgets/filter_panel.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra_api/moustra_api.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/models/cell_edit_state.dart';
import 'package:moustra/widgets/cell_edit_modal.dart';
import 'package:moustra/widgets/entity_picker_sheet.dart';
import 'package:moustra/services/dtos/put_litter_dto.dart';
import 'package:moustra/stores/strain_store.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';

class LittersScreen extends StatefulWidget {
  const LittersScreen({super.key});

  @override
  State<LittersScreen> createState() => _LittersScreenState();
}

class _LittersScreenState extends State<LittersScreen> {
  final PaginatedGridController _controller = PaginatedGridController();
  final MovableFabMenuController _fabController = MovableFabMenuController();
  final Set<String> _selected = <String>{};
  bool _isEndingMode = false;
  bool _isEndingLitters = false;

  List<LitterDto> _currentRows = [];

  static final Map<String, EditFieldConfig> _editConfigs = {
    'strain': const EditFieldConfig(
      field: 'strain',
      type: EditFieldType.autocomplete,
    ),
    'date_of_birth': const EditFieldConfig(
      field: 'date_of_birth',
      type: EditFieldType.date,
    ),
    'wean_date': const EditFieldConfig(
      field: 'wean_date',
      type: EditFieldType.date,
    ),
  };

  // Filter & Sort state
  List<FilterParam> _activeFilters = [];
  SortParam? _activeSort = LitterFilterConfig.defaultSort;

  // Table settings
  TableSettingSLR? _tableSetting;

  @override
  void initState() {
    super.initState();
    eventApi.trackEvent('view_litters');
    _loadTableSetting();
  }

  Future<void> _loadTableSetting() async {
    final setting = await getTableSetting('LitterList');
    if (mounted && setting != null) {
      setState(() => _tableSetting = setting);
    }
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
      _activeFilters = [];
      _activeSort = LitterFilterConfig.defaultSort;
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
        field: 'litter_tag',
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

  List<GridColumn> get _litterColumns => buildColumnsFromSettings(
    _tableSetting?.tableSettingFields.toList(),
    activeSortField: _activeSort?.field,
    activeSortAscending: _activeSort?.order == SortOrder.asc,
    controlCols: _isEndingMode ? [
      GridColumn(
        columnName: 'select',
        width: 42,
        label: const Center(child: Text('')),
        allowSorting: false,
      ),
    ] : null,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Panel
        FilterPanel(
          filterFields: LitterFilterConfig.filterFields,
          sortFields: LitterFilterConfig.sortFields,
          initialFilters: _activeFilters,
          initialSort: _activeSort,
          onApply: _onFiltersApplied,
          onClear: _onFiltersClear,
          onColumnSettingsTap: _tableSetting != null
              ? () => showColumnSettingsSheet(
                    context: context,
                    baseName: 'LitterList',
                    tableSetting: _tableSetting!,
                    onSettingsChanged: () {
                      final updated = tableSettingStore.value['LitterList'];
                      if (updated != null && mounted) {
                        setState(() => _tableSetting = updated);
                      }
                    },
                  )
              : null,
          searchPlaceholder: 'Try "Search litter LTR-001"',
          onSearchSubmitted: (term) => _controller.search(term),
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              PaginatedDataGrid<LitterDto>(
                onRowTap: _isEndingMode ? null : (litter) {
                  context.go('/litter/${litter.litterUuid}');
                },
                controller: _controller,
                activeSortColumn: _activeSort?.field,
                activeSortAscending: _activeSort?.order == SortOrder.asc,
                onSortChanged: (columnName, ascending) {
                  setState(() {
                    _activeSort = SortParam(
                      field: columnName,
                      order: ascending ? SortOrder.asc : SortOrder.desc,
                    );
                  });
                  _controller.reload();
                },
                onSortCleared: () {
                  setState(() { _activeSort = null; });
                  _controller.reload();
                },
                columns: _litterColumns,
                editFieldConfigs: _isEndingMode ? null : _editConfigs,
                getRowId: (l) => l.litterUuid,
                primaryColumn: 'litter_tag',
                onCellEditTap: _isEndingMode ? null : _onCellEditTap,
                onCellEditCommit: _isEndingMode ? null : _onCellEditCommit,
                sourceBuilder: (rows) {
                  _currentRows = rows;
                  return _LitterGridSource(
                    records: rows,
                    context: context,
                    selected: _selected,
                    onToggle: _onToggleSelected,
                    isEndingMode: _isEndingMode,
                    columns: _litterColumns,
                  );
                },
                fetchPage: (page, pageSize) async {
                  final params = _buildQueryParams(
                    page: page,
                    pageSize: pageSize,
                  );
                  final pageData = await litterService.getLittersPageWithParams(
                    params: params,
                  );
                  return PaginatedResult<LitterDto>(
                    count: pageData.count,
                    results: pageData.results.cast<LitterDto>(),
                  );
                },
                onFilterChanged:
                    (page, pageSize, searchTerm, {useAiSearch}) async {
                  final params = _buildQueryParams(
                    page: page,
                    pageSize: pageSize,
                    searchTerm: searchTerm,
                  );
                  final pageData = await litterService.getLittersPageWithParams(
                    params: params,
                  );
                  return PaginatedResult<LitterDto>(
                    count: pageData.count,
                    results: pageData.results,
                  );
                },
              ),
              Positioned.fill(
                child: MovableFabMenu(
                  controller: _fabController,
                  heroTag: 'litters-fab-menu',
                  margin: const EdgeInsets.only(right: 24, bottom: 50),
                  actions: [
                    if (_isEndingMode)
                      FabMenuAction(
                        label: _isEndingLitters
                            ? 'Ending...'
                            : 'End Selected Litters',
                        icon: _isEndingLitters
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Icon(Icons.stop_circle_outlined),
                        onPressed: _selected.isNotEmpty && !_isEndingLitters
                            ? _showEndDatePicker
                            : null,
                        enabled: _selected.isNotEmpty && !_isEndingLitters,
                        closeOnTap: false,
                      )
                    else
                      FabMenuAction(
                        label: 'Create Litter',
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          context.go('/litter/new');
                        },
                      ),
                    FabMenuAction(
                      label: _isEndingMode ? 'Cancel End Mode' : 'End Litters',
                      icon: Icon(
                        _isEndingMode
                            ? Icons.close
                            : Icons.stop_circle_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isEndingMode = !_isEndingMode;
                          if (!_isEndingMode) {
                            _selected.clear();
                          }
                        });
                      },
                      closeOnTap: false,
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

  void _onCellEditTap(LitterDto litter, String columnName) async {
    if (_isEndingMode) return;

    final config = _editConfigs[columnName];
    if (config == null) return;

    if (columnName == 'strain') {
      final strains = strainStore.value ?? [];
      if (!mounted) return;

      final selected = await showEntityPickerSheet<StrainStoreDto>(
        context: context,
        options: strains,
        getLabel: (s) => s.strainName,
        getKey: (s) => s.strainUuid,
        title: 'Select Strain',
        searchHint: 'Search strains...',
      );

      if (selected != null) {
        _onCellEditCommit(litter.litterUuid, 'strain', selected);
      }
      return;
    }

    // Date fields use cell edit modal
    if (!mounted) return;

    dynamic currentValue;
    String fieldLabel = columnName;

    switch (columnName) {
      case 'date_of_birth':
        currentValue = litter.dateOfBirth;
        fieldLabel = 'Date of Birth';
        break;
      case 'wean_date':
        currentValue = litter.weanDate;
        fieldLabel = 'Wean Date';
        break;
    }

    final result = await showCellEditModal(
      context: context,
      fieldLabel: fieldLabel,
      config: config,
      currentValue: currentValue,
    );

    if (result != null) {
      _onCellEditCommit(litter.litterUuid, columnName, result);
    }
  }

  Future<bool> _onCellEditCommit(
    String rowId, String field, dynamic newValue,
  ) async {
    final litter = _currentRows.firstWhere(
      (l) => l.litterUuid == rowId,
      orElse: () => throw StateError('Row not found: $rowId'),
    );

    try {
      StrainStoreDto? strain;
      if (litter.strain != null) {
        strain = await getStrainHook(litter.strain!.strainUuid);
      }
      DateTime? dateOfBirth = litter.dateOfBirth;
      DateTime? weanDate = litter.weanDate;

      switch (field) {
        case 'strain':
          strain = newValue as StrainStoreDto;
          break;
        case 'date_of_birth':
          if (newValue is DateTime) {
            dateOfBirth = newValue;
          }
          break;
        case 'wean_date':
          if (newValue is DateTime) {
            weanDate = newValue;
          }
          break;
      }

      await litterService.putLitter(
        litter.litterUuid,
        PutLitterDto(
          litterTag: litter.litterTag,
          strain: strain,
          dateOfBirth: dateOfBirth,
          weanDate: weanDate,
          owner: litter.owner?.toAccountStoreDto(),
          comment: litter.comment,
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

  void _onToggleSelected(String uuid, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(uuid);
      } else {
        _selected.remove(uuid);
      }
    });
  }

  Future<void> _showEndDatePicker() async {
    DateTime selectedDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
      helpText: 'Select End Date',
    );

    if (picked != null) {
      await _endSelectedLitters(picked);
    }
  }

  Future<void> _endSelectedLitters(DateTime endDate) async {
    if (_selected.isEmpty) {
      return;
    }
    try {
      setState(() {
        _isEndingLitters = true;
      });
      eventApi.trackEvent('end_litter');
      await litterService.endLitters(_selected.toList(), endDate);
      if (!mounted) {
        return;
      }
      setState(() {
        _controller.reload();
        _selected.clear();
        _isEndingMode = false;
        _isEndingLitters = false;
      });
      _fabController.close();
      showAppSnackBar(context, 'Litters ended successfully!', isSuccess: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isEndingLitters = false;
      });
      showAppSnackBar(context, 'Failed to end litters. Please try again.', isError: true);
    }
  }
}

class _LitterGridSource extends DataGridSource {
  final List<LitterDto> records;
  final BuildContext context;
  final Set<String> selected;
  final void Function(String uuid, bool selected) onToggle;
  final bool isEndingMode;
  final List<GridColumn> columns;

  _LitterGridSource({
    required this.records,
    required this.context,
    required this.selected,
    required this.onToggle,
    required this.isEndingMode,
    required this.columns,
  }) {
    _rows = records.map(LitterListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final Map<String, Object?> values = {
      for (final cell in row.getCells()) cell.columnName: cell.value,
    };
    final String? uuid = values[LitterListColumn.select.name] as String?;
    final bool isChecked = uuid != null && selected.contains(uuid);
    final String litterTag = values[LitterListColumn.litterTag.name] as String? ?? '';

    Widget buildCell(String columnName) {
      switch (columnName) {
        case 'select':
          return Center(
            child: Checkbox(
              value: isChecked,
              onChanged: uuid == null
                  ? null
                  : (v) {
                      onToggle(uuid, v ?? false);
                    },
            ),
          );
        case 'litter_tag':
          return GestureDetector(
            onTap: uuid == null ? null : () => context.go('/litter/$uuid'),
            child: cellText(litterTag),
          );
        default:
          // Use enum name to look up value
          final col = LitterListColumn.values.cast<LitterListColumn?>().firstWhere(
            (c) => c!.field == columnName,
            orElse: () => null,
          );
          if (col != null) {
            return cellText('${values[col.name] ?? ''}');
          }
          return cellText(values[columnName]?.toString());
      }
    }

    return DataGridRowAdapter(
      cells: columns.map((col) => buildCell(col.columnName)).toList(),
    );
  }
}
