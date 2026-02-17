import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/cage_filter_config.dart';
import 'package:moustra/constants/list_constants/cage_list_constants.dart';
import 'package:moustra/constants/list_constants/cell_text.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/clients/event_api.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/services/models/prepared_filter.dart';
import 'package:moustra/helpers/genotype_helper.dart';
import 'package:moustra/helpers/util_helper.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/stores/setting_store.dart';
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
  final Set<String> _selected = <String>{};
  bool _isEndingMode = false;
  bool _isEndingCages = false;

  // Filter & Sort state
  List<FilterParam> _activeFilters = [];
  SortParam? _activeSort = CageFilterConfig.defaultSort;
  int _selectedPresetIndex = 0;

  @override
  void initState() {
    super.initState();
    // Apply default preset on load
    _applyPreset(0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _applyPreset(int index) {
    final preset = CageFilterConfig.preparedFilters[index];
    _selectedPresetIndex = index;
    _activeFilters = List.from(preset.filters);
    _activeSort = preset.sort;
  }

  void _onPresetSelected(int index) {
    setState(() {
      _applyPreset(index);
    });
    _controller.reload();
  }

  void _onFiltersApplied(List<FilterParam> filters, SortParam? sort) {
    setState(() {
      _activeFilters = filters;
      _activeSort = sort;
      _selectedPresetIndex = PreparedFilter.findMatchingPreset(
        CageFilterConfig.preparedFilters,
        filters,
        sort,
      );
    });
    _controller.reload();
  }

  void _onFiltersClear() {
    setState(() {
      _activeFilters = [];
      _activeSort = CageFilterConfig.defaultSort;
      _selectedPresetIndex = -1;
    });
    _controller.reload();
  }

  ListQueryParams _buildQueryParams({
    required int page,
    required int pageSize,
    String? searchTerm,
  }) {
    List<FilterParam> filters = _activeFilters.map((f) {
      if (f.value == currentUserPlaceholder) {
        return f.copyWith(
          value: profileState.value?.accountUuid ?? '',
        );
      }
      return f;
    }).toList();

    if (searchTerm != null && searchTerm.isNotEmpty) {
      filters.add(
        FilterParam(
          field: 'cage_tag',
          operator: FilterOperators.contains,
          value: searchTerm,
        ),
      );
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
          preparedFilters: CageFilterConfig.preparedFilters,
          selectedPresetIndex: _selectedPresetIndex,
          onPresetSelected: _onPresetSelected,
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
                columns: CageListColumn.getColumns(
                  includeSelect: _isEndingMode,
                  useEid: settingStore.value?.labSetting.useEid ?? false,
                ),
                sourceBuilder: (rows) => _CageGridSource(
                  records: rows,
                  context: context,
                  selected: _selected,
                  onToggle: _onToggleSelected,
                  isEndingMode: _isEndingMode,
                ),
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
                        final pageData = await cageApi.searchCagesWithAi(
                          prompt: searchTerm,
                        );
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
                    if (_isEndingMode)
                      FabMenuAction(
                        label: _isEndingCages
                            ? 'Ending...'
                            : 'End Selected Cages',
                        icon: _isEndingCages
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Icon(Icons.stop_circle_outlined),
                        onPressed:
                            _selected.isNotEmpty && !_isEndingCages
                                ? _endSelectedCages
                                : null,
                        enabled: _selected.isNotEmpty && !_isEndingCages,
                        closeOnTap: false,
                      )
                    else ...[
                      FabMenuAction(
                        label: 'Scan Barcode',
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanBarcode,
                      ),
                      FabMenuAction(
                        label: 'Add Cage',
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          eventApi.trackEvent('add_cage');
                          context.go('/cage/new');
                        },
                      ),
                    ],
                    FabMenuAction(
                      label:
                          _isEndingMode ? 'Cancel End Mode' : 'End Cages',
                      icon: Icon(
                        _isEndingMode
                            ? Icons.close
                            : Icons.stop_circle_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isEndingMode = !_isEndingMode;
                          if (!_isEndingMode) {
                            _selected.clear();
                          }
                        });
                      },
                      closeOnTap: false,
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

  void _onToggleSelected(String uuid, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(uuid);
      } else {
        _selected.remove(uuid);
      }
    });
  }

  Future<void> _endSelectedCages() async {
    if (_selected.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Cages?'),
        content: Text('End ${_selected.length} cage(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _isEndingCages = true;
    });

    try {
      for (final uuid in _selected.toList()) {
        await cageApi.endCage(uuid);
      }
      eventApi.trackEvent('end_cage');
      if (!mounted) return;
      setState(() {
        _selected.clear();
        _isEndingMode = false;
        _isEndingCages = false;
      });
      _controller.reload();
      _fabController.close();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cages ended successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isEndingCages = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to end cages: $e')),
      );
    }
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
      final String? scannedValue = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
      );

      if (scannedValue == null || !mounted) return;

      eventApi.trackEvent('scan_barcode_cage');

      // Check if scanned value is a URL with cage UUID
      final cageUuidFromUrl = UtilHelper.extractCageUuidFromUrl(scannedValue);
      if (cageUuidFromUrl != null) {
        // Direct navigation - no API call needed
        context.go('/cage/$cageUuidFromUrl');
        return;
      }

      // Not a URL - treat as barcode and look up via API
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final cage = await cageApi.getCageByBarcode(scannedValue);
        if (!mounted) return;

        // Dismiss loading dialog - use rootNavigator to ensure we get the dialog
        Navigator.of(context, rootNavigator: true).pop();

        // Small delay to ensure dialog is dismissed
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;

        context.go('/cage/${cage.cageUuid}');
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
          errorMessage = 'No cage found with barcode "$scannedValue"';
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
            content: Text(
              'Error scanning barcode: ${e.toString().replaceAll('Exception: ', '')}',
            ),
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
  final Set<String> selected;
  final void Function(String uuid, bool selected) onToggle;
  final bool isEndingMode;

  _CageGridSource({
    required this.records,
    required this.context,
    required this.selected,
    required this.onToggle,
    required this.isEndingMode,
  }) {
    _rows = records.map(CageListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final String uuid = row.getCells()[0].value as String;
    final bool isChecked = selected.contains(uuid);
    return DataGridRowAdapter(
      cells: [
        // Select checkbox (only visible in ending mode)
        Center(
          child: Checkbox(
            value: isChecked,
            onChanged: (v) {
              onToggle(uuid, v ?? false);
            },
          ),
        ),
        // Edit button
        Center(
          child: IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              context.go('/cage/$uuid');
            },
          ),
        ),
        cellText('${row.getCells()[2].value}', textAlign: Alignment.center),
        cellText(row.getCells()[3].value),
        cellText(row.getCells()[4].value),
        cellText('${row.getCells()[5].value}', textAlign: Alignment.center),
        cellTextList(row.getCells()[6].value),
        cellTextList(row.getCells()[7].value),
        cellText(row.getCells()[8].value),
        cellText(row.getCells()[9].value),
        cellText(row.getCells()[10].value),
        cellText(row.getCells()[11].value),
      ],
    );
  }
}
