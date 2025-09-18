import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/animal_constants.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/constants/list_constants/mating_list_constants.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/clients/mating_api.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:moustra/widgets/safe_text.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';

class MatingsScreen extends StatefulWidget {
  const MatingsScreen({super.key});

  @override
  State<MatingsScreen> createState() => _MatingsScreenState();
}

class _MatingsScreenState extends State<MatingsScreen> {
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
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/matings/new');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Mating'),
            ),
          ),
        ),
        Expanded(
          child: PaginatedDataGrid<MatingDto>(
            controller: _controller,
            onSortChanged: (columnName, ascending) {
              _sortField = columnName;
              _sortOrder = ascending ? SortOrder.asc.name : SortOrder.desc.name;
              _controller.reload();
            },
            columns: MatingListColumn.getColumns(),
            sourceBuilder: (rows) =>
                _MatingGridSource(records: rows, context: context),
            fetchPage: (page, pageSize) async {
              final pageData = await matingService.getMatingsPage(
                page: page,
                pageSize: pageSize,
                query: {
                  if (_sortField != null)
                    SortQueryParamKey.sort.name: _sortField!,
                  if (_sortField != null)
                    SortQueryParamKey.order.name: _sortOrder,
                },
              );
              return PaginatedResult<MatingDto>(
                count: pageData.count,
                results: pageData.results.cast<MatingDto>(),
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

  int _estimateLines(MatingDto m) {
    final List<AnimalSummaryDto> animals =
        (m.animals as List<AnimalSummaryDto>? ?? <AnimalSummaryDto>[]);
    final List<AnimalSummaryDto> females = animals
        .where((a) => (a.sex ?? '') == SexConstants.female)
        .cast<AnimalSummaryDto>()
        .toList();
    final int femaleTagLines = females
        .map((f) => (f.physicalTag ?? '').toString())
        .where((t) => t.isNotEmpty)
        .length;
    final int femaleGenotypeLines = females
        .map((f) => GenotypeHelper.formatGenotypes(f.genotypes))
        .where((g) => g.isNotEmpty)
        .length;
    final int maxLines = femaleTagLines > femaleGenotypeLines
        ? femaleTagLines
        : femaleGenotypeLines;
    return maxLines.clamp(1, 20);
  }
}

class _MatingGridSource extends DataGridSource {
  final List<MatingDto> records;
  final BuildContext context;

  _MatingGridSource({required this.records, required this.context}) {
    _rows = records.map(MatingListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final String uuid = row.getCells()[0].value as String;
    final BuildContext context = this.context;
    List<String> asList(dynamic v) => (v as List<String>? ?? <String>[]);

    return DataGridRowAdapter(
      cells: [
        Center(
          child: IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              context.go('/matings/$uuid');
            },
          ),
        ),
        Center(child: SafeText('${row.getCells()[2].value}')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[2].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[3].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[4].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[5].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(
            row.getCells()[6].value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: asList(row.getCells()[7].value)
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
            children: asList(row.getCells()[8].value)
                .map(
                  (g) =>
                      SafeText(g, overflow: TextOverflow.ellipsis, maxLines: 1),
                )
                .toList(),
          ),
        ),
        Center(child: SafeText(row.getCells()[9].value)),
        Center(child: Text(row.getCells()[10].value)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[11].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[12].value),
        ),
      ],
    );
  }
}
