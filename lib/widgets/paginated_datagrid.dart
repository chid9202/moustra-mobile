import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/models/cell_edit_state.dart';

class PaginatedResult<T> {
  final int count;
  final List<T> results;
  const PaginatedResult({required this.count, required this.results});
}

typedef FetchPage<T> =
    Future<PaginatedResult<T>> Function(int page, int pageSize);
typedef SourceBuilder<T> = DataGridSource Function(List<T> rows);
typedef RowHeightEstimator<T> = int Function(int index, T row);
typedef FilterChanged<T> =
    Future<PaginatedResult<T>> Function(
      int page,
      int pageSize,
      String searchTerm, {
      bool? useAiSearch,
    });

class PaginatedGridController {
  VoidCallback? _reload;
  void Function(String term)? _search;
  void _attach(VoidCallback reload, void Function(String term) search) {
    _reload = reload;
    _search = search;
  }

  void reload() => _reload?.call();
  void search(String term) => _search?.call(term);
}

class PaginatedDataGrid<T> extends StatefulWidget {
  final List<GridColumn> columns;
  final SourceBuilder<T> sourceBuilder;
  final FetchPage<T> fetchPage;
  final Widget? topBar;
  final PaginatedGridController? controller;
  final int pageSize;
  final RowHeightEstimator<T>? rowHeightEstimator;
  final FilterChanged<T>? onFilterChanged;
  final void Function(String columnName, bool ascending)? onSortChanged;
  final VoidCallback? onSortCleared;
  final String? activeSortColumn;
  final bool activeSortAscending;
  final void Function(T row)? onRowTap;

  /// Edit field configurations — defines which columns are editable and how.
  final Map<String, EditFieldConfig>? editFieldConfigs;

  /// Called when a cell edit is committed (from modal or picker).
  final Future<bool> Function(String rowId, String field, dynamic newValue)?
      onCellEditCommit;

  /// Called when an editable cell is tapped — opens the edit modal/picker.
  /// Should handle showing the appropriate UI and calling onCellEditCommit.
  /// Returns a Future so the grid can track when editing completes.
  final Future<void> Function(T row, String columnName)? onCellEditTap;

  /// Extracts the row UUID from a row object.
  final String Function(T row)? getRowId;

  /// The primary column name — tapping it navigates to the detail page (same as onRowTap).
  final String? primaryColumn;

  const PaginatedDataGrid({
    super.key,
    required this.columns,
    required this.sourceBuilder,
    required this.fetchPage,
    this.topBar,
    this.controller,
    this.pageSize = 25,
    this.rowHeightEstimator,
    this.onFilterChanged,
    this.onSortChanged,
    this.onSortCleared,
    this.activeSortColumn,
    this.activeSortAscending = true,
    this.onRowTap,
    this.editFieldConfigs,
    this.onCellEditCommit,
    this.onCellEditTap,
    this.getRowId,
    this.primaryColumn,
  });

  @override
  State<PaginatedDataGrid<T>> createState() => _PaginatedDataGridState<T>();
}

class _PaginatedDataGridState<T> extends State<PaginatedDataGrid<T>> {
  List<T> _rows = <T>[];
  int _currentPage = 0; // zero-based
  late int _pageSize;
  int _totalCount = 0;
  bool _isLoading = true;
  String? _sortedColumn;
  bool? _isSortAscending;
  String _searchTerm = '';

  // Tracks which cell is currently being edited for highlighting
  int? _editingRowIndex;
  int? _editingColIndex;

  @override
  void initState() {
    super.initState();
    _pageSize = widget.pageSize;
    _sortedColumn = widget.activeSortColumn;
    _isSortAscending = widget.activeSortColumn != null ? widget.activeSortAscending : null;
    _fetchAndSet(0);
    widget.controller?._attach(() => _reload(), _searchByTerm);
  }

