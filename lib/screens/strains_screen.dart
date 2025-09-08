import 'package:flutter/material.dart';
import 'package:grid_view/services/strain_service.dart';
import 'package:intl/intl.dart';

class StrainsScreen extends StatefulWidget {
  const StrainsScreen({super.key});

  @override
  State<StrainsScreen> createState() => _StrainsScreenState();
}

class _StrainsScreenState extends State<StrainsScreen> {
  late Future<List<dynamic>> _future;
  List<Map<String, dynamic>> _all = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _filtered = <Map<String, dynamic>>[];
  final TextEditingController _filterController = TextEditingController();
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ScrollController _hHeader = ScrollController();
  final ScrollController _hBody = ScrollController();
  bool _isSyncingScroll = false;
  int _currentPage = 0; // zero-based UI page
  int _pageSize = 25;
  int _totalCount = 0;
  final Set<String> _selected = <String>{};

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
    _filterController.dispose();
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
            child: Text('Failed to load strains: ${snapshot.error}'),
          );
        }
        final data = snapshot.data ?? const [];
        if (_all.isEmpty && data.isNotEmpty) {
          _all = data.cast<Map<String, dynamic>>();
          _filtered = List<Map<String, dynamic>>.from(_all);
        }
        if (_filtered.isEmpty) {
          return const Center(child: Text('No strains found'));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Create Strain clicked'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Strain'),
                    ),
                    FilledButton.icon(
                      onPressed: _selected.length >= 2 ? _mergeSelected : null,
                      icon: const Icon(Icons.merge_type),
                      label: const Text('Merge Strain'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _filterController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Filter strains',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _applyFilter(value);
                },
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: Column(
                  children: [
                    // Fixed header (no rows)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _hHeader,
                      physics: const NeverScrollableScrollPhysics(),
                      child: DataTable(
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        columns: _buildColumns(),
                        rows: const <DataRow>[],
                      ),
                    ),
                    const Divider(height: 1),
                    // Scrollable body
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _hBody,
                          child: DataTable(
                            sortColumnIndex: _sortColumnIndex,
                            sortAscending: _sortAscending,
                            headingRowHeight: 0,
                            columns: _buildColumns(),
                            rows: _pageItems().map(_buildRow).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                        ? () {
                            _goToPage(_currentPage - 1);
                          }
                        : null,
                  ),
                  Text(
                    'Page ${_currentPage + 1} of ${_pageCount()} (Total: $_totalCount)',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next',
                    onPressed: (_currentPage + 1) < _pageCount()
                        ? () {
                            _goToPage(_currentPage + 1);
                          }
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

  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(label: SizedBox(width: 56, child: Text(''))),
      const DataColumn(label: SizedBox(width: 72, child: Text('Edit'))),
      DataColumn(
        label: const SizedBox(width: 240, child: Text('Strain Name')),
        onSort: (columnIndex, ascending) {
          _sort<String>(
            columnIndex,
            ascending,
            (e) => (e['strainName'] ?? '').toString(),
          );
        },
      ),
      DataColumn(
        label: const SizedBox(width: 100, child: Text('# Animals')),
        numeric: true,
        onSort: (columnIndex, ascending) {
          _sort<num>(
            columnIndex,
            ascending,
            (e) => (e['numberOfAnimals'] ?? 0) as num,
          );
        },
      ),
      const DataColumn(label: SizedBox(width: 80, child: Text('Color'))),
      const DataColumn(label: SizedBox(width: 220, child: Text('Owner'))),
      DataColumn(
        label: const SizedBox(width: 180, child: Text('Created Date')),
        onSort: (columnIndex, ascending) {
          _sortBy(
            columnIndex,
            ascending,
            (e) => DateTime.tryParse((e['createdDate'] ?? '').toString()),
          );
        },
      ),
      const DataColumn(label: SizedBox(width: 200, child: Text('Background'))),
      DataColumn(
        label: const SizedBox(width: 100, child: Text('Active')),
        onSort: (columnIndex, ascending) {
          _sort<int>(
            columnIndex,
            ascending,
            (e) => ((e['isActive'] ?? false) as bool) ? 1 : 0,
          );
        },
      ),
    ];
  }

  DataRow _buildRow(Map<String, dynamic> strain) {
    final String name = (strain['strainName'] ?? '').toString();
    final int animals = (strain['numberOfAnimals'] ?? 0) as int;
    final String color = (strain['color'] ?? '').toString();
    final String owner =
        (strain['owner']?['user']?['email'] ??
                strain['owner']?['user']?['username'] ??
                '')
            .toString();
    final String created = (strain['createdDate'] ?? '').toString();
    final String background = _firstBackgroundName(strain);
    final bool active = (strain['isActive'] ?? false) as bool;
    final String uuid = (strain['strainUuid'] ?? '').toString();
    final bool isChecked = _selected.contains(uuid);

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 56,
            child: Checkbox(
              value: isChecked,
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selected.add(uuid);
                  } else {
                    _selected.remove(uuid);
                  }
                });
              },
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 72,
            child: IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Edit clicked')));
                }
              },
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 240,
            child: Text(name.isEmpty ? 'Unnamed strain' : name),
          ),
        ),
        DataCell(SizedBox(width: 100, child: Text('$animals'))),
        DataCell(
          SizedBox(
            width: 80,
            child: Center(child: _ColorSwatch(hex: color)),
          ),
        ),
        DataCell(SizedBox(width: 220, child: Text(owner))),
        DataCell(SizedBox(width: 180, child: Text(_formatUsDateTime(created)))),
        DataCell(SizedBox(width: 200, child: Text(background))),
        DataCell(
          SizedBox(
            width: 100,
            child: Icon(
              active ? Icons.check_circle : Icons.cancel,
              color: active ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  void _applyFilter(String term) {
    final query = term.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filtered = List<Map<String, dynamic>>.from(_all);
        _currentPage = 0;
      });
      return;
    }
    setState(() {
      _filtered = _all.where((e) {
        final name = (e['strainName'] ?? '').toString().toLowerCase();
        final uuid = (e['strainUuid'] ?? '').toString().toLowerCase();
        return name.contains(query) || uuid.contains(query);
      }).toList();
      _currentPage = 0;
    });
  }

  void _sort<T extends Comparable<Object?>>(
    int columnIndex,
    bool ascending,
    T Function(Map<String, dynamic> e) selector,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _filtered.sort((a, b) {
        final T av = selector(a);
        final T bv = selector(b);
        final int comp = av.compareTo(bv);
        return ascending ? comp : -comp;
      });
      _currentPage = 0;
    });
  }

  void _sortBy(
    int columnIndex,
    bool ascending,
    Comparable<Object?>? Function(Map<String, dynamic> e) selector,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _filtered.sort((a, b) {
        final Comparable<Object?>? av = selector(a);
        final Comparable<Object?>? bv = selector(b);
        int comp;
        if (av == null && bv == null)
          comp = 0;
        else if (av == null)
          comp = -1;
        else if (bv == null)
          comp = 1;
        else
          comp = av.compareTo(bv);
        return ascending ? comp : -comp;
      });
      _currentPage = 0;
    });
  }

  String _formatUsDateTime(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('M/d/y, h:mm:ss a').format(dt);
  }

  String _firstBackgroundName(Map<String, dynamic> strain) {
    final List<dynamic> bgs = (strain['backgrounds'] as List<dynamic>? ?? []);
    if (bgs.isEmpty) return '';
    final Map<String, dynamic> first = bgs.first as Map<String, dynamic>;
    return (first['name'] ?? '').toString();
  }

  int _pageCount() {
    if (_totalCount <= 0) return 1;
    return (_totalCount + _pageSize - 1) ~/ _pageSize;
  }

  List<Map<String, dynamic>> _pageItems() {
    // When server-paging, _filtered already contains current page only
    return _filtered;
  }

  Future<List<dynamic>> _fetchPage(int zeroBasedPage) async {
    final page = zeroBasedPage + 1;
    final pageData = await strainService.getStrainsPage(
      page: page,
      pageSize: _pageSize,
    );
    _totalCount = pageData.count;
    final list = pageData.results.cast<Map<String, dynamic>>();
    _all = list;
    _filtered = List<Map<String, dynamic>>.from(list);
    return list;
  }

  Future<void> _goToPage(int zeroBasedPage) async {
    setState(() {
      _currentPage = zeroBasedPage;
    });
    final data = await _fetchPage(zeroBasedPage);
    if (!mounted) return;
    setState(() {
      _all = data.cast<Map<String, dynamic>>();
      _filtered = List<Map<String, dynamic>>.from(_all);
      _selected.clear();
    });
  }

  Future<void> _mergeSelected() async {
    final strains = _selected.toList();
    try {
      await strainService.mergeStrains(strains);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Merged ${strains.length} strains.')),
      );
      _selected.clear();
      await _goToPage(_currentPage);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Merge failed: $e')));
    }
  }
}

class _ColorSwatch extends StatelessWidget {
  final String hex;
  const _ColorSwatch({required this.hex});

  Color? _parseHex(String value) {
    if (value.isEmpty) return null;
    var v = value.trim();
    if (v.startsWith('#')) v = v.substring(1);
    if (v.length == 6) v = 'FF$v';
    if (v.length != 8) return null;
    final int? n = int.tryParse(v, radix: 16);
    if (n == null) return null;
    return Color(n);
  }

  @override
  Widget build(BuildContext context) {
    final c = _parseHex(hex) ?? Colors.transparent;
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: c,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
