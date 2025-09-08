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

  const PaginatedDataGrid({
    super.key,
    required this.columns,
    required this.sourceBuilder,
    required this.fetchPage,
    this.topBar,
    this.controller,
    this.pageSize = 25,
    this.rowHeightEstimator,
  });

  @override
  State<PaginatedDataGrid<T>> createState() => _PaginatedDataGridState<T>();
}

class _PaginatedDataGridState<T> extends State<PaginatedDataGrid<T>> {
  late Future<List<T>> _future;
  List<T> _rows = <T>[];
  int _currentPage = 0; // zero-based
  late int _pageSize;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _pageSize = widget.pageSize;
    _future = _loadPage(0);
    widget.controller?._attach(() => _reload());
  }

  Future<void> _reload() async {
    await _goToPage(_currentPage);
  }

  int _pageCount() {
    if (_totalCount <= 0) return 1;
    return (_totalCount + _pageSize - 1) ~/ _pageSize;
  }

  Future<List<T>> _loadPage(int zeroBased) async {
    final res = await widget.fetchPage(zeroBased + 1, _pageSize);
    _totalCount = res.count;
    _rows = res.results;
    return _rows;
  }

  Future<void> _goToPage(int zeroBased) async {
    setState(() {
      _currentPage = zeroBased;
      _future = _loadPage(zeroBased);
    });
    await _future;
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Failed to load: ${snapshot.error}'));
        }
        return Column(
          children: [
            if (widget.topBar != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: widget.topBar!,
                ),
              ),
            Expanded(
              child: SfDataGrid(
                source: widget.sourceBuilder(_rows),
                columns: widget.columns,
                allowSorting: true,
                onQueryRowHeight: widget.rowHeightEstimator == null
                    ? null
                    : (details) {
                        const double base = 48;
                        final int ri = details.rowIndex;
                        if (ri <= 0 || ri > _rows.length) return base;
                        final int lines = widget.rowHeightEstimator!(
                          ri - 1,
                          _rows[ri - 1],
                        );
                        return base + (lines > 1 ? (lines - 1) * 20.0 : 0);
                      },
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
                    onPressed: _currentPage > 0
                        ? () => _goToPage(_currentPage - 1)
                        : null,
                  ),
                  Text(
                    'Page ${_currentPage + 1} of ${_pageCount()} (Total: $_totalCount)',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next',
                    onPressed: (_currentPage + 1) < _pageCount()
                        ? () => _goToPage(_currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
