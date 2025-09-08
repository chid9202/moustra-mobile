import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grid_view/services/animal_service.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  late Future<List<dynamic>> _future;
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  int _currentPage = 0; // zero-based
  int _pageSize = 25;
  int _totalCount = 0;
  // account path unused here; API base handled in services

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
          return Center(
            child: Text('Failed to load animals: ${snapshot.error}'),
          );
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
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add Animal'),
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('End Animal'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SfDataGrid(
                source: _AnimalGridSource(records: _rows),
                columns: _gridColumns(),
                allowSorting: true,
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

  @override
  void didUpdateWidget(covariant AnimalsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  List<GridColumn> _gridColumns() {
    return [
      GridColumn(
        columnName: 'eid',
        width: 80,
        label: Center(child: Text('EID')),
      ),
      GridColumn(
        columnName: 'ptag',
        width: 120,
        label: Center(child: Text('Physical Tag')),
      ),
      GridColumn(
        columnName: 'status',
        width: 100,
        label: Center(child: Text('Status')),
      ),
      GridColumn(
        columnName: 'sex',
        width: 80,
        label: Center(child: Text('Sex')),
      ),
      GridColumn(
        columnName: 'dob',
        width: 140,
        label: Center(child: Text('Date of Birth')),
      ),
      GridColumn(
        columnName: 'age',
        width: 80,
        label: Center(child: Text('Age')),
      ),
      GridColumn(
        columnName: 'wean',
        width: 140,
        label: Center(child: Text('Wean Date')),
      ),
      GridColumn(
        columnName: 'cage',
        width: 120,
        label: Center(child: Text('Cage Tag')),
      ),
      GridColumn(
        columnName: 'strain',
        width: 200,
        label: Center(child: Text('Strain')),
      ),
      GridColumn(
        columnName: 'genotypes',
        width: 240,
        label: Center(child: Text('Genotypes')),
      ),
      GridColumn(
        columnName: 'sire',
        width: 160,
        label: Center(child: Text('Sire')),
      ),
      GridColumn(
        columnName: 'dam',
        width: 160,
        label: Center(child: Text('Dam')),
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

  // Data formatting now handled in DataGrid source

  int _pageCount() {
    if (_totalCount <= 0) return 1;
    return (_totalCount + _pageSize - 1) ~/ _pageSize;
  }

  Future<List<dynamic>> _fetchPage(int zeroBasedPage) async {
    final pageData = await animalService.getAnimalsPage(
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

class _AnimalGridSource extends DataGridSource {
  final List<Map<String, dynamic>> records;

  _AnimalGridSource({required this.records}) {
    _rows = records.map(_toGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  DataGridRow _toGridRow(Map<String, dynamic> a) {
    final int eid = (a['eid'] ?? 0) as int;
    final String physicalTag = (a['physicalTag'] ?? '').toString();
    final String status = (a['cage']?['status'] ?? '').toString();
    final String sex = (a['sex'] ?? '').toString();
    final String dob = (a['dateOfBirth'] ?? '').toString();
    final String age = _age(a['dateOfBirth']?.toString() ?? '');
    final String weanDate = (a['weanDate'] ?? '').toString();
    final String cageTag = (a['cage']?['cageTag'] ?? '').toString();
    final String strain = (a['strain']?['strainName'] ?? '').toString();
    final String genotypes = _genotypes(a['genotypes'] as List<dynamic>?);
    final String sire = (a['sire']?['physicalTag'] ?? '').toString();
    final String dam = _dam(a['dam'] as List<dynamic>?);
    final String owner =
        (a['owner']?['user']?['email'] ??
                a['owner']?['user']?['username'] ??
                '')
            .toString();
    final String created = (a['createdDate'] ?? '').toString();
    return DataGridRow(
      cells: [
        DataGridCell<int>(columnName: 'eid', value: eid),
        DataGridCell<String>(columnName: 'ptag', value: physicalTag),
        DataGridCell<String>(columnName: 'status', value: status),
        DataGridCell<String>(columnName: 'sex', value: sex),
        DataGridCell<String>(columnName: 'dob', value: dob),
        DataGridCell<String>(columnName: 'age', value: age),
        DataGridCell<String>(columnName: 'wean', value: weanDate),
        DataGridCell<String>(columnName: 'cage', value: cageTag),
        DataGridCell<String>(columnName: 'strain', value: strain),
        DataGridCell<String>(columnName: 'genotypes', value: genotypes),
        DataGridCell<String>(columnName: 'sire', value: sire),
        DataGridCell<String>(columnName: 'dam', value: dam),
        DataGridCell<String>(columnName: 'owner', value: owner),
        DataGridCell<String>(columnName: 'created', value: created),
      ],
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    String _fmtDate(String iso) {
      if (iso.isEmpty) return '';
      final dt = DateTime.tryParse(iso)?.toLocal();
      if (dt == null) return iso;
      return DateFormat('M/d/y').format(dt);
    }

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
        Center(child: Text(row.getCells()[2].value as String)),
        Center(child: Text(row.getCells()[3].value as String)),
        Center(child: Text(_fmtDate(row.getCells()[4].value as String))),
        Center(child: Text(row.getCells()[5].value as String)),
        Center(child: Text(_fmtDate(row.getCells()[6].value as String))),
        Center(child: Text(row.getCells()[7].value as String)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[8].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[9].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[10].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[11].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[12].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(_fmtDateTime(row.getCells()[13].value as String)),
        ),
      ],
    );
  }

  String _age(String dobIso) {
    final dob = DateTime.tryParse(dobIso);
    if (dob == null) return '';
    final now = DateTime.now();
    int totalDays = now.difference(dob).inDays;
    if (totalDays < 0) totalDays = 0;
    final int weeks = totalDays ~/ 7;
    final int days = totalDays % 7;
    if (weeks == 0) return '${days}d';
    if (days == 0) return '${weeks}w';
    return '${weeks}w${days}d';
  }

  String _genotypes(List<dynamic>? list) {
    if (list == null || list.isEmpty) return '';
    return list
        .map((g) {
          final gene = (g['gene']?['geneName'] ?? '').toString();
          final allele = (g['allele']?['alleleName'] ?? '').toString();
          return gene.isEmpty ? allele : '$gene/$allele';
        })
        .join(', ');
  }

  String _dam(List<dynamic>? list) {
    if (list == null || list.isEmpty) return '';
    return list
        .map((d) => (d['physicalTag'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .join(', ');
  }
}
