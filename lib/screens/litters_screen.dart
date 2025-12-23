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
                columns: LitterListColumn.getColumns(),
                sourceBuilder: (rows) =>
                    _LitterGridSource(records: rows, context: context),
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
                    FabMenuAction(
                      label: 'Add Litter',
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        context.go('/litters/new');
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

class _LitterGridSource extends DataGridSource {
  final List<LitterDto> records;
  final BuildContext context;
  _LitterGridSource({required this.records, required this.context}) {
    _rows = records.map(LitterListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final String uuid = row.getCells()[0].value as String;
    return DataGridRowAdapter(
      cells: [
        Center(
          child: IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              context.go('/litters/$uuid');
            },
          ),
        ),
        cellText(row.getCells()[1].value),
        cellText(row.getCells()[2].value),
        cellText('${row.getCells()[3].value}'),
        cellText(row.getCells()[4].value),
        cellText(row.getCells()[5].value),
        cellText(row.getCells()[6].value),
        cellText(row.getCells()[7].value),
      ],
    );
  }
}
