import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grid_view/services/cage_service.dart';

class CagesListScreen extends StatefulWidget {
  const CagesListScreen({super.key});

  @override
  State<CagesListScreen> createState() => _CagesListScreenState();
}

class _CagesListScreenState extends State<CagesListScreen> {
  final ScrollController _hHeader = ScrollController();
  final ScrollController _hBody = ScrollController();
  bool _isSyncingScroll = false;
  late Future<List<dynamic>> _future;
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  int _currentPage = 0; // zero-based
  final int _pageSize = 25;
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
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _hHeader,
                    physics: const NeverScrollableScrollPhysics(),
                    child: _buildHeader(),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _hBody,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _rows.map(_buildBodyRow).toList(),
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
      DataColumn(label: SizedBox(width: 140, child: Text('Cage Tag'))),
      DataColumn(label: SizedBox(width: 200, child: Text('Strain'))),
      DataColumn(label: SizedBox(width: 140, child: Text('Number of Animals'))),
      DataColumn(label: SizedBox(width: 240, child: Text('Animal Tags'))),
      DataColumn(label: SizedBox(width: 260, child: Text('Genotypes'))),
      DataColumn(label: SizedBox(width: 120, child: Text('Status'))),
      DataColumn(label: SizedBox(width: 220, child: Text('Owner'))),
      DataColumn(label: SizedBox(width: 180, child: Text('Created Date'))),
    ];
  }

  DataRow _row(Map<String, dynamic> c) {
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
        .map((a) => _formatGenotypesForAnimal(a['genotypes'] as List<dynamic>?))
        .where((g) => g.isNotEmpty)
        .toList();
    final String status = (c['status'] ?? '').toString();
    final String owner =
        (c['owner']?['user']?['email'] ??
                c['owner']?['user']?['username'] ??
                '')
            .toString();
    final String created = (c['createdDate'] ?? '').toString();
    return DataRow(
      cells: [
        DataCell(SizedBox(width: 80, child: Text('$eid'))),
        DataCell(SizedBox(width: 140, child: Text(cageTag))),
        DataCell(SizedBox(width: 200, child: Text(strain))),
        DataCell(SizedBox(width: 140, child: Text('$numAnimals'))),
        DataCell(
          SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: animalTagLines.map((t) => Text(t)).toList(),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: animalGenotypeLines.map((g) => Text(g)).toList(),
            ),
          ),
        ),
        DataCell(SizedBox(width: 120, child: Text(status))),
        DataCell(SizedBox(width: 220, child: Text(owner))),
        DataCell(SizedBox(width: 180, child: Text(_formatDateTime(created)))),
      ],
    );
  }

  Widget _buildHeader() {
    return DataTable(
      dataRowMaxHeight: double.infinity,
      columns: _columns(),
      rows: const <DataRow>[],
    );
  }

  Widget _buildBodyRow(Map<String, dynamic> c) {
    final int eid = (c['eid'] ?? 0) as int;
    final String cageTag = (c['cageTag'] ?? '').toString();
    final String strain = (c['strain']?['strainName'] ?? '').toString();
    final List<dynamic> animals =
        (c['animals'] as List<dynamic>? ?? <dynamic>[]);
    final int numAnimals = animals.length;
    final List<String> animalTagLines = animals
        .map((a) => (a['physicalTag'] ?? '').toString())
        .toList();
    final List<String> animalGenotypeLines = animals
        .map((a) => _formatGenotypesForAnimal(a['genotypes'] as List<dynamic>?))
        .toList();
    final String status = (c['status'] ?? '').toString();
    final String owner =
        (c['owner']?['user']?['email'] ??
                c['owner']?['user']?['username'] ??
                '')
            .toString();
    final String created = (c['createdDate'] ?? '').toString();

    return DataTable(
      headingRowHeight: 0,
      dataRowMaxHeight: double.infinity,
      columns: _columns(),
      rows: [
        DataRow(
          cells: [
            DataCell(SizedBox(width: 80, child: Text('$eid'))),
            DataCell(SizedBox(width: 140, child: Text(cageTag))),
            DataCell(SizedBox(width: 200, child: Text(strain))),
            DataCell(SizedBox(width: 140, child: Text('$numAnimals'))),
            DataCell(
              SizedBox(
                width: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: animalTagLines
                      .map(
                        (t) => Text(
                          t,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            DataCell(
              SizedBox(
                width: 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: animalGenotypeLines
                      .map(
                        (g) => Text(
                          g,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            DataCell(SizedBox(width: 120, child: Text(status))),
            DataCell(SizedBox(width: 220, child: Text(owner))),
            DataCell(
              SizedBox(width: 180, child: Text(_formatDateTime(created))),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateTime(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('M/d/y, h:mm:ss a').format(dt);
  }

  String _formatGenotypesForAnimal(List<dynamic>? list) {
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
