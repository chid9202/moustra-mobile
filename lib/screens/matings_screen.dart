import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grid_view/services/mating_service.dart';

class MatingsScreen extends StatefulWidget {
  const MatingsScreen({super.key});

  @override
  State<MatingsScreen> createState() => _MatingsScreenState();
}

class _MatingsScreenState extends State<MatingsScreen> {
  final ScrollController _hHeader = ScrollController();
  final ScrollController _hBody = ScrollController();
  bool _isSyncingScroll = false;
  late Future<List<dynamic>> _future;
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  int _currentPage = 0; // zero-based
  int _pageSize = 25;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _future = _fetchPage(0);
    _hBody.addListener(() {
      if (_isSyncingScroll) return;
      if (_hHeader.hasClients && _hHeader.offset != _hBody.offset) {
        _isSyncingScroll = true;
        try {
          _hHeader.jumpTo(_hBody.offset);
        } finally {
          _isSyncingScroll = false;
        }
      }
    });
    _hHeader.addListener(() {
      if (_isSyncingScroll) return;
      if (_hBody.hasClients && _hBody.offset != _hHeader.offset) {
        _isSyncingScroll = true;
        try {
          _hBody.jumpTo(_hHeader.offset);
        } finally {
          _isSyncingScroll = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _hHeader.dispose();
    _hBody.dispose();
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
            child: Text('Failed to load matings: ${snapshot.error}'),
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
                      const SnackBar(content: Text('Add Mating clicked')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Mating'),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _hHeader,
                    physics: const NeverScrollableScrollPhysics(),
                    child: DataTable(
                      columns: _columns(),
                      rows: const <DataRow>[],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _hBody,
                        child: DataTable(
                          headingRowHeight: 0,
                          columns: _columns(),
                          rows: _rows.map(_row).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
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

  List<DataColumn> _columns() {
    return const [
      DataColumn(label: SizedBox(width: 80, child: Text('EID'))),
      DataColumn(label: SizedBox(width: 140, child: Text('Mating Tag'))),
      DataColumn(label: SizedBox(width: 140, child: Text('Cage Tag'))),
      DataColumn(label: SizedBox(width: 200, child: Text('Litter Strain'))),
      DataColumn(label: SizedBox(width: 140, child: Text('Male Tag'))),
      DataColumn(label: SizedBox(width: 260, child: Text('Male Genotypes'))),
      DataColumn(label: SizedBox(width: 140, child: Text('Female Tag'))),
      DataColumn(label: SizedBox(width: 260, child: Text('Female Genotypes'))),
      DataColumn(label: SizedBox(width: 140, child: Text('Set Up Date'))),
      DataColumn(label: SizedBox(width: 220, child: Text('Owner'))),
      DataColumn(label: SizedBox(width: 180, child: Text('Created Date'))),
    ];
  }

  DataRow _row(Map<String, dynamic> m) {
    final int eid = (m['eid'] ?? 0) as int;
    final String matingTag = (m['matingTag'] ?? '').toString();
    final String cageTag = (m['cage']?['cageTag'] ?? '').toString();
    final String litterStrain = (m['litterStrain']?['strainName'] ?? '')
        .toString();
    final List<dynamic> animals =
        (m['animals'] as List<dynamic>? ?? <dynamic>[]);
    final Map<String, dynamic>? male = animals
        .cast<Map<String, dynamic>?>()
        .firstWhere((a) => (a?['sex'] ?? '') == 'M', orElse: () => null);
    final Map<String, dynamic>? female = animals
        .cast<Map<String, dynamic>?>()
        .firstWhere((a) => (a?['sex'] ?? '') == 'F', orElse: () => null);
    final String maleTag = (male?['physicalTag'] ?? '').toString();
    final String femaleTag = (female?['physicalTag'] ?? '').toString();
    final String maleGenotypes = _formatGenotypes(
      male?['genotypes'] as List<dynamic>?,
    );
    final String femaleGenotypes = _formatGenotypes(
      female?['genotypes'] as List<dynamic>?,
    );
    final String setUpDate = (m['setUpDate'] ?? '').toString();
    final String owner =
        (m['owner']?['user']?['email'] ??
                m['owner']?['user']?['username'] ??
                '')
            .toString();
    final String created = (m['createdDate'] ?? '').toString();
    return DataRow(
      cells: [
        DataCell(SizedBox(width: 80, child: Text('$eid'))),
        DataCell(SizedBox(width: 140, child: Text(matingTag))),
        DataCell(SizedBox(width: 140, child: Text(cageTag))),
        DataCell(SizedBox(width: 200, child: Text(litterStrain))),
        DataCell(SizedBox(width: 140, child: Text(maleTag))),
        DataCell(SizedBox(width: 260, child: Text(maleGenotypes))),
        DataCell(SizedBox(width: 140, child: Text(femaleTag))),
        DataCell(SizedBox(width: 260, child: Text(femaleGenotypes))),
        DataCell(SizedBox(width: 140, child: Text(_formatDate(setUpDate)))),
        DataCell(SizedBox(width: 220, child: Text(owner))),
        DataCell(SizedBox(width: 180, child: Text(_formatDateTime(created)))),
      ],
    );
  }

  String _formatGenotypes(List<dynamic>? list) {
    if (list == null || list.isEmpty) return '';
    return list
        .map((g) {
          final gene = (g['gene']?['geneName'] ?? '').toString();
          final allele = (g['allele']?['alleleName'] ?? '').toString();
          return gene.isEmpty ? allele : '$gene/$allele';
        })
        .join(', ');
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('M/d/y').format(dt);
  }

  String _formatDateTime(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('M/d/y, h:mm:ss a').format(dt);
  }

  int _pageCount() {
    if (_totalCount <= 0) return 1;
    return (_totalCount + _pageSize - 1) ~/ _pageSize;
  }

  Future<List<dynamic>> _fetchPage(int zeroBasedPage) async {
    final pageData = await matingService.getMatingsPage(
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
