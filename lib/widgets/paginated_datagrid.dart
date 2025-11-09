import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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
  void _attach(VoidCallback reload) => _reload = reload;
  void reload() => _reload?.call();
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
  final String? searchPlaceholder;

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
    this.searchPlaceholder,
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
  bool _sortAscending = true;
  bool _useAiSearch = true;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _pageSize = widget.pageSize;
    _fetchAndSet(0);
    widget.controller?._attach(() => _reload());
  }

  @override
  void dispose() {
    widget.controller?._attach(() {});
    super.dispose();
  }

  Future<void> _reload() async => _fetchAndSet(_currentPage);

  void _onFilterChanged(String value) {
    setState(() {
      _searchTerm = value;
    });
  }

  void _triggerSearch() {
    if (widget.onFilterChanged != null) {
      // Only use AI search if there's a search term
      final bool shouldUseAi = _useAiSearch && _searchTerm.trim().isNotEmpty;

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
        if (widget.onFilterChanged != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _onFilterChanged,
                    onSubmitted: (_) => _triggerSearch(),
                    decoration: InputDecoration(
                      hintText: widget.searchPlaceholder ?? 'Filter',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _triggerSearch,
                  tooltip: 'Search',
                ),
              ],
            ),
          ),
        if (widget.topBar != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: widget.topBar!,
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              SfDataGrid(
                source: widget.sourceBuilder(_rows),
                columns: widget.columns,
                allowSorting: true,
                onCellTap: (details) {
                  if (details.rowColumnIndex.rowIndex == 0) {
                    final int ci = details.rowColumnIndex.columnIndex;
                    if (ci < 0 || ci >= widget.columns.length) return;
                    final GridColumn col = widget.columns[ci];
                    if (col.allowSorting != true) return;
                    final String name = col.columnName;
                    // Toggle order
                    _sortAscending = !_sortAscending;
                    widget.onSortChanged?.call(name, _sortAscending);
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
