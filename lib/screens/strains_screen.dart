import 'package:flutter/material.dart';
import 'package:moustra/services/clients/event_api.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/constants/list_constants/strain_filter_config.dart';
import 'package:moustra/constants/list_constants/common.dart' hide SortOrder;
import 'package:moustra/constants/list_constants/strain_list_constants.dart';
import 'package:moustra/models/cell_edit_state.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/services/clients/strain_api.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/widgets/color_picker.dart';
import 'package:moustra/widgets/cell_edit_modal.dart';
import 'package:moustra/widgets/entity_picker_sheet.dart';
import 'package:moustra/stores/table_setting_store.dart';
import 'package:moustra/widgets/column_settings_sheet.dart';
import 'package:moustra/widgets/filter_panel.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra_api/moustra_api.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/stores/account_store.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';

class StrainsScreen extends StatefulWidget {
  const StrainsScreen({super.key});

  @override
  State<StrainsScreen> createState() => _StrainsScreenState();
}

class _StrainsScreenState extends State<StrainsScreen> {
  final PaginatedGridController _controller = PaginatedGridController();
  final Set<String> _selected = <String>{};
  final MovableFabMenuController _fabController = MovableFabMenuController();

  // Filter & Sort state
  List<FilterParam> _activeFilters = [];
  SortParam? _activeSort = StrainFilterConfig.defaultSort;
  int _selectedPresetIndex = -1;

  // Table settings
  TableSettingSLR? _tableSetting;

  // Edit field configurations for inline editing
  static final Map<String, EditFieldConfig> _editConfigs = {
    'name': const EditFieldConfig(
      field: 'name',
      type: EditFieldType.text,
      validate: _validateStrainName,
    ),
    'owner': const EditFieldConfig(
      field: 'owner',
      type: EditFieldType.autocomplete,
    ),
    'active': const EditFieldConfig(
      field: 'active',
      type: EditFieldType.boolean,
    ),
  };

  static String? _validateStrainName(dynamic value) {
    final name = value?.toString() ?? '';
    if (name.trim().isEmpty) return 'Strain name is required';
    if (name.length > 100) return 'Strain name must be 100 characters or less';
    return null;
  }

  // Cached rows for edit lookups
  List<StrainDto> _currentRows = [];

  @override
  void initState() {
    super.initState();
    eventApi.trackEvent('view_strains');
    _loadTableSetting();
  }

  Future<void> _loadTableSetting() async {
    final setting = await getTableSetting('StrainList');
    if (mounted && setting != null) {
      setState(() => _tableSetting = setting);
    }
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
    setState(() {
      _activeFilters = [];
      _activeSort = StrainFilterConfig.defaultSort;
      _selectedPresetIndex = -1;
    });
    _controller.reload();
  }

  void _onPresetSelected(int index) {
    final preset = StrainFilterConfig.preparedFilters[index];
    setState(() {
      _selectedPresetIndex = index;
      _activeFilters = List.from(preset.filters);
      _activeSort = preset.sort;
    });
    _controller.reload();
  }

  void _onCellEditTap(StrainDto strain, String columnName) async {
    final config = _editConfigs[columnName];
    if (config == null) return;

    if (config.type == EditFieldType.autocomplete && columnName == 'owner') {
      // Owner uses entity picker bottom sheet
      final accounts = accountStore.value ?? [];
      if (!mounted) return;

      final selected = await showEntityPickerSheet<AccountStoreDto>(
        context: context,
        options: accounts,
        getLabel: (a) {
          final name = '${a.user.firstName} ${a.user.lastName}'.trim();
          return name.isNotEmpty ? name : (a.user.email ?? '');
        },
        getKey: (a) => a.accountUuid,
        title: 'Select Owner',
        searchHint: 'Search users...',
      );

      if (selected != null) {
        _onCellEditCommit(strain.strainUuid, 'owner', selected);
      }
      return;
    }

    // Text, boolean, select, date — use cell edit modal
    if (!mounted) return;

    dynamic currentValue;
    String fieldLabel = columnName;

    switch (columnName) {
      case 'name':
        currentValue = strain.strainName;
        fieldLabel = 'Strain Name';
        break;
      case 'active':
        currentValue = strain.isActive;
        fieldLabel = 'Active';
        break;
    }

    final result = await showCellEditModal(
      context: context,
      fieldLabel: fieldLabel,
      config: config,
      currentValue: currentValue,
    );

    if (result != null) {
      _onCellEditCommit(strain.strainUuid, columnName, result);
    }
  }

