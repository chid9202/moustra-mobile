import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/cage_list_constants.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:moustra/widgets/shared/button.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';

class CagesListScreen extends StatefulWidget {
  const CagesListScreen({super.key});

  @override
  State<CagesListScreen> createState() => _CagesListScreenState();
}

class _CagesListScreenState extends State<CagesListScreen> {
  final PaginatedGridController _controller = PaginatedGridController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 12,
              children: [
                MoustraButton.icon(
                  onPressed: () {
                    context.go('/cages/new');
                  },
                  icon: Icons.add,
                  label: 'Add Cage',
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PaginatedDataGrid<CageDto>(
            controller: _controller,
            onSortChanged: (columnName, ascending) {
              _sortField = columnName;
              _sortOrder = ascending ? SortOrder.asc.name : SortOrder.desc.name;
              _controller.reload();
            },
            columns: CageListColumn.getColumns(),
            sourceBuilder: (rows) =>
                _CageGridSource(records: rows, context: context),
            fetchPage: (page, pageSize) async {
              final pageData = await cageService.getCagesPage(
                page: page,
                pageSize: pageSize,
                query: {
                  if (_sortField != null)
                    SortQueryParamKey.sort.name: _sortField!,
                  if (_sortField != null)
                    SortQueryParamKey.order.name: _sortOrder,
                },
              );
              return PaginatedResult<CageDto>(
                count: pageData.count,
                results: pageData.results.cast<CageDto>(),
              );
            },
            onFilterChanged: (page, pageSize, searchTerm) async {
              final pageData = await cageService.getCagesPage(
                page: page,
                pageSize: pageSize,
                query: {
                  if (_sortField != null)
                    SortQueryParamKey.sort.name: _sortField!,
                  if (_sortField != null)
                    SortQueryParamKey.order.name: _sortOrder,
                  if (searchTerm.isNotEmpty) ...{
                    SearchQueryParamKey.filter.name: 'cage_tag',
                    SearchQueryParamKey.value.name: searchTerm,
                    SearchQueryParamKey.op.name: 'contains',
                  },
                },
              );
              return PaginatedResult<CageDto>(
                count: pageData.count,
                results: pageData.results,
              );
            },
            rowHeightEstimator: (index, row) => _estimateLines(row),
          ),
        ),
      ],
    );
  }

  String? _sortField;
  String _sortOrder = SortOrder.asc.name;

  int _estimateLines(CageDto c) {
    final List<dynamic> animals = (c.animals as List<dynamic>? ?? <dynamic>[]);
    int tags = animals
        .map((a) => (a.physicalTag ?? '').toString())
        .where((t) => t.isNotEmpty)
        .length;
    int gens = animals
        .map((a) => GenotypeHelper.formatGenotypes(a.genotypes))
        .where((g) => g.isNotEmpty)
        .length;
    return (tags > gens ? tags : gens).clamp(1, 20);
  }
}

class _CageGridSource extends DataGridSource {
  final List<CageDto> records;
  final BuildContext context;

  _CageGridSource({required this.records, required this.context}) {
    _rows = records.map(CageListColumn.getDataGridRow).toList();
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
              context.go('/cages/$uuid');
            },
          ),
        ),
        cellText('${row.getCells()[1].value}', textAlign: Alignment.center),
        cellText(row.getCells()[2].value),
        cellText(row.getCells()[3].value),
        cellText('${row.getCells()[4].value}', textAlign: Alignment.center),
        cellTextList(row.getCells()[5].value),
        cellTextList(row.getCells()[6].value),
        cellText(row.getCells()[7].value),
        cellText(row.getCells()[8].value),
        cellText(row.getCells()[9].value),
        cellText(row.getCells()[10].value),
      ],
    );
  }
}
