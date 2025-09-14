import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/constants/list_constants/mating_list_constants.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/clients/mating_api.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:moustra/widgets/safe_text.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';

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
          child: PaginatedDataGrid<MatingDto>(
            controller: _controller,
            onSortChanged: (columnName, ascending) {
              _sortField = columnName;
              _sortOrder = ascending ? SortOrder.asc.name : SortOrder.desc.name;
              _controller.reload();
            },
            columns: matingListColumns(),
            sourceBuilder: (rows) => _MatingGridSource(records: rows),
            fetchPage: (page, pageSize) async {
              final pageData = await matingService.getMatingsPage(
                page: page,
                pageSize: pageSize,
                query: {
                  if (_sortField != null)
                    SortQueryParamKey.sort.name: _sortField!,
                  if (_sortField != null)
                    SortQueryParamKey.order.name: _sortOrder,
                },
              );
              return PaginatedResult<MatingDto>(
                count: pageData.count,
                results: pageData.results.cast<MatingDto>(),
              );
            },
            rowHeightEstimator: (index, row) => _estimateLines(row),
          ),
        ),
      ],
    );
  }

  String? _sortField;
  String _sortOrder = SortOrder.asc.name;

  int _estimateLines(MatingDto m) {
    final List<AnimalSummaryDto> animals =
        (m.animals as List<AnimalSummaryDto>? ?? <AnimalSummaryDto>[]);
    final List<AnimalSummaryDto> females = animals
        .where((a) => (a.sex ?? '') == 'F') // TODO: use constants
        .cast<AnimalSummaryDto>()
        .toList();
    final int femaleTagLines = females
        .map((f) => (f.physicalTag ?? '').toString())
        .where((t) => t.isNotEmpty)
        .length;
    final int femaleGenotypeLines = females
        .map((f) => GenotypeHelper.formatGenotypes(f.genotypes))
        .where((g) => g.isNotEmpty)
        .length;
    final int maxLines = femaleTagLines > femaleGenotypeLines
        ? femaleTagLines
        : femaleGenotypeLines;
    return maxLines.clamp(1, 20);
  }
}

class _MatingGridSource extends DataGridSource {
  final List<MatingDto> records;

  _MatingGridSource({required this.records}) {
    _rows = records.map(_toGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  DataGridRow _toGridRow(MatingDto m) {
    final int eid = (m.eid);
    final String matingTag = (m.matingTag ?? '').toString();
    final String cageTag = (m.cage?.cageTag ?? '').toString();
    final String litterStrain = (m.litterStrain?.strainName ?? '').toString();
    final List<AnimalSummaryDto> animals = m.animals;
    final AnimalSummaryDto? male = animals.cast<AnimalSummaryDto?>().firstWhere(
      (a) => (a?.sex ?? '') == 'M', // TODO: use constants
      orElse: () => null,
    );
    final List<AnimalSummaryDto> females = animals
        .where((a) => (a.sex ?? '') == 'F') // TODO: use constants
        .cast<AnimalSummaryDto>()
        .toList();
    final String maleTag = (male?.physicalTag ?? '').toString();
    final List<String> femaleTags = females
        .map((f) => (f.physicalTag ?? '').toString())
        .where((t) => t.isNotEmpty)
        .toList();
    final String maleGenotypes = GenotypeHelper.formatGenotypes(
      male?.genotypes,
    );
    final List<String> femaleGenotypeLines = females
        .map((f) => GenotypeHelper.formatGenotypes(f.genotypes))
        .where((g) => g.isNotEmpty)
        .toList();
    final String setUpDate = DateTimeHelper.formatDate(m.setUpDate);
    final String disbandedDate = DateTimeHelper.formatDate(m.disbandedDate);
    final String owner = AccountHelper.getOwnerName(m.owner);
    final String created = DateTimeHelper.formatDateTime(m.createdDate);
    return DataGridRow(
      cells: [
        DataGridCell<int>(columnName: MatingListColumn.eid.name, value: eid),
        DataGridCell<String>(
          columnName: MatingListColumn.matingTag.name,
          value: matingTag,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.cageTag.name,
          value: cageTag,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.litterStrain.name,
          value: litterStrain,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.maleTag.name,
          value: maleTag,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.maleGenotypes.name,
          value: maleGenotypes,
        ),
        DataGridCell<List<String>>(
          columnName: MatingListColumn.femaleTag.name,
          value: femaleTags,
        ),
        DataGridCell<List<String>>(
          columnName: MatingListColumn.femaleGenotypes.name,
          value: femaleGenotypeLines,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.setUpDate.name,
          value: setUpDate,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.disbandedDate.name,
          value: disbandedDate,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.owner.name,
          value: owner,
        ),
        DataGridCell<String>(
          columnName: MatingListColumn.created.name,
          value: created,
        ),
      ],
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    List<String> asList(dynamic v) => (v as List<String>? ?? <String>[]);

    return DataGridRowAdapter(
      cells: [
        Center(child: SafeText('${row.getCells()[0].value}')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[1].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[2].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[3].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[4].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(
            row.getCells()[5].value,
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
                  (t) =>
                      SafeText(t, overflow: TextOverflow.ellipsis, maxLines: 1),
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
                  (g) =>
                      SafeText(g, overflow: TextOverflow.ellipsis, maxLines: 1),
                )
                .toList(),
          ),
        ),
        Center(child: SafeText(row.getCells()[8].value)),
        Center(child: Text(row.getCells()[9].value)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[10].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[11].value),
        ),
      ],
    );
  }
}
