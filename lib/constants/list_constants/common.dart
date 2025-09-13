enum SortOrder { asc, desc }

enum SortQueryParamKey { sort, order }

abstract class ListColumn {
  String get label;
  String get field;
  String get enumName; // expose enum name
}
