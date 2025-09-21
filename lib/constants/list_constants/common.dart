enum SortOrder { asc, desc }

enum SortQueryParamKey { sort, order }

enum SearchQueryParamKey { filter, op, value }

abstract class ListColumn<T> {
  String get label;
  String get field;
  String get enumName; // expose enum name
}

const double selectColumnWidth = 42;
const double editColumnWidth = 42;
const double eidColumnWidth = 64;
const double ownerColumnWidth = 160;
