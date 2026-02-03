import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/constants/list_constants/litter_filter_config.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/clients/litter_api.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/constants/list_constants/litter_list_constants.dart';
import 'package:moustra/widgets/filter_panel.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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

  // Filter & Sort state
  List<FilterParam> _activeFilters = [];
  SortParam? _activeSort = LitterFilterConfig.defaultSort;

  @override
  void initState() {
    super.initState();
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
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              PaginatedDataGrid<LitterDto>(
                controller: _controller,
                searchPlaceholder: 'Try "Search litter LTR-001"',
                onSortChanged: (columnName, ascending) {
                  setState(() {
                    _activeSort = SortParam(
                      field: columnName,
                      order: ascending ? SortOrder.asc : SortOrder.desc,
                    );
                  });
                  _controller.reload();
                },
                columns: LitterListColumn.getColumns(
                  includeSelect: _isEndingMode,
                ),
                sourceBuilder: (rows) => _LitterGridSource(
                  records: rows,
                  context: context,
                  selected: _selected,
                  onToggle: _onToggleSelected,
                  isEndingMode: _isEndingMode,
                ),
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
                        label: 'Add Litter',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Litters ended successfully!')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isEndingLitters = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to end litters. Please try again.'),
        ),
      );
    }
  }
}

class _LitterGridSource extends DataGridSource {
  final List<LitterDto> records;
  final BuildContext context;
  final Set<String> selected;
  final void Function(String uuid, bool selected) onToggle;
  final bool isEndingMode;

  _LitterGridSource({
    required this.records,
    required this.context,
    required this.selected,
    required this.onToggle,
    required this.isEndingMode,
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
    final List<Widget> cells = [];

    // Select checkbox column
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

    // Edit column
    cells.add(
      Center(
        child: IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: uuid == null
              ? null
              : () {
                  context.go('/litter/$uuid');
                },
        ),
      ),
    );

    // Data columns
    cells.add(cellText(values[LitterListColumn.litterTag.name] as String?));
    cells.add(cellText(values[LitterListColumn.litterStrain.name] as String?));
    cells.add(cellText('${values[LitterListColumn.numberOfPups.name] ?? ''}'));
    cells.add(cellText(values[LitterListColumn.wean.name] as String?));
    cells.add(cellText(values[LitterListColumn.dob.name] as String?));
    cells.add(cellText(values[LitterListColumn.owner.name] as String?));
    cells.add(cellText(values[LitterListColumn.created.name] as String?));

    return DataGridRowAdapter(cells: cells);
  }
}
