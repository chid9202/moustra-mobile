import 'package:flutter/material.dart';
import 'package:grid_view/services/strain_service.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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
  // Sorting handled by grid; legacy fields removed
  int _currentPage = 0; // zero-based UI page
  int _pageSize = 25;
  int _totalCount = 0;
  final Set<String> _selected = <String>{};

  @override
  void initState() {
    super.initState();
    _future = _fetchPage(0);
    // No-op
  }

  @override
  void dispose() {
    _filterController.dispose();
    // No controllers to dispose
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
              child: SfDataGrid(
                source: _StrainGridSource(
                  records: _pageItems(),
                  selected: _selected,
                  onToggle: _onToggleSelected,
                ),
                allowSorting: true,
                columns: _gridColumns(),
                selectionMode: SelectionMode.multiple,
                allowTriStateSorting: false,
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

  List<GridColumn> _gridColumns() {
    return [
      GridColumn(
        columnName: 'select',
        width: 56,
        label: const SizedBox.shrink(),
      ),
      GridColumn(
        columnName: 'edit',
        width: 72,
        label: const Center(child: Text('Edit')),
      ),
      GridColumn(
        columnName: 'name',
        width: 240,
        label: const Center(child: Text('Strain Name')),
      ),
      GridColumn(
        columnName: 'animals',
        width: 100,
        label: const Center(child: Text('# Animals')),
      ),
      GridColumn(
        columnName: 'color',
        width: 80,
        label: const Center(child: Text('Color')),
      ),
      GridColumn(
        columnName: 'owner',
        width: 220,
        label: const Center(child: Text('Owner')),
      ),
      GridColumn(
        columnName: 'created',
        width: 180,
        label: const Center(child: Text('Created Date')),
      ),
      GridColumn(
        columnName: 'background',
        width: 200,
        label: const Center(child: Text('Background')),
      ),
      GridColumn(
        columnName: 'active',
        width: 100,
        label: const Center(child: Text('Active')),
      ),
    ];
  }

  void _onToggleSelected(String uuid, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(uuid);
      } else {
        _selected.remove(uuid);
      }
    });
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

  // Formatting handled in DataGrid source

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

class _StrainGridSource extends DataGridSource {
  final List<Map<String, dynamic>> records;
  final Set<String> selected;
  final void Function(String uuid, bool selected) onToggle;

  _StrainGridSource({
    required this.records,
    required this.selected,
    required this.onToggle,
  }) {
    _dataGridRows = records.map(_toGridRow).toList();
  }

  late List<DataGridRow> _dataGridRows;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  DataGridRow _toGridRow(Map<String, dynamic> e) {
    final String uuid = (e['strainUuid'] ?? '').toString();
    return DataGridRow(
      cells: [
        DataGridCell<String>(columnName: 'select', value: uuid),
        DataGridCell<String>(columnName: 'edit', value: uuid),
        DataGridCell<String>(
          columnName: 'name',
          value: (e['strainName'] ?? '').toString(),
        ),
        DataGridCell<int>(
          columnName: 'animals',
          value: (e['numberOfAnimals'] ?? 0) as int,
        ),
        DataGridCell<String>(
          columnName: 'color',
          value: (e['color'] ?? '').toString(),
        ),
        DataGridCell<String>(
          columnName: 'owner',
          value:
              (e['owner']?['user']?['email'] ??
                      e['owner']?['user']?['username'] ??
                      '')
                  .toString(),
        ),
        DataGridCell<String>(
          columnName: 'created',
          value: (e['createdDate'] ?? '').toString(),
        ),
        DataGridCell<String>(
          columnName: 'background',
          value: _firstBackground(e),
        ),
        DataGridCell<bool>(
          columnName: 'active',
          value: (e['isActive'] ?? false) as bool,
        ),
      ],
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final String uuid = row.getCells()[0].value as String;
    final bool isChecked = selected.contains(uuid);
    return DataGridRowAdapter(
      cells: [
        Center(
          child: Checkbox(
            value: isChecked,
            onChanged: (v) {
              onToggle(uuid, v ?? false);
            },
          ),
        ),
        Center(
          child: IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[2].value as String),
        ),
        Center(child: Text('${row.getCells()[3].value as int}')),
        Center(child: _ColorSwatch(hex: row.getCells()[4].value as String)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[5].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(_format(row.getCells()[6].value as String)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[7].value as String),
        ),
        Center(
          child: Icon(
            (row.getCells()[8].value as bool)
                ? Icons.check_circle
                : Icons.cancel,
            color: (row.getCells()[8].value as bool)
                ? Colors.green
                : Colors.red,
            size: 18,
          ),
        ),
      ],
    );
  }

  String _format(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return DateFormat('M/d/y, h:mm:ss a').format(dt);
  }

  String _firstBackground(Map<String, dynamic> strain) {
    final List<dynamic> bgs = (strain['backgrounds'] as List<dynamic>? ?? []);
    if (bgs.isEmpty) return '';
    final Map<String, dynamic> first = bgs.first as Map<String, dynamic>;
    return (first['name'] ?? '').toString();
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
