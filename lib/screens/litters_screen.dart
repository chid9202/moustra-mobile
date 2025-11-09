import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/clients/litter_api.dart';
import 'package:moustra/constants/list_constants/litter_list_constants.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PaginatedDataGrid<LitterDto>(
          controller: _controller,
          searchPlaceholder: 'Try "Search litter LTR-001"',
          onSortChanged: (columnName, ascending) {
            _sortField = columnName;
            _sortOrder = ascending ? SortOrder.asc.name : SortOrder.desc.name;
            _controller.reload();
          },
          columns: LitterListColumn.getColumns(),
          sourceBuilder: (rows) =>
              _LitterGridSource(records: rows, context: context),
          fetchPage: (page, pageSize) async {
            final pageData = await litterService.getLittersPage(
              page: page,
              pageSize: pageSize,
              query: {
                if (_sortField != null)
                  SortQueryParamKey.sort.name: _sortField!,
                if (_sortField != null)
                  SortQueryParamKey.order.name: _sortOrder,
              },
            );
            return PaginatedResult<LitterDto>(
              count: pageData.count,
              results: pageData.results.cast<LitterDto>(),
            );
          },
          onFilterChanged: (page, pageSize, searchTerm, {useAiSearch}) async {
            final pageData = await litterService.getLittersPage(
              page: page,
              pageSize: pageSize,
              query: {
                if (_sortField != null)
                  SortQueryParamKey.sort.name: _sortField!,
                if (_sortField != null)
                  SortQueryParamKey.order.name: _sortOrder,
                if (searchTerm.isNotEmpty) ...{
                  SearchQueryParamKey.filter.name: 'litter_tag',
                  SearchQueryParamKey.value.name: searchTerm,
                  SearchQueryParamKey.op.name: 'contains',
                },
              },
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
    );
  }

  String? _sortField;
  String _sortOrder = SortOrder.asc.name;
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
        // Center(child: SafeText('${row.getCells()[1].value}')),
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
