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
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _future = strainService.getStrains();
  }

  @override
  void dispose() {
    _filterController.dispose();
    _horizontalController.dispose();
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
                      controller: _horizontalController,
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
                          controller: _horizontalController,
                          child: DataTable(
                            sortColumnIndex: _sortColumnIndex,
                            sortAscending: _sortAscending,
                            headingRowHeight: 0,
                            columns: _buildColumns(),
                            rows: _filtered.map(_buildRow).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<DataColumn> _buildColumns() {
    return [
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
        label: const Text('# Animals'),
        numeric: true,
        onSort: (columnIndex, ascending) {
          _sort<num>(
            columnIndex,
            ascending,
            (e) => (e['numberOfAnimals'] ?? 0) as num,
          );
        },
      ),
      const DataColumn(label: Text('Color')),
      const DataColumn(label: Text('Owner')),
      DataColumn(
        label: const Text('Created Date'),
        onSort: (columnIndex, ascending) {
          _sortBy(
            columnIndex,
            ascending,
            (e) => DateTime.tryParse((e['createdDate'] ?? '').toString()),
          );
        },
      ),
      const DataColumn(label: Text('Background')),
      DataColumn(
        label: const Text('Active'),
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

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 240,
            child: Text(name.isEmpty ? 'Unnamed strain' : name),
          ),
        ),
        DataCell(Text('$animals')),
        DataCell(_ColorSwatch(hex: color)),
        DataCell(Text(owner)),
        DataCell(Text(_formatUsDateTime(created))),
        DataCell(Text(background)),
        DataCell(
          Icon(
            active ? Icons.check_circle : Icons.cancel,
            color: active ? Colors.green : Colors.red,
            size: 18,
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
      });
      return;
    }
    setState(() {
      _filtered = _all.where((e) {
        final name = (e['strainName'] ?? '').toString().toLowerCase();
        final uuid = (e['strainUuid'] ?? '').toString().toLowerCase();
        return name.contains(query) || uuid.contains(query);
      }).toList();
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
