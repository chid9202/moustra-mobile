import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/constants/list_constants/strain_filter_config.dart';
import 'package:moustra/constants/list_constants/strain_list_constants.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/services/clients/strain_api.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/widgets/color_picker.dart';
import 'package:moustra/widgets/filter_panel.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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
  bool _showInactiveOnly = false;

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
      _activeSort = StrainFilterConfig.defaultSort;
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
        field: 'strain_name',
        operator: FilterOperators.contains,
        value: searchTerm,
      ));
    }

    // Add inactive filter if toggled
    if (_showInactiveOnly) {
      filters.add(FilterParam(
        field: 'is_active',
        operator: FilterOperators.equals,
        value: 'false',
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
        // Filter Panel with inactive toggle
        Row(
          children: [
            Expanded(
              child: FilterPanel(
                filterFields: StrainFilterConfig.filterFields,
                sortFields: StrainFilterConfig.sortFields,
                initialFilters: _activeFilters,
                initialSort: _activeSort,
                onApply: _onFiltersApplied,
                onClear: _onFiltersClear,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _showInactiveOnly,
                    onChanged: (value) {
                      setState(() {
                        _showInactiveOnly = value ?? false;
                      });
                      _controller.reload();
                    },
                  ),
                  const Text('Inactive Only'),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              PaginatedDataGrid<StrainDto>(
                controller: _controller,
                searchPlaceholder: 'Try "Search strain B6"',
                onSortChanged: (columnName, ascending) {
                  setState(() {
                    _activeSort = SortParam(
                      field: columnName,
                      order: ascending ? SortOrder.asc : SortOrder.desc,
                    );
                  });
                  _controller.reload();
                },
                columns: StrainListColumn.getColumns(),
                sourceBuilder: (rows) => _StrainGridSource(
                  records: rows,
                  selected: _selected,
                  onToggle: _onToggleSelected,
                  context: context,
                ),
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
              ),
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
                        if (context.mounted) {
                          context.go('/strains/new');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Merged ${strains.length} strains.')),
      );
      _selected.clear();
      _controller.reload();
      _fabController.close();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Merge failed: $e')));
    }
  }
}

class _StrainGridSource extends DataGridSource {
  final List<StrainDto> records;
  final Set<String> selected;
  final void Function(String uuid, bool selected) onToggle;
  final BuildContext context;

  _StrainGridSource({
    required this.records,
    required this.selected,
    required this.onToggle,
    required this.context,
  }) {
    _dataGridRows = records.map(StrainListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _dataGridRows;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final String uuid = row.getCells()[0].value as String;
    final bool isChecked = selected.contains(uuid);
    return DataGridRowAdapter(
      cells: [
        Center(
          child: Checkbox(
            value: isChecked,
            onChanged: (v) {
              onToggle(uuid, v ?? false);
            },
          ),
        ),
        Center(
          child: IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              context.go('/strains/$uuid');
            },
          ),
        ),
        cellText(row.getCells()[2].value),
        cellText('${row.getCells()[3].value}', textAlign: Alignment.center),
        Center(child: ColorPicker(hex: row.getCells()[4].value)),
        cellText(row.getCells()[5].value),
        cellText(row.getCells()[6].value),
        cellText(row.getCells()[7].value),
        Center(
          child: Icon(
            (row.getCells()[8].value as bool)
                ? Icons.check_circle
                : Icons.cancel,
            color: (row.getCells()[8].value as bool)
                ? Colors.green
                : Colors.red,
            size: 18,
          ),
        ),
      ],
    );
  }
}
