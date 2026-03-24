import 'package:flutter/material.dart';
import 'package:moustra/services/clients/event_api.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/animal_constants.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/constants/list_constants/mating_filter_config.dart';
import 'package:moustra/constants/list_constants/mating_list_constants.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/clients/mating_api.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:moustra/stores/table_setting_store.dart';
import 'package:moustra/widgets/column_settings_sheet.dart';
import 'package:moustra/widgets/filter_panel.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra_api/moustra_api.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MatingsScreen extends StatefulWidget {
  const MatingsScreen({super.key});

  @override
  State<MatingsScreen> createState() => _MatingsScreenState();
}

class _MatingsScreenState extends State<MatingsScreen> {
  final PaginatedGridController _controller = PaginatedGridController();
  final MovableFabMenuController _fabController = MovableFabMenuController();

  // Filter & Sort state
  List<FilterParam> _activeFilters = [];
  SortParam? _activeSort = MatingFilterConfig.defaultSort;

  // Table settings
  TableSettingSLR? _tableSetting;

  @override
  void initState() {
    super.initState();
    eventApi.trackEvent('view_matings');
    _loadTableSetting();
  }

  Future<void> _loadTableSetting() async {
    final setting = await getTableSetting('MatingList');
    if (mounted && setting != null) {
      setState(() => _tableSetting = setting);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onFiltersApplied(List<FilterParam> filters, SortParam? sort) {
    setState(() {
      _activeFilters = filters;
      _activeSort = sort;
    });
    _controller.reload();
  }

  void _onFiltersClear() {
    setState(() {
      _activeFilters = [];
      _activeSort = MatingFilterConfig.defaultSort;
    });
    _controller.reload();
  }

  ListQueryParams _buildQueryParams({
    required int page,
    required int pageSize,
    String? searchTerm,
  }) {
    List<FilterParam> filters = List.from(_activeFilters);

    if (searchTerm != null && searchTerm.isNotEmpty) {
      filters.add(FilterParam(
        field: 'mating_tag',
        operator: FilterOperators.contains,
        value: searchTerm,
      ));
    }

    List<SortParam> sorts = [];
    if (_activeSort != null) {
      sorts.add(_activeSort!);
    }

    return ListQueryParams(
      page: page,
      pageSize: pageSize,
      filters: filters,
      sorts: sorts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Panel
        FilterPanel(
          filterFields: MatingFilterConfig.filterFields,
          sortFields: MatingFilterConfig.sortFields,
          initialFilters: _activeFilters,
          initialSort: _activeSort,
          onApply: _onFiltersApplied,
          onClear: _onFiltersClear,
          onColumnSettingsTap: _tableSetting != null
              ? () => showColumnSettingsSheet(
                    context: context,
                    baseName: 'MatingList',
                    tableSetting: _tableSetting!,
                    onSettingsChanged: () {
                      final updated = tableSettingStore.value['MatingList'];
                      if (updated != null && mounted) {
                        setState(() => _tableSetting = updated);
                      }
                    },
                  )
              : null,
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              Builder(builder: (context) {
                final matingColumns = MatingListColumn.getColumns(
                  settingFields: _tableSetting?.tableSettingFields.toList(),
                );
                return PaginatedDataGrid<MatingDto>(
                controller: _controller,
                searchPlaceholder: 'Try "Search mating M-42"',
                onSortChanged: (columnName, ascending) {
                  setState(() {
                    _activeSort = SortParam(
                      field: columnName,
                      order: ascending ? SortOrder.asc : SortOrder.desc,
                    );
                  });
                  _controller.reload();
                },
                columns: matingColumns,
                sourceBuilder: (rows) =>
                    _MatingGridSource(records: rows, context: context, columns: matingColumns),
                fetchPage: (page, pageSize) async {
                  final params = _buildQueryParams(
                    page: page,
                    pageSize: pageSize,
                  );
                  final pageData = await matingService.getMatingsPageWithParams(
                    params: params,
                  );
                  return PaginatedResult<MatingDto>(
                    count: pageData.count,
                    results: pageData.results.cast<MatingDto>(),
                  );
                },
                onFilterChanged:
                    (page, pageSize, searchTerm, {useAiSearch}) async {
                  final params = _buildQueryParams(
                    page: page,
                    pageSize: pageSize,
                    searchTerm: searchTerm,
                  );
                  final pageData = await matingService.getMatingsPageWithParams(
                    params: params,
                  );
                  return PaginatedResult<MatingDto>(
                    count: pageData.count,
                    results: pageData.results,
                  );
                },
                rowHeightEstimator: (index, row) => _estimateLines(row),
              );
              }),
              Positioned.fill(
                child: MovableFabMenu(
                  controller: _fabController,
                  heroTag: 'matings-fab-menu',
                  actions: [
                    FabMenuAction(
                      label: 'Create Mating',
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        eventApi.trackEvent('create_mating');
                        context.go('/mating/new');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _estimateLines(MatingDto m) {
    final List<AnimalSummaryDto> animals = (m.animals ?? <AnimalSummaryDto>[]);
    final List<AnimalSummaryDto> females = animals
        .where((a) => (a.sex ?? '') == SexConstants.female)
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
  final BuildContext context;
  final List<GridColumn> columns;

  _MatingGridSource({required this.records, required this.context, required this.columns}) {
    _rows = records.map(MatingListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final Map<String, Object?> values = {
      for (final cell in row.getCells()) cell.columnName: cell.value,
    };
    final String uuid = (values[MatingListColumn.edit.name] as String?) ?? '';
    final String matingTag = (values[MatingListColumn.matingTag.name] as String?) ?? '';
    List<String> asList(dynamic v) => (v as List<String>? ?? <String>[]);

    Widget buildCell(String columnName) {
      switch (columnName) {
        case 'edit':
          return Center(
            child: Semantics(
              label: 'Edit $matingTag',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () {
                  context.go('/mating/$uuid');
                },
              ),
            ),
          );
        case 'mating_tag':
          return GestureDetector(
            onTap: () => context.go('/mating/$uuid'),
            child: cellText(matingTag),
          );
        case 'female_tag':
          return cellTextList(asList(values[MatingListColumn.femaleTag.name]));
        case 'female_genotypes':
          return cellTextList(asList(values[MatingListColumn.femaleGenotypes.name]));
        default:
          return cellText(values[columnName]?.toString());
      }
    }

    return DataGridRowAdapter(
      cells: columns.map((col) => buildCell(col.columnName)).toList(),
    );
  }
}
