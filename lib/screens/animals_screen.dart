import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/animal_filter_config.dart';
import 'package:moustra/constants/list_constants/animal_list_constants.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/widgets/filter_panel.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
      _activeSort = AnimalFilterConfig.defaultSort;
    });
    _controller.reload();
  }

  ListQueryParams _buildQueryParams({
    required int page,
    required int pageSize,
    String? searchTerm,
  }) {
    // Build filters list
    List<FilterParam> filters = List.from(_activeFilters);

    // Add search term as physical_tag filter if provided
    if (searchTerm != null && searchTerm.isNotEmpty) {
      filters.add(FilterParam(
        field: 'physical_tag',
        operator: FilterOperators.contains,
        value: searchTerm,
      ));
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
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              PaginatedDataGrid<AnimalDto>(
                controller: _controller,
                searchPlaceholder: 'Try "Search Animal in mating"',
                onSortChanged: (columnName, ascending) {
                  // Update sort from column header click
                  setState(() {
                    _activeSort = SortParam(
                      field: columnName,
                      order: ascending ? SortOrder.asc : SortOrder.desc,
                    );
                  });
                  _controller.reload();
                },
                columns: AnimalListColumn.getColumns(
                  includeSelect: _isEndingMode,
                ),
                sourceBuilder: (rows) => _AnimalGridSource(
                  records: rows,
                  selected: _selected,
                  onToggle: _onToggleSelected,
                  context: context,
                  isEndingMode: _isEndingMode,
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
                    final pageData = await animalService.searchAnimalsWithAi(
                      prompt: searchTerm,
                    );
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
                  final pageData = await animalService.getAnimalsPageWithParams(
                    params: params,
                  );
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
                    if (_isEndingMode)
                      FabMenuAction(
                        label: _isEndingAnimals
                            ? 'Ending...'
                            : 'End Selected Animals',
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
                            ? _endSelectedAnimals
                            : null,
                        enabled: _selected.isNotEmpty && !_isEndingAnimals,
                        closeOnTap: false,
                      )
                    else
                      FabMenuAction(
                        label: 'Create Animals',
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          context.go('/animals/new');
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

  Future<void> _endSelectedAnimals() async {
    if (_selected.isEmpty) {
      return;
    }
    try {
      setState(() {
        _isEndingAnimals = true;
      });
      await animalService.endAnimals(_selected.toList());
      await animalService.getAnimalsPage(page: 1, pageSize: _pageSize);
      if (!mounted) {
        return;
      }
      setState(() {
        _controller.reload();
        _selected.clear();
        _isEndingMode = false;
        _isEndingAnimals = false;
      });
      _fabController.close();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animals ended successfully!')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isEndingAnimals = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to end animals. Please try again.'),
        ),
      );
    }
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

  _AnimalGridSource({
    required this.records,
    required this.selected,
    required this.onToggle,
    required this.context,
    required this.isEndingMode,
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
    final String? uuid = values[AnimalListColumn.edit.name] as String?;
    final bool isChecked = uuid != null && selected.contains(uuid);
    final BuildContext context = this.context;
    final List<Widget> cells = [];
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
    cells.add(
      Center(
        child: IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: uuid == null
              ? null
              : () {
                  context.go('/animals/$uuid');
                },
        ),
      ),
    );
    String? valueFor(AnimalListColumn column) => values[column.name] as String?;
    cells.add(cellText(valueFor(AnimalListColumn.physicalTag)));
    cells.add(
      cellText(valueFor(AnimalListColumn.sex), textAlign: Alignment.center),
    );
    cells.add(
      cellText(valueFor(AnimalListColumn.dob), textAlign: Alignment.center),
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
    return DataGridRowAdapter(cells: cells);
  }
}
