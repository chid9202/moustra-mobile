import 'package:flutter/material.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/animal_helper.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
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
          child: PaginatedDataGrid<AnimalDto>(
            controller: _controller,
            onSortChanged: (columnName, ascending) {
              _sortField = _mapSortField(columnName);
              _sortOrder = ascending ? 'asc' : 'desc';
              _controller.reload();
            },
            columns: _gridColumns(),
            sourceBuilder: (rows) => _AnimalGridSource(records: rows),
            fetchPage: (page, pageSize) async {
              final pageData = await animalService.getAnimalsPage(
                page: page,
                pageSize: pageSize,
                query: {
                  if (_sortField != null) 'sort': _sortField!,
                  if (_sortField != null) 'order': _sortOrder,
                },
              );
              return PaginatedResult<AnimalDto>(
                count: pageData.count,
                results: pageData.results.cast<AnimalDto>(),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant AnimalsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
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
        columnName: 'ptag',
        width: 120,
        label: Center(child: Text('Physical Tag')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'status',
        width: 100,
        label: Center(child: Text('Status')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'sex',
        width: 80,
        label: Center(child: Text('Sex')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'dob',
        width: 140,
        label: Center(child: Text('Date of Birth')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'age',
        width: 80,
        label: Center(child: Text('Age')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'wean',
        width: 140,
        label: Center(child: Text('Wean Date')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'cage',
        width: 120,
        label: Center(child: Text('Cage Tag')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'strain',
        width: 200,
        label: Center(child: Text('Strain')),
        allowSorting: true,
      ),
      GridColumn(
        columnName: 'genotypes',
        width: 240,
        label: Center(child: Text('Genotypes')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'sire',
        width: 160,
        label: Center(child: Text('Sire')),
        allowSorting: false,
      ),
      GridColumn(
        columnName: 'dam',
        width: 160,
        label: Center(child: Text('Dam')),
        allowSorting: false,
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
      case 'ptag':
        return 'physical_tag';
      case 'cage':
        return 'cage_tag';
      case 'status':
        return 'status';
      case 'sex':
        return 'sex';
      case 'dob':
        return 'date_of_birth';
      case 'wean':
        return 'wean_date';
      case 'strain':
        return 'strain';
      case 'owner':
        return 'owner';
      case 'created':
        return 'created_date';
      default:
        return null;
    }
  }

  // Data formatting now handled in DataGrid source
}

class _AnimalGridSource extends DataGridSource {
  final List<AnimalDto> records;

  _AnimalGridSource({required this.records}) {
    _rows = records.map(_toGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  DataGridRow _toGridRow(AnimalDto a) {
    final int eid = (a.eid);
    final String physicalTag = (a.physicalTag ?? '').toString();
    final String status = (a.cage?.status ?? '').toString();
    final String sex = (a.sex ?? '').toString();
    final String dob = DateTimeHelper.formatDate(a.dateOfBirth);
    final String age = AnimalHelper.getAge(a);
    final String weanDate = DateTimeHelper.formatDate(a.weanDate);
    final String cageTag = (a.cage?.cageTag ?? '').toString();
    final String strain = (a.strain?.strainName ?? '').toString();
    final String genotypes = GenotypeHelper.formatGenotypes(a.genotypes);
    final String sire = (a.sire?.physicalTag ?? '').toString();
    final String dam = GenotypeHelper.getDamNames(a.dam);
    final String owner = AccountHelper.getOwnerName(a.owner);
    final String created = DateTimeHelper.formatDateTime(a.createdDate);
    return DataGridRow(
      cells: [
        DataGridCell<int>(columnName: 'eid', value: eid),
        DataGridCell<String>(columnName: 'ptag', value: physicalTag),
        DataGridCell<String>(columnName: 'status', value: status),
        DataGridCell<String>(columnName: 'sex', value: sex),
        DataGridCell<String>(columnName: 'dob', value: dob),
        DataGridCell<String>(columnName: 'age', value: age),
        DataGridCell<String>(columnName: 'wean', value: weanDate),
        DataGridCell<String>(columnName: 'cage', value: cageTag),
        DataGridCell<String>(columnName: 'strain', value: strain),
        DataGridCell<String>(columnName: 'genotypes', value: genotypes),
        DataGridCell<String>(columnName: 'sire', value: sire),
        DataGridCell<String>(columnName: 'dam', value: dam),
        DataGridCell<String>(columnName: 'owner', value: owner),
        DataGridCell<String>(columnName: 'created', value: created),
      ],
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: [
        Center(child: Text('${row.getCells()[0].value}')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[1].value),
        ),
        Center(child: Text(row.getCells()[2].value)),
        Center(child: Text(row.getCells()[3].value)),
        Center(child: Text(row.getCells()[4].value)),
        Center(child: Text(row.getCells()[5].value)),
        Center(child: Text(row.getCells()[6].value)),
        Center(child: Text(row.getCells()[7].value)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[8].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[9].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[10].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[11].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[12].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[13].value),
        ),
      ],
    );
  }
}
