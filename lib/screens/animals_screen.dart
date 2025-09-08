import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grid_view/services/animal_service.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  final ScrollController _hHeader = ScrollController();
  final ScrollController _hBody = ScrollController();
  bool _isSyncingScroll = false;
  late Future<List<dynamic>> _future;
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  int _currentPage = 0; // zero-based
  int _pageSize = 25;
  int _totalCount = 0;
  final String _accountPath =
      '/api/v1/account/fc15ff90-0b34-4e69-8a22-9ca36bfd3b15';

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
      DataColumn(label: SizedBox(width: 120, child: Text('Physical Tag'))),
      DataColumn(label: SizedBox(width: 100, child: Text('Status'))),
      DataColumn(label: SizedBox(width: 80, child: Text('Sex'))),
      DataColumn(label: SizedBox(width: 140, child: Text('Date of Birth'))),
      DataColumn(label: SizedBox(width: 80, child: Text('Age'))),
      DataColumn(label: SizedBox(width: 140, child: Text('Wean Date'))),
      DataColumn(label: SizedBox(width: 120, child: Text('Cage Tag'))),
      DataColumn(label: SizedBox(width: 200, child: Text('Strain'))),
      DataColumn(label: SizedBox(width: 240, child: Text('Genotypes'))),
      DataColumn(label: SizedBox(width: 160, child: Text('Sire'))),
      DataColumn(label: SizedBox(width: 160, child: Text('Dam'))),
      DataColumn(label: SizedBox(width: 220, child: Text('Owner'))),
      DataColumn(label: SizedBox(width: 180, child: Text('Created Date'))),
    ];
  }

  DataRow _row(Map<String, dynamic> a) {
    final int eid = (a['eid'] ?? 0) as int;
    final String physicalTag = (a['physicalTag'] ?? '').toString();
    final String status = (a['cage']?['status'] ?? '').toString();
    final String sex = (a['sex'] ?? '').toString();
    final String dob = (a['dateOfBirth'] ?? '').toString();
    final String age = _formatAge(dob);
    final String weanDate = (a['weanDate'] ?? '').toString();
    final String cageTag = (a['cage']?['cageTag'] ?? '').toString();
    final String strain = (a['strain']?['strainName'] ?? '').toString();
    final String genotypes = _formatGenotypes(a['genotypes'] as List<dynamic>?);
    final String sire = (a['sire']?['physicalTag'] ?? '').toString();
    final String dam = _formatDam(a['dam'] as List<dynamic>?);
    final String owner =
        (a['owner']?['user']?['email'] ??
                a['owner']?['user']?['username'] ??
                '')
            .toString();
    final String created = (a['createdDate'] ?? '').toString();
    return DataRow(
      cells: [
        DataCell(SizedBox(width: 80, child: Text('$eid'))),
        DataCell(SizedBox(width: 120, child: Text(physicalTag))),
        DataCell(SizedBox(width: 100, child: Text(status))),
        DataCell(SizedBox(width: 80, child: Text(sex))),
        DataCell(SizedBox(width: 140, child: Text(_formatDate(dob)))),
        DataCell(SizedBox(width: 80, child: Text(age))),
        DataCell(SizedBox(width: 140, child: Text(_formatDate(weanDate)))),
        DataCell(SizedBox(width: 120, child: Text(cageTag))),
        DataCell(SizedBox(width: 200, child: Text(strain))),
        DataCell(SizedBox(width: 240, child: Text(genotypes))),
        DataCell(SizedBox(width: 160, child: Text(sire))),
        DataCell(SizedBox(width: 160, child: Text(dam))),
        DataCell(SizedBox(width: 220, child: Text(owner))),
        DataCell(SizedBox(width: 180, child: Text(_formatDateTime(created)))),
      ],
    );
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

  String _formatAge(String dobIso) {
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

  String _formatDam(List<dynamic>? list) {
    if (list == null || list.isEmpty) return '';
    return list
        .map((d) => (d['physicalTag'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .join(', ');
  }

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
