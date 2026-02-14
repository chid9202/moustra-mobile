import 'package:moustra/services/models/list_query_params.dart';

class PreparedFilter {
  final String name;
  final List<FilterParam> filters;
  final SortParam? sort;

  const PreparedFilter({
    required this.name,
    this.filters = const [],
    this.sort,
  });
}
