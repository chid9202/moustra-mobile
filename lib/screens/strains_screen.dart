import 'package:flutter/material.dart';
import 'package:moustra/services/strain_service.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';

class StrainsScreen extends StatefulWidget {
  const StrainsScreen({super.key});

  @override
  State<StrainsScreen> createState() => _StrainsScreenState();
}

class _StrainsScreenState extends State<StrainsScreen> {
  final PaginatedGridController _controller = PaginatedGridController();
  List<Map<String, dynamic>> _all = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _filtered = <Map<String, dynamic>>[];
  final TextEditingController _filterController = TextEditingController();
  String? _sortColumn; // api field, e.g., strain_name
  String _sortOrder = 'asc';
  // Sorting handled by grid; legacy fields removed
  // Paging handled by PaginatedDataGrid; keep UI page index for filter reset
  int _currentPage = 0;
  final Set<String> _selected = <String>{};

  @override
  void initState() {
    super.initState();
    _goToPage(0);
  }

  @override
  void dispose() {
    _filterController.dispose();
    // No controllers to dispose
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
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Create Strain clicked')),
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
              _controller.reload();
            },
          ),
        ),
        Expanded(
          child: PaginatedDataGrid<Map<String, dynamic>>(
            controller: _controller,
            onSortChanged: (columnName, ascending) {
              // Map grid column names to API fields
              if (columnName == 'name') {
                _sortColumn = 'strain_name';
              } else if (columnName == 'created') {
                _sortColumn = 'created_date';
              } else if (columnName == 'owner') {
                _sortColumn = 'owner';
              } else if (columnName == 'animals') {
                _sortColumn = 'number_of_animals';
              } else {
                _sortColumn = null;
              }
              _sortOrder = ascending ? 'asc' : 'desc';
              _controller.reload();
            },
            columns: _gridColumns(),
            sourceBuilder: (rows) => _StrainGridSource(
              records: rows,
              selected: _selected,
              onToggle: _onToggleSelected,
            ),
            fetchPage: (page, pageSize) async {
              final pageData = await strainService.getStrainsPage(
                page: page,
                pageSize: pageSize,
                query: {
                  if (_sortColumn != null) 'sort': _sortColumn!,
                  if (_sortColumn != null) 'order': _sortOrder,
                },
              );
              _all = pageData.results.cast<Map<String, dynamic>>();
              _filtered = List<Map<String, dynamic>>.from(_all);
              return PaginatedResult<Map<String, dynamic>>(
                count: pageData.count,
                results: _pageItems(),
              );
            },
          ),
        ),
      ],
    );
  }

  List<GridColumn> _gridColumns() {
    return [
      GridColumn(
        columnName: 'select',
        width: 56,
        label: const SizedBox.shrink(),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'edit',
        width: 72,
        label: const Center(child: Text('Edit')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'name',
        width: 240,
        label: const Center(child: Text('Strain Name')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'animals',
        width: 100,
        label: const Center(child: Text('# Animals')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'color',
        width: 80,
        label: const Center(child: Text('Color')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'owner',
        width: 220,
        label: const Center(child: Text('Owner')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'created',
        width: 180,
        label: const Center(child: Text('Created Date')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'background',
        width: 200,
        label: const Center(child: Text('Background')),
        allowSorting: false,
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

  // Paging handled by PaginatedDataGrid

  List<Map<String, dynamic>> _pageItems() {
    // When server-paging, _filtered already contains current page only
    return _filtered;
  }

  // Fetching is handled inside PaginatedDataGrid's fetchPage

  Future<void> _goToPage(int zeroBasedPage) async {
    setState(() {
      _currentPage = zeroBasedPage;
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
      _controller.reload();
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
