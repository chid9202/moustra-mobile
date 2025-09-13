import 'package:flutter/material.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/helpers/genotype_helper.dart';
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
              _sortField = _mapSortField(columnName);
              _sortOrder = ascending ? 'asc' : 'desc';
              _controller.reload();
            },
            columns: _gridColumns(),
            sourceBuilder: (rows) => _CageGridSource(records: rows),
            fetchPage: (page, pageSize) async {
              final pageData = await cageService.getCagesPage(
                page: page,
                pageSize: pageSize,
                query: {
                  if (_sortField != null) 'sort': _sortField!,
                  if (_sortField != null) 'order': _sortOrder,
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

  List<GridColumn> _gridColumns() {
    return [
      GridColumn(
        columnName: 'eid',
        width: 80,
        label: Center(child: Text('EID')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'cageTag',
        width: 140,
        label: Center(child: Text('Cage Tag')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'strain',
        width: 200,
        label: Center(child: Text('Strain')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'num',
        width: 140,
        label: Center(child: Text('Number of Animals')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'tags',
        width: 240,
        label: Center(child: Text('Animal Tags')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'genotypes',
        width: 260,
        label: Center(child: Text('Genotypes')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'status',
        width: 120,
        label: Center(child: Text('Status')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'endDate',
        width: 160,
        label: Center(child: Text('End Date')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'owner',
        width: 220,
        label: Center(child: Text('Owner')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'created',
        width: 180,
        label: Center(child: Text('Created Date')),
        allowSorting: true,
      ),
    ];
  }

  String? _sortField;
  String _sortOrder = 'asc';
  String? _mapSortField(String columnName) {
    switch (columnName) {
      case 'cageTag':
        return 'cage_tag';
      case 'strain':
        return 'strain';
      case 'status':
        return 'status';
      case 'endDate':
        return 'end_date';
      case 'owner':
        return 'owner';
      case 'created':
        return 'created_date';
      default:
        return null;
    }
  }

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
    _rows = records.map(_toRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  DataGridRow _toRow(CageDto c) {
    final int eid = (c.eid);
    final String cageTag = (c.cageTag);
    final String strain = (c.strain?.strainName).toString();
    final List<dynamic> animals = (c.animals as List<dynamic>? ?? <dynamic>[]);
    final int numAnimals = animals.length;
    final List<String> animalTagLines = animals
        .map((a) => (a.physicalTag ?? '').toString())
        .where((t) => t.isNotEmpty)
        .toList();
    final List<String> animalGenotypeLines = animals
        .map(
          (a) =>
              GenotypeHelper.formatGenotypes(a.genotypes as List<GenotypeDto>?),
        )
        .where((g) => g.isNotEmpty)
        .toList();
    final String status = c.status;
    final String endDate = DateTimeHelper.formatDate(c.endDate);
    final String owner = AccountHelper.getOwnerName(c.owner);
    final String created = DateTimeHelper.formatDateTime(c.createdDate);
    return DataGridRow(
      cells: [
        DataGridCell<int>(columnName: 'eid', value: eid),
        DataGridCell<String>(columnName: 'cageTag', value: cageTag),
        DataGridCell<String>(columnName: 'strain', value: strain),
        DataGridCell<int>(columnName: 'num', value: numAnimals),
        DataGridCell<List<String>>(columnName: 'tags', value: animalTagLines),
        DataGridCell<List<String>>(
          columnName: 'genotypes',
          value: animalGenotypeLines,
        ),
        DataGridCell<String>(columnName: 'status', value: status),
        DataGridCell<String>(columnName: 'endDate', value: endDate),
        DataGridCell<String>(columnName: 'owner', value: owner),
        DataGridCell<String>(columnName: 'created', value: created),
      ],
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    List<String> asList(dynamic v) => (v as List<String>? ?? <String>[]);

    return DataGridRowAdapter(
      cells: [
        Center(child: Text('${row.getCells()[0].value}')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[1].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[2].value),
        ),
        Center(child: Text('${row.getCells()[3].value}')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: asList(row.getCells()[4].value)
                .map(
                  (t) => Text(t, overflow: TextOverflow.ellipsis, maxLines: 1),
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
                  (g) => Text(g, overflow: TextOverflow.ellipsis, maxLines: 1),
                )
                .toList(),
          ),
        ),
        Center(child: Text(row.getCells()[6].value)),
        Center(child: Text(row.getCells()[7].value)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[8].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[9].value),
        ),
      ],
    );
  }
}
