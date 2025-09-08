import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grid_view/services/litter_service.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class LittersScreen extends StatefulWidget {
  const LittersScreen({super.key});

  @override
  State<LittersScreen> createState() => _LittersScreenState();
}

class _LittersScreenState extends State<LittersScreen> {
  late Future<List<dynamic>> _future;
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  int _currentPage = 0; // zero-based
  int _pageSize = 25;
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
          return Center(
            child: Text('Failed to load litters: ${snapshot.error}'),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Litter clicked')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Litter'),
                ),
              ),
            ),
            Expanded(
              child: SfDataGrid(
                source: _LitterGridSource(records: _rows),
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

  List<GridColumn> _gridColumns() {
    return [
      GridColumn(
        columnName: 'eid',
        width: 80,
        label: Center(child: Text('EID')),
      ),
      GridColumn(
        columnName: 'tag',
        width: 140,
        label: Center(child: Text('Litter Tag')),
      ),
      GridColumn(
        columnName: 'strain',
        width: 200,
        label: Center(child: Text('Litter Strain')),
      ),
      GridColumn(
        columnName: 'num',
        width: 160,
        label: Center(child: Text('Number of Pups')),
      ),
      GridColumn(
        columnName: 'wean',
        width: 140,
        label: Center(child: Text('Wean Date')),
      ),
      GridColumn(
        columnName: 'dob',
        width: 160,
        label: Center(child: Text('Date of Birth')),
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
  // header/body rendering handled by DataGrid

  int _pageCount() {
    if (_totalCount <= 0) return 1;
    return (_totalCount + _pageSize - 1) ~/ _pageSize;
  }

  Future<List<dynamic>> _fetchPage(int zeroBasedPage) async {
    final pageData = await litterService.getLittersPage(
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

class _LitterGridSource extends DataGridSource {
  final List<Map<String, dynamic>> records;

  _LitterGridSource({required this.records}) {
    _rows = records.map(_toGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  DataGridRow _toGridRow(Map<String, dynamic> l) {
    final int eid = (l['eid'] ?? 0) as int;
    final String tag = (l['litterTag'] ?? '').toString();
    final String strain = (l['mating']?['litterStrain']?['strainName'] ?? '')
        .toString();
    final List<dynamic> pups = (l['animals'] as List<dynamic>? ?? <dynamic>[]);
    final int numPups = pups.length;
    final String weanDate = (l['weanDate'] ?? '').toString();
    final String dob = (l['dateOfBirth'] ?? '').toString();
    final String owner =
        (l['owner']?['user']?['email'] ??
                l['owner']?['user']?['username'] ??
                '')
            .toString();
    final String created = (l['createdDate'] ?? '').toString();
    return DataGridRow(
      cells: [
        DataGridCell<int>(columnName: 'eid', value: eid),
        DataGridCell<String>(columnName: 'tag', value: tag),
        DataGridCell<String>(columnName: 'strain', value: strain),
        DataGridCell<int>(columnName: 'num', value: numPups),
        DataGridCell<String>(columnName: 'wean', value: weanDate),
        DataGridCell<String>(columnName: 'dob', value: dob),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[2].value as String),
        ),
        Center(child: Text('${row.getCells()[3].value as int}')),
        Center(child: Text(_fmtDate(row.getCells()[4].value as String))),
        Center(child: Text(_fmtDate(row.getCells()[5].value as String))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[6].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(_fmtDateTime(row.getCells()[7].value as String)),
        ),
      ],
    );
  }
}
