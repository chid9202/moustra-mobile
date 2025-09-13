import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/litter_service.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';

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
    return PaginatedDataGrid<LitterDto>(
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
        return PaginatedResult<LitterDto>(
          count: pageData.count,
          results: pageData.results.cast<LitterDto>(),
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
  final List<LitterDto> records;

  _LitterGridSource({required this.records}) {
    _rows = records.map(_toGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  DataGridRow _toGridRow(LitterDto litter) {
    final int eid = (litter.eid);
    final String tag = (litter.litterTag).toString();
    final String strain = (litter.mating.litterStrain?.strainName ?? '')
        .toString();
    final List<dynamic> pups = (litter.animals);
    final int numPups = pups.length;
    final String weanDate = (litter.weanDate).toString();
    final String dob = (litter.dateOfBirth).toString();
    final String owner =
        (litter.owner.user?.email ?? litter.owner.user?.username ?? '');
    final String created = (litter.createdDate).toString();
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
    String fmtDate(String iso) {
      // TODO: move to helper
      if (iso.isEmpty) return '';
      final dt = DateTime.tryParse(iso)?.toLocal();
      if (dt == null) return iso;
      return DateFormat('M/d/y').format(dt);
    }

    String fmtDateTime(String iso) {
      // TODO: move to helper
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
        Center(child: Text(fmtDate(row.getCells()[4].value as String))),
        Center(child: Text(fmtDate(row.getCells()[5].value as String))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[6].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(fmtDateTime(row.getCells()[7].value as String)),
        ),
      ],
    );
  }
}
