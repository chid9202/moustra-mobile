import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/animal_list_constants.dart';
import 'package:moustra/constants/list_constants/common.dart';
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
              _sortField = mapSortField(columnName as AnimalListColumn);
              _sortOrder = ascending ? SortOrder.asc.name : SortOrder.desc.name;
              _controller.reload();
            },
            columns: animalListColumns(),
            sourceBuilder: (rows) => _AnimalGridSource(records: rows),
            fetchPage: (page, pageSize) async {
              final pageData = await animalService.getAnimalsPage(
                page: page,
                pageSize: pageSize,
                query: {
                  if (_sortField != null)
                    SortQueryParamKey.sort.name: _sortField!,
                  if (_sortField != null)
                    SortQueryParamKey.order.name: _sortOrder,
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

  String? _sortField;
  String _sortOrder = SortOrder.asc.name;
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
    return DataGridRow(
      cells: [
        DataGridCell<int>(columnName: AnimalListColumn.eid.name, value: a.eid),
        DataGridCell<String>(
          columnName: AnimalListColumn.physicalTag.name,
          value: a.physicalTag,
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.status.name,
          value: a.cage?.status,
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.sex.name,
          value: a.sex,
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.dob.name,
          value: DateTimeHelper.formatDate(a.dateOfBirth),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.age.name,
          value: AnimalHelper.getAge(a),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.wean.name,
          value: DateTimeHelper.formatDate(a.weanDate),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.cage.name,
          value: a.cage?.cageTag,
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.strain.name,
          value: a.strain?.strainName,
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.genotypes.name,
          value: GenotypeHelper.formatGenotypes(a.genotypes),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.sire.name,
          value: a.sire?.physicalTag,
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.dam.name,
          value: GenotypeHelper.getDamNames(a.dam),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.owner.name,
          value: AccountHelper.getOwnerName(a.owner),
        ),
        DataGridCell<String>(
          columnName: AnimalListColumn.created.name,
          value: DateTimeHelper.formatDateTime(a.createdDate),
        ),
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
