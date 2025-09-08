import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grid_view/services/litter_service.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:grid_view/shared/widgets/paginated_datagrid.dart';

class LittersScreen extends StatefulWidget {
  const LittersScreen({super.key});

  @override
  State<LittersScreen> createState() => _LittersScreenState();
}

class _LittersScreenState extends State<LittersScreen> {
  final PaginatedGridController _controller = PaginatedGridController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedDataGrid<Map<String, dynamic>>(
      controller: _controller,
      onSortChanged: (columnName, ascending) {
        _sortField = _mapSortField(columnName);
        _sortOrder = ascending ? 'asc' : 'desc';
        _controller.reload();
      },
      columns: _gridColumns(),
      sourceBuilder: (rows) => _LitterGridSource(records: rows),
      fetchPage: (page, pageSize) async {
        final pageData = await litterService.getLittersPage(
          page: page,
          pageSize: pageSize,
          query: {
            if (_sortField != null) 'sort': _sortField!,
            if (_sortField != null) 'order': _sortOrder,
          },
        );
        return PaginatedResult<Map<String, dynamic>>(
          count: pageData.count,
          results: pageData.results.cast<Map<String, dynamic>>(),
        );
      },
      topBar: ElevatedButton.icon(
        onPressed: () {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Add Litter clicked')));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Litter'),
      ),
    );
  }

  List<GridColumn> _gridColumns() {
    return [
      GridColumn(
        columnName: 'eid',
        width: 80,
        label: Center(child: Text('EID')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'tag',
        width: 140,
        label: Center(child: Text('Litter Tag')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'strain',
        width: 200,
        label: Center(child: Text('Litter Strain')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'num',
        width: 160,
        label: Center(child: Text('Number of Pups')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'wean',
        width: 140,
        label: Center(child: Text('Wean Date')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'dob',
        width: 160,
        label: Center(child: Text('Date of Birth')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'owner',
        width: 220,
        label: Center(child: Text('Owner')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'created',
        width: 180,
        label: Center(child: Text('Created Date')),
        allowSorting: true,
      ),
    ];
  }

  String? _sortField;
  String _sortOrder = 'asc';
  String? _mapSortField(String columnName) {
    switch (columnName) {
      case 'tag':
        return 'litter_tag';
      case 'strain':
        return 'litter_strain';
      case 'wean':
        return 'wean_date';
      case 'dob':
        return 'date_of_birth';
      case 'owner':
        return 'owner';
      case 'created':
        return 'created_date';
      default:
        return null;
    }
  }

  // header/body rendering handled by DataGrid
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
