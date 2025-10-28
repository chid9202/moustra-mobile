import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/constants/list_constants/strain_list_constants.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/services/clients/strain_api.dart';
import 'package:moustra/widgets/color_picker.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:moustra/widgets/shared/button.dart';

class StrainsScreen extends StatefulWidget {
  const StrainsScreen({super.key});

  @override
  State<StrainsScreen> createState() => _StrainsScreenState();
}

class _StrainsScreenState extends State<StrainsScreen> {
  final PaginatedGridController _controller = PaginatedGridController();
  String? _sortField; // api field, e.g., strain_name
  String _sortOrder = SortOrder.asc.name;
  final Set<String> _selected = <String>{};

  @override
  void initState() {
    super.initState();
    _goToPage(0);
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
                MoustraButton.icon(
                  label: 'Create Strain',
                  icon: Icons.add,
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    if (context.mounted) {
                      context.go('/strains/new');
                    }
                  },
                ),
                MoustraButton.icon(
                  label: 'Merge Strain',
                  icon: Icons.merge_type,
                  variant: ButtonVariant.secondary,
                  onPressed: _selected.length >= 2 ? _mergeSelected : null,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PaginatedDataGrid<StrainDto>(
            controller: _controller,
            onSortChanged: (columnName, ascending) {
              _sortField = columnName;
              _sortOrder = ascending ? SortOrder.asc.name : SortOrder.desc.name;
              _controller.reload();
            },
            columns: StrainListColumn.getColumns(),
            sourceBuilder: (rows) => _StrainGridSource(
              records: rows,
              selected: _selected,
              onToggle: _onToggleSelected,
              context: context,
            ),
            fetchPage: (page, pageSize) async {
              final pageData = await strainService.getStrainsPage(
                page: page,
                pageSize: pageSize,
                query: {
                  if (_sortField != null)
                    SortQueryParamKey.sort.name: _sortField!,
                  if (_sortField != null)
                    SortQueryParamKey.order.name: _sortOrder,
                },
              );
              return PaginatedResult<StrainDto>(
                count: pageData.count,
                results: pageData.results,
              );
            },
            onFilterChanged: (page, pageSize, searchTerm, {useAiSearch}) async {
              final pageData = useAiSearch == true
                  ? await strainService.searchStrainsWithAi(prompt: searchTerm)
                  : await strainService.getStrainsPage(
                      page: page,
                      pageSize: pageSize,
                      query: {
                        if (_sortField != null)
                          SortQueryParamKey.sort.name: _sortField!,
                        if (_sortField != null)
                          SortQueryParamKey.order.name: _sortOrder,
                        if (searchTerm.isNotEmpty) ...{
                          SearchQueryParamKey.filter.name: 'strain_name',
                          SearchQueryParamKey.value.name: searchTerm,
                          SearchQueryParamKey.op.name: 'contains',
                        },
                      },
                    );
              return PaginatedResult<StrainDto>(
                count: pageData.count,
                results: pageData.results,
              );
            },
          ),
        ),
      ],
    );
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

  Future<void> _goToPage(int zeroBasedPage) async {}

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
  final List<StrainDto> records;
  final Set<String> selected;
  final void Function(String uuid, bool selected) onToggle;
  final BuildContext context;

  _StrainGridSource({
    required this.records,
    required this.selected,
    required this.onToggle,
    required this.context,
  }) {
    _dataGridRows = records.map(StrainListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _dataGridRows;

  @override
  List<DataGridRow> get rows => _dataGridRows;

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
            onPressed: () {
              context.go('/strains/$uuid');
            },
          ),
        ),
        cellText(row.getCells()[2].value),
        cellText('${row.getCells()[3].value}', textAlign: Alignment.center),
        Center(child: ColorPicker(hex: row.getCells()[4].value)),
        cellText(row.getCells()[5].value),
        cellText(row.getCells()[6].value),
        cellText(row.getCells()[7].value),
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
}
