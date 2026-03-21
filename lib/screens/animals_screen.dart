import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/animal_filter_config.dart';
import 'package:moustra/constants/list_constants/animal_list_constants.dart';
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

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  final PaginatedGridController _controller = PaginatedGridController();
  final Set<String> _selected = <String>{};
  final int _pageSize = 1000;
  bool _isEditMode = false;
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
          isEditMode: _isEditMode,
          onEditToggle: () => setState(() => _isEditMode = !_isEditMode),
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
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              PaginatedDataGrid<AnimalDto>(
                controller: _controller,
                searchPlaceholder: 'Try "Search Animal in mating"',
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
                onRowTap: _isEditMode
                    ? (AnimalDto animal) =>
                        context.go('/animal/${animal.animalUuid}')
                    : null,
                columns: [
                  if (_isEditMode)
                    GridColumn(
                      columnName: 'edit_stripe',
                      width: 4,
                      label: Builder(
                        builder: (ctx) => Container(
                          color: Theme.of(ctx).colorScheme.primary,
                        ),
                      ),
                      allowSorting: false,
                    ),
                  ...AnimalListColumn.getColumns(
                    includeSelect: _isEndingMode,
                    sortNotifier: _sortNotifier,
                    settingFields: _tableSetting?.tableSettingFields.toList(),
                  ),
                ],
                sourceBuilder: (rows) => _AnimalGridSource(
                  records: rows,
                  selected: _selected,
                  onToggle: _onToggleSelected,
                  context: context,
                  isEndingMode: _isEndingMode,
                  isEditMode: _isEditMode,
                ),
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
  final bool isEditMode;

  _AnimalGridSource({
    required this.records,
    required this.selected,
    required this.onToggle,
    required this.context,
    required this.isEndingMode,
    required this.isEditMode,
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
    final List<Widget> cells = [];
    if (isEditMode) {
      cells.add(
        Builder(
          builder: (c) => Container(
            color: Theme.of(c).colorScheme.primary,
          ),
        ),
      );
    }
    cells.add(
      Center(
        child: Checkbox(
          value: isChecked,
          onChanged: uuid == null
              ? null
              : (v) {
                  onToggle(uuid, v ?? false);
                },
        ),
      ),
    );
    String? valueFor(AnimalListColumn column) => values[column.name] as String?;
    final String animalTag = valueFor(AnimalListColumn.physicalTag) ?? '';
    cells.add(
      GestureDetector(
        onTap: uuid == null ? null : () => context.go('/animal/$uuid'),
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: cellText(valueFor(AnimalListColumn.physicalTag)),
        ),
      ),
    );
    cells.add(
      cellText(valueFor(AnimalListColumn.sex)),
    );
    cells.add(
      cellText(valueFor(AnimalListColumn.dob)),
    );
    cells.add(cellText(valueFor(AnimalListColumn.genotypes)));
    cells.add(cellText(valueFor(AnimalListColumn.status)));
    cells.add(cellText(valueFor(AnimalListColumn.age)));
    cells.add(cellText(valueFor(AnimalListColumn.wean)));
    cells.add(cellText(valueFor(AnimalListColumn.cage)));
    cells.add(cellText(valueFor(AnimalListColumn.strain)));
    cells.add(cellText(valueFor(AnimalListColumn.sire)));
    cells.add(cellText(valueFor(AnimalListColumn.dam)));
    cells.add(cellText(valueFor(AnimalListColumn.owner)));
    cells.add(cellText(valueFor(AnimalListColumn.created)));
    return DataGridRowAdapter(
      color: isEditMode
          ? Theme.of(context).colorScheme.secondaryContainer.withValues(
              alpha: 0.25,
            )
          : null,
      cells: cells,
    );
  }
}
