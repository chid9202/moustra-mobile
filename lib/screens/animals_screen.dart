import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/animal_filter_config.dart';
import 'package:moustra/constants/list_constants/animal_list_constants.dart';
import 'package:moustra/constants/list_constants/common.dart' hide SortOrder;
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/constants/list_constants/cage_filter_config.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/end_animals_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/services/models/prepared_filter.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/stores/table_setting_store.dart';
import 'package:moustra/widgets/column_settings_sheet.dart';
import 'package:moustra/widgets/filter_panel.dart';
import 'package:moustra_api/moustra_api.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra/services/clients/event_api.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/models/cell_edit_state.dart';
import 'package:moustra/widgets/cell_edit_modal.dart';
import 'package:moustra/widgets/entity_picker_sheet.dart';
import 'package:moustra/stores/account_store.dart';
import 'package:moustra/stores/strain_store.dart';
import 'package:moustra/stores/animal_store.dart';
import 'package:moustra/stores/cage_store.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/constants/animal_constants.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  final PaginatedGridController _controller = PaginatedGridController();
  final Set<String> _selected = <String>{};
  final int _pageSize = 1000;
  bool _isEndingMode = false;
  bool _isEndingAnimals = false;
  final MovableFabMenuController _fabController = MovableFabMenuController();

  // Filter & Sort state
  List<FilterParam> _activeFilters = [];
  SortParam? _activeSort = AnimalFilterConfig.defaultSort;
  int _selectedPresetIndex = 0;
  late final ValueNotifier<SortParam?> _sortNotifier;

  // Table settings
  TableSettingSLR? _tableSetting;

  // Cached rows for edit lookups
  List<AnimalDto> _currentRows = [];

  static final Map<String, EditFieldConfig> _editConfigs = {
    'strain': const EditFieldConfig(
      field: 'strain',
      type: EditFieldType.autocomplete,
    ),
    'owner': const EditFieldConfig(
      field: 'owner',
      type: EditFieldType.autocomplete,
    ),
    'sire': const EditFieldConfig(
      field: 'sire',
      type: EditFieldType.autocomplete,
    ),
    'cage_tag': const EditFieldConfig(
      field: 'cage_tag',
      type: EditFieldType.autocomplete,
    ),
    'sex': EditFieldConfig(
      field: 'sex',
      type: EditFieldType.select,
      options: [
        const SelectOption(value: 'M', label: 'Male'),
        const SelectOption(value: 'F', label: 'Female'),
      ],
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

  @override
  void initState() {
    super.initState();
    _sortNotifier = ValueNotifier(AnimalFilterConfig.defaultSort);
    _applyPreset(0);
    _loadTableSetting();
  }

  Future<void> _loadTableSetting() async {
    final setting = await getTableSetting('AnimalList');
    if (mounted && setting != null) {
      setState(() => _tableSetting = setting);
    }
  }

  @override
  void dispose() {
    _sortNotifier.dispose();
    super.dispose();
  }

  void _applyPreset(int index) {
    final preset = AnimalFilterConfig.preparedFilters[index];
    _selectedPresetIndex = index;
    _activeFilters = List.from(preset.filters);
    _activeSort = preset.sort;
    _sortNotifier.value = preset.sort;
  }

  void _onPresetSelected(int index) {
    final preset = AnimalFilterConfig.preparedFilters[index];
    final name = preset.name.toLowerCase().replaceAll(' ', '_');
    eventApi.trackEvent('filter_animal_$name');
    setState(() {
      _applyPreset(index);
    });
    _controller.reload();
  }

  void _onFiltersApplied(List<FilterParam> filters, SortParam? sort) {
    setState(() {
      _activeFilters = filters;
      _activeSort = sort;
      _sortNotifier.value = sort;
      _selectedPresetIndex = PreparedFilter.findMatchingPreset(
        AnimalFilterConfig.preparedFilters,
        filters,
        sort,
      );
    });
    _controller.reload();
  }

  void _onFiltersClear() {
    setState(() {
      _activeFilters = [];
      _activeSort = AnimalFilterConfig.defaultSort;
      _sortNotifier.value = AnimalFilterConfig.defaultSort;
      _selectedPresetIndex = -1;
    });
    _controller.reload();
  }

  Future<void> _onCellEditTap(AnimalDto animal, String columnName) async {
    if (_isEndingMode) return;

    final config = _editConfigs[columnName];
    if (config == null) return;

    // Autocomplete fields — entity picker sheets
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
        _onCellEditCommit(animal.animalUuid, 'strain', selected);
      }
      return;
    }

    if (columnName == 'owner') {
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
        _onCellEditCommit(animal.animalUuid, 'owner', selected);
      }
      return;
    }

    if (columnName == 'sire') {
      final animals = (animalStore.value ?? [])
          .where((a) => a.sex == SexConstants.male)
          .toList();
      if (!mounted) return;
      final selected = await showEntityPickerSheet<AnimalStoreDto>(
        context: context,
        options: animals,
        getLabel: (a) => a.physicalTag ?? a.animalUuid,
        getKey: (a) => a.animalUuid,
        title: 'Select Sire',
        searchHint: 'Search males...',
      );
      if (selected != null) {
        _onCellEditCommit(animal.animalUuid, 'sire', selected);
      }
      return;
    }

    if (columnName == 'cage_tag') {
      final cages = cageStore.value ?? [];
      if (!mounted) return;
      final selected = await showEntityPickerSheet<CageStoreDto>(
        context: context,
        options: cages,
        getLabel: (c) => c.cageTag ?? '',
        getKey: (c) => c.cageUuid,
        title: 'Select Cage',
        searchHint: 'Search cages...',
      );
      if (selected != null) {
        _onCellEditCommit(animal.animalUuid, 'cage_tag', selected);
      }
      return;
    }

    // Select and date fields — cell edit modal
    if (!mounted) return;

    dynamic currentValue;
    String fieldLabel = columnName;

    switch (columnName) {
      case 'sex':
        currentValue = animal.sex;
        fieldLabel = 'Sex';
        break;
      case 'date_of_birth':
        currentValue = animal.dateOfBirth;
        fieldLabel = 'Date of Birth';
        break;
      case 'wean_date':
        currentValue = animal.weanDate;
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
      _onCellEditCommit(animal.animalUuid, columnName, result);
    }
  }

  Future<bool> _onCellEditCommit(
    String rowId, String field, dynamic newValue,
  ) async {
    final animal = _currentRows.firstWhere(
      (a) => a.animalUuid == rowId,
      orElse: () => throw StateError('Row not found: $rowId'),
    );

    try {
      // Start with current values
      StrainSummaryDto? strain = animal.strain;
      AccountDto? owner = animal.owner;
      AnimalSummaryDto? sire = animal.sire;
      CageSummaryDto? cage = animal.cage;
      String? sex = animal.sex;
      DateTime? dateOfBirth = animal.dateOfBirth;
      DateTime? weanDate = animal.weanDate;

      switch (field) {
        case 'strain':
          strain = (newValue as StrainStoreDto).toStrainSummaryDto();
          break;
        case 'owner':
          owner = (newValue as AccountStoreDto).toAccountDto();
          break;
        case 'sire':
          sire = (newValue as AnimalStoreDto).toAnimalSummaryDto();
          break;
        case 'cage_tag':
          cage = (newValue as CageStoreDto).toCageSummaryDto();
          break;
        case 'sex':
          sex = newValue?.toString();
          break;
        case 'date_of_birth':
          if (newValue is DateTime) dateOfBirth = newValue;
          break;
        case 'wean_date':
          if (newValue is DateTime) weanDate = newValue;
          break;
      }

      await animalService.putAnimal(
        animal.animalUuid,
        AnimalDto(
          eid: 0,
          animalId: 0,
          animalUuid: animal.animalUuid,
          physicalTag: animal.physicalTag,
          sex: sex,
          strain: strain,
          owner: owner,
          sire: sire,
          dam: animal.dam,
          cage: cage,
          dateOfBirth: dateOfBirth,
          weanDate: weanDate,
          genotypes: animal.genotypes,
          endDate: animal.endDate,
          endType: animal.endType,
          endReason: animal.endReason,
          endComment: animal.endComment,
          comment: animal.comment,
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
    // Build filters list, resolving CURRENT_USER placeholder
    List<FilterParam> filters = _activeFilters.map((f) {
      if (f.value == currentUserPlaceholder) {
        return f.copyWith(
          value: profileState.value?.accountUuid ?? '',
        );
      }
      return f;
    }).toList();

    // Add search term as physical_tag filter if provided
    if (searchTerm != null && searchTerm.isNotEmpty) {
      filters.add(
        FilterParam(
          field: 'physical_tag',
          operator: FilterOperators.contains,
          value: searchTerm,
        ),
      );
    }

    // Build sorts list
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

  List<GridColumn> get _animalColumns => buildColumnsFromSettings(
    _tableSetting?.tableSettingFields.toList(),
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
          filterFields: AnimalFilterConfig.filterFields,
          sortFields: AnimalFilterConfig.sortFields,
          initialFilters: _activeFilters,
          initialSort: _activeSort,
          onApply: _onFiltersApplied,
          onClear: _onFiltersClear,
          preparedFilters: AnimalFilterConfig.preparedFilters,
          selectedPresetIndex: _selectedPresetIndex,
          onPresetSelected: _onPresetSelected,
          onColumnSettingsTap: _tableSetting != null
              ? () => showColumnSettingsSheet(
                    context: context,
                    baseName: 'AnimalList',
                    tableSetting: _tableSetting!,
                    onSettingsChanged: () {
                      final updated = tableSettingStore.value['AnimalList'];
                      if (updated != null && mounted) {
                        setState(() => _tableSetting = updated);
                      }
                    },
                  )
              : null,
          searchPlaceholder: 'Try "Search Animal in mating"',
          onSearchSubmitted: (term) => _controller.search(term),
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              PaginatedDataGrid<AnimalDto>(
                onRowTap: _isEndingMode ? null : (animal) {
                  context.go('/animal/${animal.animalUuid}');
                },
                controller: _controller,
                onSortChanged: (columnName, ascending) {
                  final sort = SortParam(
                    field: columnName,
                    order: ascending ? SortOrder.asc : SortOrder.desc,
                  );
                  setState(() {
                    _activeSort = sort;
                  });
                  _sortNotifier.value = sort;
                  _controller.reload();
                },
                columns: _animalColumns,
                editFieldConfigs: _isEndingMode ? null : _editConfigs,
                getRowId: (a) => a.animalUuid,
                primaryColumn: 'physical_tag',
                onCellEditTap: _isEndingMode ? null : _onCellEditTap,
                onCellEditCommit: _isEndingMode ? null : _onCellEditCommit,
                sourceBuilder: (rows) {
                  _currentRows = rows;
                  return _AnimalGridSource(
                    records: rows,
                    selected: _selected,
                    onToggle: _onToggleSelected,
                    context: context,
                    isEndingMode: _isEndingMode,
                    columns: _animalColumns,
                  );
                },
                fetchPage: (page, pageSize) async {
                  final params = _buildQueryParams(
                    page: page,
                    pageSize: pageSize,
                  );
                  final pageData = await animalService.getAnimalsPageWithParams(
                    params: params,
                  );
                  return PaginatedResult<AnimalDto>(
                    count: pageData.count,
                    results: pageData.results.cast<AnimalDto>(),
                  );
                },
                pageSize: _pageSize,
                onFilterChanged:
                    (page, pageSize, searchTerm, {useAiSearch}) async {
                      if (useAiSearch == true && searchTerm.isNotEmpty) {
                        // AI search
                        eventApi.trackEvent('ai_search_animal');
                        final pageData = await animalService
                            .searchAnimalsWithAi(prompt: searchTerm);
                        return PaginatedResult<AnimalDto>(
                          count: pageData.count,
                          results: pageData.results,
                        );
                      }

                      // Regular search with filters
                      final params = _buildQueryParams(
                        page: page,
                        pageSize: pageSize,
                        searchTerm: searchTerm,
                      );
                      final pageData = await animalService
                          .getAnimalsPageWithParams(params: params);
                      return PaginatedResult<AnimalDto>(
                        count: pageData.count,
                        results: pageData.results,
                      );
                    },
              ),
              Positioned.fill(
                child: MovableFabMenu(
                  controller: _fabController,
                  heroTag: 'animals-fab-menu',
                  margin: const EdgeInsets.only(right: 24, bottom: 50),
                  actions: [
                    if (_isEndingMode) ...[
                      FabMenuAction(
                        label: _isEndingAnimals
                            ? 'Ending...'
                            : 'Quick End',
                        icon: _isEndingAnimals
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Icon(Icons.stop_circle_outlined),
                        onPressed: _selected.isNotEmpty && !_isEndingAnimals
                            ? _quickEndSelectedAnimals
                            : null,
                        enabled: _selected.isNotEmpty && !_isEndingAnimals,
                        closeOnTap: false,
                      ),
                      FabMenuAction(
                        label: 'End with Details',
                        icon: const Icon(Icons.assignment_outlined),
                        onPressed: _selected.isNotEmpty && !_isEndingAnimals
                            ? _endSelectedAnimalsWithForm
                            : null,
                        enabled: _selected.isNotEmpty && !_isEndingAnimals,
                      ),
                    ] else
                      FabMenuAction(
                        label: 'Create Animals',
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          context.go('/animal/new');
                        },
                      ),
                    FabMenuAction(
                      label: _isEndingMode ? 'Cancel End Mode' : 'End Animals',
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

  void _onToggleSelected(String uuid, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(uuid);
      } else {
        _selected.remove(uuid);
      }
    });
  }

  Future<void> _quickEndSelectedAnimals() async {
    if (_selected.isEmpty) return;
    try {
      setState(() {
        _isEndingAnimals = true;
      });
      await animalService.endAnimals(
        _selected.toList(),
        EndAnimalFormDto(
          endDate: DateTime.now().toIso8601String().split('T')[0],
        ),
      );
      eventApi.trackEvent('end_animal');
      if (!mounted) return;
      setState(() {
        _controller.reload();
        _selected.clear();
        _isEndingMode = false;
        _isEndingAnimals = false;
      });
      _fabController.close();
      showAppSnackBar(context, 'Animals ended successfully!', isSuccess: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isEndingAnimals = false;
      });
      showAppSnackBar(context, 'Failed to end animals. Please try again.', isError: true);
    }
  }

  void _endSelectedAnimalsWithForm() {
    if (_selected.isEmpty) return;
    final uuids = _selected.join(',');
    context.go('/animal/end?animals=$uuids');
  }

  @override
  void didUpdateWidget(covariant AnimalsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}

class _AnimalGridSource extends DataGridSource {
  final List<AnimalDto> records;
  final Set<String> selected;
  final void Function(String uuid, bool selected) onToggle;
  final BuildContext context;
  final bool isEndingMode;
  final List<GridColumn> columns;

  _AnimalGridSource({
    required this.records,
    required this.selected,
    required this.onToggle,
    required this.context,
    required this.isEndingMode,
    required this.columns,
  }) {
    _rows = records.map(AnimalListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final Map<String, Object?> values = {
      for (final cell in row.getCells()) cell.columnName: cell.value,
    };
    final String? uuid = values[AnimalListColumn.select.name] as String?;
    final bool isChecked = uuid != null && selected.contains(uuid);
    String? valueFor(AnimalListColumn column) => values[column.name] as String?;

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
        case 'physical_tag':
          return GestureDetector(
            onTap: uuid == null ? null : () => context.go('/animal/$uuid'),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: cellText(valueFor(AnimalListColumn.physicalTag)),
            ),
          );
        default:
          // All other columns use the enum name mapping
          final col = AnimalListColumn.values.cast<AnimalListColumn?>().firstWhere(
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
