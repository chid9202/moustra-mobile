import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/cage_list_constants.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:moustra/widgets/safe_text.dart';
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
                ElevatedButton.icon(
                  onPressed: () {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Cage clicked')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Cage'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('End Cage clicked')),
                    );
                  },
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('End Cage'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PaginatedDataGrid<CageDto>(
            controller: _controller,
            onSortChanged: (columnName, ascending) {
              print('onSortChanged: $columnName, $ascending');
              _sortField = columnName;
              _sortOrder = ascending ? SortOrder.asc.name : SortOrder.desc.name;
              _controller.reload();
            },
            columns: CageListColumn.getColumns(),
            sourceBuilder: (rows) => _CageGridSource(records: rows),
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

  _CageGridSource({required this.records}) {
    _rows = records.map(CageListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    List<String> asList(dynamic v) => (v as List<String>? ?? <String>[]);

    return DataGridRowAdapter(
      cells: [
        Center(child: SafeText('${row.getCells()[0].value}')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[1].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[2].value),
        ),
        Center(child: SafeText('${row.getCells()[3].value}')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: asList(row.getCells()[4].value)
                .map(
                  (t) =>
                      SafeText(t, overflow: TextOverflow.ellipsis, maxLines: 1),
                )
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: asList(row.getCells()[5].value)
                .map(
                  (g) =>
                      SafeText(g, overflow: TextOverflow.ellipsis, maxLines: 1),
                )
                .toList(),
          ),
        ),
        Center(child: SafeText(row.getCells()[6].value)),
        Center(child: SafeText(row.getCells()[7].value)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[8].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[9].value),
        ),
      ],
    );
  }
}
