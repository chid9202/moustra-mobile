import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/animal_list_constants.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/widgets/safe_text.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:moustra/widgets/shared/button.dart';

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
                MoustraButton.icon(
                  onPressed: () {
                    context.go('/animals/new');
                  },
                  icon: Icons.add,
                  label: 'Create Animals',
                ),
                MoustraButton.icon(
                  onPressed: () {},
                  icon: Icons.stop_circle_outlined,
                  label: 'End Animal',
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PaginatedDataGrid<AnimalDto>(
            controller: _controller,
            onSortChanged: (columnName, ascending) {
              _sortField = columnName;
              _sortOrder = ascending ? SortOrder.asc.name : SortOrder.desc.name;
              _controller.reload();
            },
            columns: AnimalListColumn.getColumns(),
            sourceBuilder: (rows) =>
                _AnimalGridSource(records: rows, context: context),
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
  final BuildContext context;

  _AnimalGridSource({required this.records, required this.context}) {
    _rows = records.map(AnimalListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final String uuid = row.getCells()[0].value as String;
    return DataGridRowAdapter(
      cells: [
        Center(
          child: IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              context.go('/animals/$uuid');
            },
          ),
        ),
        Center(child: SafeText('${row.getCells()[1].value}')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[2].value),
        ),
        Center(child: SafeText(row.getCells()[3].value)),
        Center(child: SafeText(row.getCells()[4].value)),
        Center(child: SafeText(row.getCells()[5].value)),
        Center(child: SafeText(row.getCells()[6].value)),
        Center(child: SafeText(row.getCells()[7].value)),
        Center(child: SafeText(row.getCells()[8].value)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[9].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[10].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[11].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[12].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[13].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[14].value),
        ),
      ],
    );
  }
}