  @override
  void didUpdateWidget(PaginatedDataGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSortColumn != oldWidget.activeSortColumn ||
        widget.activeSortAscending != oldWidget.activeSortAscending) {
      _sortedColumn = widget.activeSortColumn;
      _isSortAscending = widget.activeSortColumn != null ? widget.activeSortAscending : null;
    }
  }

  @override
  void dispose() {
    widget.controller?._attach(() {}, (_) {});
    super.dispose();
  }

  Future<void> _reload() async => _fetchAndSet(_currentPage);

  void _searchByTerm(String term) {
    _searchTerm = term;
    _triggerSearch();
  }

  void _triggerSearch() {
    if (widget.onFilterChanged != null) {
      final bool shouldUseAi = _searchTerm.trim().isNotEmpty;

      setState(() {
        _isLoading = true;
      });

      widget
          .onFilterChanged!(1, _pageSize, _searchTerm, useAiSearch: shouldUseAi)
          .then((res) {
            if (mounted) {
              setState(() {
                _currentPage = 0;
                _rows = res.results;
                _totalCount = res.count;
                _isLoading = false;
              });
            }
          });
    }
  }

  int _pageCount() {
    if (_totalCount <= 0) return 1;
    return (_totalCount + _pageSize - 1) ~/ _pageSize;
  }

  Future<void> _fetchAndSet(int zeroBased) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await widget.fetchPage(zeroBased + 1, _pageSize);
      _totalCount = res.count;
      _rows = res.results;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _goToPage(int zeroBased) async {
    setState(() {
      _currentPage = zeroBased;
    });
    await _fetchAndSet(zeroBased);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.topBar != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: widget.topBar!,
            ),
          ),
        Expanded(
          child: widget.columns.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Stack(
            children: [
              SfDataGridTheme(
                data: const SfDataGridThemeData(
                  gridLineColor: Color(0xFFE0E0E0),
                  gridLineStrokeWidth: 1,
                ),
                child: SfDataGrid(
                source: _HighlightingDataGridSource(
                  delegate: widget.sourceBuilder(_rows),
                  highlightRowIndex: _editingRowIndex,
                  highlightColIndex: _editingColIndex,
                  highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  highlightBorderColor: Theme.of(context).colorScheme.primary,
                ),
                columns: widget.columns,
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                allowSorting: false,
                onCellTap: (details) {
                  final int ri = details.rowColumnIndex.rowIndex;
                  if (ri == 0) {
                    // Header row — handle sorting
                    final int ci = details.rowColumnIndex.columnIndex;
                    if (ci < 0 || ci >= widget.columns.length) return;
                    final GridColumn col = widget.columns[ci];
                    if (col.allowSorting != true) return;
                    final String name = col.columnName;
                    if (_sortedColumn == name) {
                      if (_isSortAscending == true) {
                        // asc → desc
                        setState(() { _isSortAscending = false; });
                        widget.onSortChanged?.call(name, false);
                      } else if (widget.onSortCleared != null) {
                        // desc → unset (only if caller supports it)
                        setState(() { _sortedColumn = null; _isSortAscending = null; });
                        widget.onSortCleared!();
                      } else {
                        // desc → asc (fallback: original behavior for screens without unset)
                        setState(() { _isSortAscending = true; });
                        widget.onSortChanged?.call(name, true);
                      }
                    } else {
                      // New column → start asc
                      setState(() { _sortedColumn = name; _isSortAscending = true; });
                      widget.onSortChanged?.call(name, true);
                    }
                  } else if (ri > 0 && ri <= _rows.length) {
                    final row = _rows[ri - 1];
                    final int ci = details.rowColumnIndex.columnIndex;
                    if (ci >= 0 && ci < widget.columns.length) {
                      final colName = widget.columns[ci].columnName;

                      // Primary column tap → navigate to detail
                      if (colName == widget.primaryColumn) {
                        widget.onRowTap?.call(row);
                        return;
                      }

                      // Editable column tap → open edit modal
                      final config = widget.editFieldConfigs?[colName];
                      if (config != null && widget.onCellEditTap != null) {
                        setState(() {
                          _editingRowIndex = ri - 1;
                          _editingColIndex = ci;
                        });
                        widget.onCellEditTap!(row, colName).whenComplete(() {
                          if (mounted) {
                            setState(() {
                              _editingRowIndex = null;
                              _editingColIndex = null;
                            });
                          }
                        });
                        return;
                      }

                      // Non-editable, non-primary cell:
                      // If inline editing is configured, do nothing (like web's blue border select)
                      // If no inline editing configured, fall through to row tap for navigation
                      if (widget.editFieldConfigs != null) {
                        return;
                      }
                    }
                    // No inline editing configured — navigate on any cell tap
                    widget.onRowTap?.call(row);
                  }
                },
                onQueryRowHeight: (details) {
                  const double base = 36;
                  final int ri = details.rowIndex;
                  if (widget.rowHeightEstimator == null) return base;
                  if (ri <= 0 || ri > _rows.length) return base;
                  final int lines = widget.rowHeightEstimator!(
                    ri - 1,
                    _rows[ri - 1],
                  );
                  return base + (lines > 1 ? (lines - 1) * 20.0 : 0);
                },
              ),
              ),
              if (_isLoading)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: const LinearProgressIndicator(minHeight: 3),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous',
                onPressed: _currentPage > 0 && !_isLoading
                    ? () => _goToPage(_currentPage - 1)
                    : null,
              ),
              Text(
                'Page ${_currentPage + 1} of ${_pageCount()} (Total: $_totalCount)',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next',
                onPressed: (_currentPage + 1) < _pageCount() && !_isLoading
                    ? () => _goToPage(_currentPage + 1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Wraps a [DataGridSource] to highlight the currently-editing cell.
class _HighlightingDataGridSource extends DataGridSource {
  final DataGridSource delegate;
  final int? highlightRowIndex;
  final int? highlightColIndex;
  final Color highlightColor;
  final Color highlightBorderColor;

  _HighlightingDataGridSource({
    required this.delegate,
    this.highlightRowIndex,
    this.highlightColIndex,
    required this.highlightColor,
    required this.highlightBorderColor,
  });

  @override
  List<DataGridRow> get rows => delegate.rows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final adapter = delegate.buildRow(row);
    if (adapter == null ||
        highlightRowIndex == null ||
        highlightColIndex == null) {
      return adapter;
    }

    final rowIndex = delegate.rows.indexOf(row);
    if (rowIndex != highlightRowIndex ||
        highlightColIndex! >= adapter.cells.length) {
      return adapter;
    }

    final cells = List<Widget>.from(adapter.cells);
    cells[highlightColIndex!] = Container(
      decoration: BoxDecoration(
        color: highlightColor,
        border: Border.all(color: highlightBorderColor, width: 2),
      ),
      child: cells[highlightColIndex!],
    );
    return DataGridRowAdapter(cells: cells, color: adapter.color);
  }
}
