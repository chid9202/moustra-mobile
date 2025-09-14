import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/clients/litter_api.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/datetime_helper.dart';
import 'package:moustra/constants/list_constants/litter_list_constants.dart';
import 'package:moustra/widgets/safe_text.dart';
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
        _sortField = columnName;
        _sortOrder = ascending ? SortOrder.asc.name : SortOrder.desc.name;
        _controller.reload();
      },
      columns: litterListColumns(),
      sourceBuilder: (rows) => _LitterGridSource(records: rows),
      fetchPage: (page, pageSize) async {
        final pageData = await litterService.getLittersPage(
          page: page,
          pageSize: pageSize,
          query: {
            if (_sortField != null) SortQueryParamKey.sort.name: _sortField!,
            if (_sortField != null) SortQueryParamKey.order.name: _sortOrder,
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

  String? _sortField;
  String _sortOrder = SortOrder.asc.name;
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
    final List<LitterAnimalDto>? pups = (litter.animals);
    final int numPups = pups?.length ?? 0;
    final String weanDate = DateTimeHelper.formatDate(litter.weanDate);
    final String dob = DateTimeHelper.formatDate(litter.dateOfBirth);
    final String owner = AccountHelper.getOwnerName(litter.owner);
    final String created = DateTimeHelper.formatDateTime(litter.createdDate);
    return DataGridRow(
      cells: [
        DataGridCell<int>(columnName: LitterListColumn.eid.name, value: eid),
        DataGridCell<String>(
          columnName: LitterListColumn.litterTag.name,
          value: tag,
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.litterStrain.name,
          value: strain,
        ),
        DataGridCell<int>(
          columnName: LitterListColumn.numberOfPups.name,
          value: numPups,
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.wean.name,
          value: weanDate,
        ),
        DataGridCell<String>(columnName: LitterListColumn.dob.name, value: dob),
        DataGridCell<String>(
          columnName: LitterListColumn.owner.name,
          value: owner,
        ),
        DataGridCell<String>(
          columnName: LitterListColumn.created.name,
          value: created,
        ),
      ],
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
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
        Center(child: SafeText('${row.getCells()[3].value}')),
        Center(child: SafeText(row.getCells()[4].value)),
        Center(child: SafeText(row.getCells()[5].value)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[6].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SafeText(row.getCells()[7].value),
        ),
      ],
    );
  }
}
