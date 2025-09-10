import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grid_view/services/mating_service.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:grid_view/shared/widgets/paginated_datagrid.dart';

class MatingsScreen extends StatefulWidget {
  const MatingsScreen({super.key});

  @override
  State<MatingsScreen> createState() => _MatingsScreenState();
}

class _MatingsScreenState extends State<MatingsScreen> {
  final PaginatedGridController _controller = PaginatedGridController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
          child: PaginatedDataGrid<Map<String, dynamic>>(
            controller: _controller,
            onSortChanged: (columnName, ascending) {
              _sortField = _mapSortField(columnName);
              _sortOrder = ascending ? 'asc' : 'desc';
              _controller.reload();
            },
            columns: _gridColumns(),
            sourceBuilder: (rows) => _MatingGridSource(records: rows),
            fetchPage: (page, pageSize) async {
              final pageData = await matingService.getMatingsPage(
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
            rowHeightEstimator: (index, row) => _estimateLines(row),
          ),
        ),
      ],
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
        columnName: 'matingTag',
        width: 140,
        label: Center(child: Text('Mating Tag')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'cageTag',
        width: 140,
        label: Center(child: Text('Cage Tag')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'litterStrain',
        width: 200,
        label: Center(child: Text('Litter Strain')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'maleTag',
        width: 140,
        label: Center(child: Text('Male Tag')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'maleGenotypes',
        width: 260,
        label: Center(child: Text('Male Genotypes')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'femaleTag',
        width: 140,
        label: Center(child: Text('Female Tag')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'femaleGenotypes',
        width: 260,
        label: Center(child: Text('Female Genotypes')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'setUpDate',
        width: 140,
        label: Center(child: Text('Set Up Date')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'disbandedDate',
        width: 160,
        label: Center(child: Text('Disbanded Date')),
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
      case 'matingTag':
        return 'mating_tag';
      case 'cageTag':
        return 'cage_tag';
      case 'litterStrain':
        return 'litter_strain';
      case 'maleTag':
        return 'male_tag';
      case 'setUpDate':
        return 'set_up_date';
      case 'owner':
        return 'owner';
      case 'created':
        return 'created_date';
      case 'disbandedDate':
        return 'disbanded_date';
      default:
        return null;
    }
  }

  int _estimateLines(Map<String, dynamic> m) {
    final List<dynamic> animals =
        (m['animals'] as List<dynamic>? ?? <dynamic>[]);
    final List<Map<String, dynamic>> females = animals
        .where((a) => (a is Map && (a['sex'] ?? '') == 'F'))
        .cast<Map<String, dynamic>>()
        .toList();
    final int femaleTagLines = females
        .map((f) => (f['physicalTag'] ?? '').toString())
        .where((t) => t.isNotEmpty)
        .length;
    final int femaleGenotypeLines = females
        .map((f) => _formatGenotypes(f['genotypes'] as List<dynamic>?))
        .where((g) => g.isNotEmpty)
        .length;
    final int maxLines = femaleTagLines > femaleGenotypeLines
        ? femaleTagLines
        : femaleGenotypeLines;
    return maxLines.clamp(1, 20);
  }

  // header/body handled by SfDataGrid

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

  // Formatting is handled in row adapter helpers
}

class _MatingGridSource extends DataGridSource {
  final List<Map<String, dynamic>> records;

  _MatingGridSource({required this.records}) {
    _rows = records.map(_toGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  DataGridRow _toGridRow(Map<String, dynamic> m) {
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
    final List<Map<String, dynamic>> females = animals
        .where((a) => (a is Map && (a['sex'] ?? '') == 'F'))
        .cast<Map<String, dynamic>>()
        .toList();
    final String maleTag = (male?['physicalTag'] ?? '').toString();
    final List<String> femaleTags = females
        .map((f) => (f['physicalTag'] ?? '').toString())
        .where((t) => t.isNotEmpty)
        .toList();
    final String maleGenotypes = _fmtGenotypes(
      male?['genotypes'] as List<dynamic>?,
    );
    final List<String> femaleGenotypeLines = females
        .map((f) => _fmtGenotypes(f['genotypes'] as List<dynamic>?))
        .where((g) => g.isNotEmpty)
        .toList();
    final String setUpDate = (m['setUpDate'] ?? '').toString();
    final String disbandedDate = (m['disbandedDate'] ?? '').toString();
    final String owner =
        (m['owner']?['user']?['email'] ??
                m['owner']?['user']?['username'] ??
                '')
            .toString();
    final String created = (m['createdDate'] ?? '').toString();
    return DataGridRow(
      cells: [
        DataGridCell<int>(columnName: 'eid', value: eid),
        DataGridCell<String>(columnName: 'matingTag', value: matingTag),
        DataGridCell<String>(columnName: 'cageTag', value: cageTag),
        DataGridCell<String>(columnName: 'litterStrain', value: litterStrain),
        DataGridCell<String>(columnName: 'maleTag', value: maleTag),
        DataGridCell<String>(columnName: 'maleGenotypes', value: maleGenotypes),
        DataGridCell<List<String>>(columnName: 'femaleTag', value: femaleTags),
        DataGridCell<List<String>>(
          columnName: 'femaleGenotypes',
          value: femaleGenotypeLines,
        ),
        DataGridCell<String>(columnName: 'setUpDate', value: setUpDate),
        DataGridCell<String>(columnName: 'disbandedDate', value: disbandedDate),
        DataGridCell<String>(columnName: 'owner', value: owner),
        DataGridCell<String>(columnName: 'created', value: created),
      ],
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    List<String> asList(dynamic v) => (v as List<String>? ?? <String>[]);
    String fmtDate(String iso) {
      if (iso.isEmpty) return '';
      final dt = DateTime.tryParse(iso)?.toLocal();
      if (dt == null) return iso;
      return DateFormat('M/d/y').format(dt);
    }

    String fmtDateTime(String iso) {
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[3].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[4].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            row.getCells()[5].value as String,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: asList(row.getCells()[6].value)
                .map(
                  (t) => Text(t, overflow: TextOverflow.ellipsis, maxLines: 1),
                )
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: asList(row.getCells()[7].value)
                .map(
                  (g) => Text(g, overflow: TextOverflow.ellipsis, maxLines: 1),
                )
                .toList(),
          ),
        ),
        Center(child: Text(fmtDate(row.getCells()[8].value as String))),
        Center(child: Text(fmtDate(row.getCells()[9].value as String))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[10].value as String),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(fmtDateTime(row.getCells()[11].value as String)),
        ),
      ],
    );
  }

  String _fmtGenotypes(List<dynamic>? list) {
    if (list == null || list.isEmpty) return '';
    return list
        .map((g) {
          final gene = (g['gene']?['geneName'] ?? '').toString();
          final allele = (g['allele']?['alleleName'] ?? '').toString();
          return gene.isEmpty ? allele : '$gene/$allele';
        })
        .join(', ');
  }
}
