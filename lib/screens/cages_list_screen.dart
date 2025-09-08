import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grid_view/services/cage_service.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CagesListScreen extends StatefulWidget {
  const CagesListScreen({super.key});

  @override
  State<CagesListScreen> createState() => _CagesListScreenState();
}

class _CagesListScreenState extends State<CagesListScreen> {
  late Future<List<dynamic>> _future;
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  int _currentPage = 0; // zero-based
  final int _pageSize = 25;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _future = _fetchPage(0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Failed to load cages: ${snapshot.error}'));
        }
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
              child: SfDataGrid(
                source: _CageGridSource(records: _rows),
                columns: _gridColumns(),
                onQueryRowHeight: (details) {
                  const double base = 48;
                  final int ri = details.rowIndex;
                  if (ri <= 0 || ri > _rows.length) {
                    return base;
                  }
                  final Map<String, dynamic> row = _rows[ri - 1];
                  final int lines = _estimateLines(row);
                  return base + (lines > 1 ? (lines - 1) * 20.0 : 0);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous',
                    onPressed: _currentPage > 0
                        ? () => _goToPage(_currentPage - 1)
                        : null,
                  ),
                  Text(
                    'Page ${_currentPage + 1} of ${_pageCount()} (Total: $_totalCount)',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next',
                    onPressed: (_currentPage + 1) < _pageCount()
                        ? () => _goToPage(_currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<GridColumn> _gridColumns() {
    return [
      GridColumn(
        columnName: 'eid',
        width: 80,
        label: Center(child: Text('EID')),
      ),
      GridColumn(
        columnName: 'cageTag',
        width: 140,
        label: Center(child: Text('Cage Tag')),
      ),
      GridColumn(
        columnName: 'strain',
        width: 200,
        label: Center(child: Text('Strain')),
      ),
      GridColumn(
        columnName: 'num',
        width: 140,
        label: Center(child: Text('Number of Animals')),
      ),
      GridColumn(
        columnName: 'tags',
        width: 240,
        label: Center(child: Text('Animal Tags')),
      ),
      GridColumn(
        columnName: 'genotypes',
        width: 260,
        label: Center(child: Text('Genotypes')),
      ),
      GridColumn(
        columnName: 'status',
        width: 120,
        label: Center(child: Text('Status')),
      ),
      GridColumn(
        columnName: 'owner',
        width: 220,
        label: Center(child: Text('Owner')),
      ),
      GridColumn(
        columnName: 'created',
        width: 180,
        label: Center(child: Text('Created Date')),
      ),
    ];
  }

  int _estimateLines(Map<String, dynamic> c) {
    final List<dynamic> animals =
        (c['animals'] as List<dynamic>? ?? <dynamic>[]);
    int tags = animals
        .map((a) => (a['physicalTag'] ?? '').toString())
        .where((t) => t.isNotEmpty)
        .length;
    int gens = animals
        .map((a) => _fmtGenotypes(a['genotypes'] as List<dynamic>?))
        .where((g) => g.isNotEmpty)
        .length;
    return (tags > gens ? tags : gens).clamp(1, 20);
  }

  // header/body rendering handled by SfDataGrid

  String _fmtGenotypes(List<dynamic>? list) {
    if (list == null || list.isEmpty) return '';
    return list
        .map((g) {
          final String gene = (g['gene']?['geneName'] ?? '').toString();
          final String allele = (g['allele']?['alleleName'] ?? '').toString();
          return gene.isEmpty ? allele : '$gene/$allele';
        })
        .join(', ');
  }

  int _pageCount() {
    if (_totalCount <= 0) return 1;
    return (_totalCount + _pageSize - 1) ~/ _pageSize;
  }

  Future<List<dynamic>> _fetchPage(int zeroBasedPage) async {
    final pageData = await cageService.getCagesPage(
      page: zeroBasedPage + 1,
      pageSize: _pageSize,
    );
    _totalCount = pageData.count;
    _rows = pageData.results.cast<Map<String, dynamic>>();
    return _rows;
  }

  Future<void> _goToPage(int zeroBasedPage) async {
    setState(() {
      _currentPage = zeroBasedPage;
    });
    await _fetchPage(zeroBasedPage);
    if (!mounted) return;
    setState(() {});
  }
}

class _CageGridSource extends DataGridSource {
  final List<Map<String, dynamic>> records;

  _CageGridSource({required this.records}) {
    _rows = records.map(_toRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  DataGridRow _toRow(Map<String, dynamic> c) {
    final int eid = (c['eid'] ?? 0) as int;
    final String cageTag = (c['cageTag'] ?? '').toString();
    final String strain = (c['strain']?['strainName'] ?? '').toString();
    final List<dynamic> animals =
        (c['animals'] as List<dynamic>? ?? <dynamic>[]);
    final int numAnimals = animals.length;
    final List<String> animalTagLines = animals
        .map((a) => (a['physicalTag'] ?? '').toString())
        .where((t) => t.isNotEmpty)
        .toList();
    final List<String> animalGenotypeLines = animals
        .map((a) => _fmtGenotypes(a['genotypes'] as List<dynamic>?))
        .where((g) => g.isNotEmpty)
        .toList();
    final String status = (c['status'] ?? '').toString();
    final String owner =
        (c['owner']?['user']?['email'] ??
                c['owner']?['user']?['username'] ??
                '')
            .toString();
    final String created = (c['createdDate'] ?? '').toString();
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
        DataGridCell<String>(columnName: 'owner', value: owner),
        DataGridCell<String>(columnName: 'created', value: created),
      ],
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    List<String> _asList(dynamic v) => (v as List<String>? ?? <String>[]);
    String _fmtDateTime(String iso) {
      if (iso.isEmpty) return '';
      final dt = DateTime.tryParse(iso)?.toLocal();
      if (dt == null) return iso;
      return DateFormat('M/d/y, h:mm:ss a').format(dt);
    }

    return DataGridRowAdapter(
      cells: [
        Center(child: Text('${row.getCells()[0].value as int}')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[1].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[2].value as String),
        ),
        Center(child: Text('${row.getCells()[3].value as int}')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _asList(row.getCells()[4].value)
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
            children: _asList(row.getCells()[5].value)
                .map(
                  (g) => Text(g, overflow: TextOverflow.ellipsis, maxLines: 1),
                )
                .toList(),
          ),
        ),
        Center(child: Text(row.getCells()[6].value as String)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[7].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(_fmtDateTime(row.getCells()[8].value as String)),
        ),
      ],
    );
  }

  String _fmtGenotypes(List<dynamic>? list) {
    if (list == null || list.isEmpty) return '';
    return list
        .map((g) {
          final String gene = (g['gene']?['geneName'] ?? '').toString();
          final String allele = (g['allele']?['alleleName'] ?? '').toString();
          return gene.isEmpty ? allele : '$gene/$allele';
        })
        .join(', ');
  }
}
