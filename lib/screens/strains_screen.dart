import 'package:flutter/material.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/constants/list_constants/strain_list_constants.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/services/clients/strain_api.dart';
import 'package:moustra/widgets/color_picker.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';

class StrainsScreen extends StatefulWidget {
  const StrainsScreen({super.key});

  @override
  State<StrainsScreen> createState() => _StrainsScreenState();
}

class _StrainsScreenState extends State<StrainsScreen> {
  final PaginatedGridController _controller = PaginatedGridController();
  List<StrainDto> _all = <StrainDto>[];
  final TextEditingController _filterController = TextEditingController();
  String? _sortField; // api field, e.g., strain_name
  String _sortOrder = SortOrder.asc.name;
  // Sorting handled by grid; legacy fields removed
  // Paging handled by PaginatedDataGrid; keep UI page index for filter reset
  int _currentPage = 0;
  final Set<String> _selected = <String>{};

  @override
  void initState() {
    super.initState();
    _goToPage(0);
  }

  @override
  void dispose() {
    _filterController.dispose();
    // No controllers to dispose
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
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Create Strain clicked')),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Strain'),
                ),
                FilledButton.icon(
                  onPressed: _selected.length >= 2 ? _mergeSelected : null,
                  icon: const Icon(Icons.merge_type),
                  label: const Text('Merge Strain'),
                ),
              ],
            ),
          ),
        ),
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
              _controller.reload();
            },
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
              _all = pageData.results.cast<StrainDto>();
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

  void _applyFilter(String term) {
    final query = term.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _currentPage = 0;
      });
      return;
    }
    setState(() {
      _all = _all.where((e) {
        final name = e.strainName.toLowerCase();
        final uuid = e.strainUuid.toLowerCase();
        return name.contains(query) || uuid.contains(query);
      }).toList();
      _currentPage = 0;
    });
  }

  Future<void> _goToPage(int zeroBasedPage) async {
    setState(() {
      _currentPage = zeroBasedPage;
    });
  }

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

  _StrainGridSource({
    required this.records,
    required this.selected,
    required this.onToggle,
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
            onPressed: () {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[2].value),
        ),
        Center(child: Text('${row.getCells()[3].value}')),
        Center(child: ColorPicker(hex: row.getCells()[4].value)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[5].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[6].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[7].value),
        ),
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