  Future<bool> _onCellEditCommit(
    String rowId, String field, dynamic newValue,
  ) async {
    final strain = _currentRows.firstWhere(
      (s) => s.strainUuid == rowId,
      orElse: () => throw StateError('Row not found: $rowId'),
    );

    // Validate
    final config = _editConfigs[field];
    if (config?.validate != null) {
      final error = config!.validate!(newValue);
      if (error != null) {
        if (mounted) showAppSnackBar(context, error, isError: true);
        return false;
      }
    }

    try {
      // Build the updated DTO
      AccountStoreDto owner = await getAccountHook(strain.owner.accountUuid) ??
          (throw StateError('Owner account not found'));
      String strainName = strain.strainName;
      bool? isActive = strain.isActive;

      switch (field) {
        case 'name':
          strainName = newValue.toString();
          break;
        case 'owner':
          owner = newValue as AccountStoreDto;
          break;
        case 'active':
          isActive = newValue as bool;
          break;
      }

      await strainService.putStrain(
        strain.strainUuid,
        PutStrainDto(
          strainId: strain.strainId,
          strainUuid: strain.strainUuid,
          strainName: strainName,
          owner: owner,
          color: strain.color ?? '',
          comment: strain.comment,
          backgrounds: strain.backgrounds
              .map((b) => b.toBackgroundStoreDto())
              .toList(),
          isActive: isActive,
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

  ListQueryParams _buildQueryParams({
    required int page,
    required int pageSize,
    String? searchTerm,
  }) {
    List<FilterParam> filters = _activeFilters.map((f) {
      if (f.value == currentUserPlaceholder) {
        return f.copyWith(
          value: profileState.value?.accountUuid ?? '',
        );
      }
      return f;
    }).toList();

    if (searchTerm != null && searchTerm.isNotEmpty) {
      filters.add(FilterParam(
        field: 'strain_name',
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Panel (includes prepared filter presets)
        FilterPanel(
          filterFields: StrainFilterConfig.filterFields,
          sortFields: StrainFilterConfig.sortFields,
          initialFilters: _activeFilters,
          initialSort: _activeSort,
          onApply: _onFiltersApplied,
          onClear: _onFiltersClear,
          preparedFilters: StrainFilterConfig.preparedFilters,
          selectedPresetIndex: _selectedPresetIndex,
          onPresetSelected: _onPresetSelected,
          onColumnSettingsTap: _tableSetting != null
              ? () => showColumnSettingsSheet(
                    context: context,
                    baseName: 'StrainList',
                    tableSetting: _tableSetting!,
                    onSettingsChanged: () {
                      final updated = tableSettingStore.value['StrainList'];
                      if (updated != null && mounted) {
                        setState(() => _tableSetting = updated);
                      }
                    },
                  )
              : null,
          searchPlaceholder: 'Try "Search strain B6"',
          onSearchSubmitted: (term) => _controller.search(term),
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              Builder(builder: (context) {
                final strainColumns = buildColumnsFromSettings(
                  _tableSetting?.tableSettingFields.toList(),
                  activeSortField: _activeSort?.field,
                  activeSortAscending: _activeSort?.order == SortOrder.asc,
                );
                return PaginatedDataGrid<StrainDto>(
                onRowTap: (strain) {
                  context.go('/strain/${strain.strainUuid}');
                },
                controller: _controller,
                editFieldConfigs: _editConfigs,
                getRowId: (strain) => strain.strainUuid,
                primaryColumn: 'name',
                onCellEditTap: _onCellEditTap,
                onCellEditCommit: _onCellEditCommit,
                activeSortColumn: _activeSort?.field,
                activeSortAscending: _activeSort?.order == SortOrder.asc,
                onSortChanged: (columnName, ascending) {
                  setState(() {
                    _activeSort = SortParam(
                      field: columnName,
                      order: ascending ? SortOrder.asc : SortOrder.desc,
                    );
                    _selectedPresetIndex = -1;
                  });
                  _controller.reload();
                },
                onSortCleared: () {
                  setState(() { _activeSort = null; _selectedPresetIndex = -1; });
                  _controller.reload();
                },
                columns: strainColumns,
                sourceBuilder: (rows) {
                  _currentRows = rows;
                  return _StrainGridSource(
                    records: rows,
                    selected: _selected,
                    onToggle: _onToggleSelected,
                    context: context,
                    columns: strainColumns,
                  );
                },
                fetchPage: (page, pageSize) async {
                  final params = _buildQueryParams(
                    page: page,
                    pageSize: pageSize,
                  );
                  final pageData = await strainService.getStrainsPageWithParams(
                    params: params,
                  );
                  return PaginatedResult<StrainDto>(
                    count: pageData.count,
                    results: pageData.results,
                  );
                },
                onFilterChanged:
                    (page, pageSize, searchTerm, {useAiSearch}) async {
                  if (useAiSearch == true && searchTerm.isNotEmpty) {
                    final pageData = await strainService.searchStrainsWithAi(
                      prompt: searchTerm,
                    );
                    return PaginatedResult<StrainDto>(
                      count: pageData.count,
                      results: pageData.results,
                    );
                  }

                  final params = _buildQueryParams(
                    page: page,
                    pageSize: pageSize,
                    searchTerm: searchTerm,
                  );
                  final pageData = await strainService.getStrainsPageWithParams(
                    params: params,
                  );
                  return PaginatedResult<StrainDto>(
                    count: pageData.count,
                    results: pageData.results,
                  );
                },
              );
              }),
              Positioned.fill(
                child: MovableFabMenu(
                  controller: _fabController,
                  heroTag: 'strains-fab-menu',
                  margin: const EdgeInsets.only(right: 24, bottom: 50),
                  actions: [
                    FabMenuAction(
                      label: 'Create Strain',
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        eventApi.trackEvent('create_strain');
                        if (context.mounted) {
                          context.go('/strain/new');
                        }
                      },
                    ),
                    FabMenuAction(
                      label: 'Merge Strain',
                      icon: const Icon(Icons.merge_type),
                      onPressed: _selected.length >= 2 ? _mergeSelected : null,
                      enabled: _selected.length >= 2,
                      closeOnTap: true,
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

  void _onToggleSelected(String uuid, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(uuid);
      } else {
        _selected.remove(uuid);
      }
    });
  }

  Future<void> _mergeSelected() async {
    final strains = _selected.toList();
    try {
      await strainService.mergeStrains(strains);
      if (!mounted) return;
      showAppSnackBar(context, 'Merged ${strains.length} strains.', isSuccess: true);
      _selected.clear();
      _controller.reload();
      _fabController.close();
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Merge failed: $e', isError: true);
    }
  }
}

class _StrainGridSource extends DataGridSource {
  final List<StrainDto> records;
  final Set<String> selected;
  final void Function(String uuid, bool selected) onToggle;
  final BuildContext context;
  final List<GridColumn> columns;

  _StrainGridSource({
    required this.records,
    required this.selected,
    required this.onToggle,
    required this.context,
    required this.columns,
  }) {
    _dataGridRows = records.map(StrainListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _dataGridRows;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final Map<String, Object?> values = {
      for (final cell in row.getCells()) cell.columnName: cell.value,
    };
    final String uuid = (values[StrainListColumn.select.name] as String?) ?? '';
    final String strainName = (values[StrainListColumn.strainName.name] as String?) ?? '';
    final bool isChecked = selected.contains(uuid);

    Widget buildCell(String columnName) {
      switch (columnName) {
        case 'select':
          return Center(
            child: Checkbox(
              value: isChecked,
              onChanged: (v) {
                onToggle(uuid, v ?? false);
              },
            ),
          );
        case 'name':
          return cellText(strainName);
        case 'animals':
          return cellText('${values[StrainListColumn.animals.name] ?? ''}', textAlign: Alignment.center);
        case 'color':
          return Center(child: ColorPicker(hex: (values[StrainListColumn.color.name] as String?) ?? ''));
        case 'active':
          final bool isActive = (values[StrainListColumn.active.name] as bool?) ?? false;
          return Center(
            child: Icon(
              isActive ? Icons.check_circle : Icons.cancel,
              color: isActive ? Colors.green : Colors.red,
              size: 18,
            ),
          );
        default:
          final col = StrainListColumn.values.cast<StrainListColumn?>().firstWhere(
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
}
