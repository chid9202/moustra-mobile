enum SortOrder { asc, desc }

enum SortQueryParamKey { sort, order }

enum SearchQueryParamKey { filter, op, value }

abstract class ListColumn<T> {
  String get label;
  String get field;
  String get enumName; // expose enum name
}
