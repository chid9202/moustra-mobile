import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/cage_filter_config.dart';
import 'package:moustra/constants/list_constants/cage_list_constants.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:moustra/widgets/filter_panel.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:moustra/screens/barcode_scanner_screen.dart';

class CagesListScreen extends StatefulWidget {
  const CagesListScreen({super.key});

  @override
  State<CagesListScreen> createState() => _CagesListScreenState();
}

class _CagesListScreenState extends State<CagesListScreen> {
  final PaginatedGridController _controller = PaginatedGridController();
  final MovableFabMenuController _fabController = MovableFabMenuController();

  // Filter & Sort state
  List<FilterParam> _activeFilters = [];
  SortParam? _activeSort = CageFilterConfig.defaultSort;

  @override
  void initState() {
    super.initState();
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
      _activeSort = CageFilterConfig.defaultSort;
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
        field: 'cage_tag',
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
          filterFields: CageFilterConfig.filterFields,
          sortFields: CageFilterConfig.sortFields,
          initialFilters: _activeFilters,
          initialSort: _activeSort,
          onApply: _onFiltersApplied,
          onClear: _onFiltersClear,
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              PaginatedDataGrid<CageDto>(
                controller: _controller,
                searchPlaceholder: 'Try "Search cage C-101"',
                onSortChanged: (columnName, ascending) {
                  setState(() {
                    _activeSort = SortParam(
                      field: columnName,
                      order: ascending ? SortOrder.asc : SortOrder.desc,
                    );
                  });
                  _controller.reload();
                },
                columns: CageListColumn.getColumns(),
                sourceBuilder: (rows) =>
                    _CageGridSource(records: rows, context: context),
                fetchPage: (page, pageSize) async {
                  final params = _buildQueryParams(
                    page: page,
                    pageSize: pageSize,
                  );
                  final pageData = await cageApi.getCagesPageWithParams(
                    params: params,
                  );
                  return PaginatedResult<CageDto>(
                    count: pageData.count,
                    results: pageData.results.cast<CageDto>(),
                  );
                },
                onFilterChanged:
                    (page, pageSize, searchTerm, {useAiSearch}) async {
                  if (useAiSearch == true && searchTerm.isNotEmpty) {
                    final pageData =
                        await cageApi.searchCagesWithAi(prompt: searchTerm);
                    return PaginatedResult<CageDto>(
                      count: pageData.count,
                      results: pageData.results,
                    );
                  }

                  final params = _buildQueryParams(
                    page: page,
                    pageSize: pageSize,
                    searchTerm: searchTerm,
                  );
                  final pageData = await cageApi.getCagesPageWithParams(
                    params: params,
                  );
                  return PaginatedResult<CageDto>(
                    count: pageData.count,
                    results: pageData.results,
                  );
                },
                rowHeightEstimator: (index, row) => _estimateLines(row),
              ),
              Positioned.fill(
                child: MovableFabMenu(
                  controller: _fabController,
                  heroTag: 'cages-fab-menu',
                  margin: const EdgeInsets.only(right: 24, bottom: 50),
                  actions: [
                    FabMenuAction(
                      label: 'Scan Barcode',
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanBarcode,
                    ),
                    FabMenuAction(
                      label: 'Add Cage',
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        context.go('/cages/new');
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

  int _estimateLines(CageDto c) {
    final List<dynamic> animals = (c.animals as List<dynamic>? ?? <dynamic>[]);
    int tags = animals
        .map((a) => (a.physicalTag ?? '').toString())
        .where((t) => t.isNotEmpty)
        .length;
    int gens = animals
        .map((a) => GenotypeHelper.formatGenotypes(a.genotypes))
        .where((g) => g.isNotEmpty)
        .length;
    return (tags > gens ? tags : gens).clamp(1, 20);
  }

  Future<void> _scanBarcode() async {
    try {
      final String? barcode = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => const BarcodeScannerScreen(),
        ),
      );

      if (barcode == null || !mounted) return;

      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final cage = await cageApi.getCageByBarcode(barcode);
        if (!mounted) return;
        
        // Dismiss loading dialog - use rootNavigator to ensure we get the dialog
        Navigator.of(context, rootNavigator: true).pop();
        
        // Small delay to ensure dialog is dismissed
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
        
        context.go('/cages/${cage.cageUuid}');
      } catch (e) {
        if (!mounted) return;
        
        // Dismiss loading dialog - use rootNavigator to ensure we get the dialog
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {
          // Dialog might already be dismissed
        }
        
        // Small delay to ensure dialog is dismissed
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
        
        // Show user-friendly error message
        String errorMessage = 'Cage not found';
        final errorString = e.toString();
        if (errorString.contains('not found') || errorString.contains('404')) {
          errorMessage = 'No cage found with barcode "$barcode"';
        } else if (errorString.contains('Exception:')) {
          errorMessage = errorString.replaceFirst('Exception: ', '');
        } else {
          errorMessage = 'Error: $errorString';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Try to dismiss dialog if still showing
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {
        // Ignore
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning barcode: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

class _CageGridSource extends DataGridSource {
  final List<CageDto> records;
  final BuildContext context;

  _CageGridSource({required this.records, required this.context}) {
    _rows = records.map(CageListColumn.getDataGridRow).toList();
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
              context.go('/cages/$uuid');
            },
          ),
        ),
        cellText('${row.getCells()[1].value}', textAlign: Alignment.center),
        cellText(row.getCells()[2].value),
        cellText(row.getCells()[3].value),
        cellText('${row.getCells()[4].value}', textAlign: Alignment.center),
        cellTextList(row.getCells()[5].value),
        cellTextList(row.getCells()[6].value),
        cellText(row.getCells()[7].value),
        cellText(row.getCells()[8].value),
        cellText(row.getCells()[9].value),
        cellText(row.getCells()[10].value),
      ],
    );
  }
}
