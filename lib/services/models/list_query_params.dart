/// Filter parameter for API list queries
class FilterParam {
  final String field;
  final String operator;
  final String? value;

  const FilterParam({
    required this.field,
    required this.operator,
    this.value,
  });

  FilterParam copyWith({
    String? field,
    String? operator,
    String? value,
  }) {
    return FilterParam(
      field: field ?? this.field,
      operator: operator ?? this.operator,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterParam &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          operator == other.operator &&
          value == other.value;

  @override
  int get hashCode => Object.hash(field, operator, value);

  @override
  String toString() => 'FilterParam(field: $field, op: $operator, value: $value)';
}

/// Sort parameter for API list queries
class SortParam {
  final String field;
  final SortOrder order;

  const SortParam({
    required this.field,
    this.order = SortOrder.desc,
  });

  SortParam copyWith({
    String? field,
    SortOrder? order,
  }) {
    return SortParam(
      field: field ?? this.field,
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortParam &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          order == other.order;

  @override
  int get hashCode => Object.hash(field, order);

  @override
  String toString() => 'SortParam(field: $field, order: ${order.name})';
}

/// Sort order enum
enum SortOrder { asc, desc }

/// Combined query parameters for paginated list endpoints
class ListQueryParams {
  final int page;
  final int pageSize;
  final List<FilterParam> filters;
  final List<SortParam> sorts;

  const ListQueryParams({
    this.page = 1,
    this.pageSize = 25,
    this.filters = const [],
    this.sorts = const [],
  });

  ListQueryParams copyWith({
    int? page,
    int? pageSize,
    List<FilterParam>? filters,
    List<SortParam>? sorts,
  }) {
    return ListQueryParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      filters: filters ?? this.filters,
      sorts: sorts ?? this.sorts,
    );
  }

  /// Builds a query string with support for repeated parameters
  /// Example output: page=1&page_size=25&filter=strain&op=contains&value=C57&filter=sex&op=equals&value=M
  String buildQueryString() {
    final List<String> parts = [];

    // Add pagination
    parts.add('page=$page');
    parts.add('page_size=$pageSize');

    // Add filters (filter, op, value triplets)
    for (final filter in filters) {
      parts.add('filter=${Uri.encodeComponent(filter.field)}');
      parts.add('op=${Uri.encodeComponent(filter.operator)}');
      if (filter.value != null) {
        parts.add('value=${Uri.encodeComponent(filter.value!)}');
      }
    }

    // Add sorts (sort, order pairs)
    for (final sort in sorts) {
      parts.add('sort=${Uri.encodeComponent(sort.field)}');
      parts.add('order=${sort.order.name}');
    }

    return parts.join('&');
  }

  /// Returns true if there are any active filters
  bool get hasFilters => filters.isNotEmpty;

  /// Returns true if there are any active sorts
  bool get hasSorts => sorts.isNotEmpty;

  @override
  String toString() =>
      'ListQueryParams(page: $page, pageSize: $pageSize, filters: $filters, sorts: $sorts)';
}

/// Filter field types for determining which operators are available
enum FilterFieldType {
  text,
  date,
  boolean,
  select,
  number,
}

/// Definition of a filterable field
class FilterFieldDefinition {
  final String field;
  final String label;
  final FilterFieldType type;
  final List<String> operators;
  final List<FilterSelectOption>? selectOptions;

  const FilterFieldDefinition({
    required this.field,
    required this.label,
    required this.type,
    required this.operators,
    this.selectOptions,
  });
}

/// Option for select-type filter fields
class FilterSelectOption {
  final String value;
  final String label;

  const FilterSelectOption({
    required this.value,
    required this.label,
  });
}

/// Definition of a sortable field
class SortFieldDefinition {
  final String field;
  final String label;

  const SortFieldDefinition({
    required this.field,
    required this.label,
  });
}

/// Available filter operators by category
class FilterOperators {
  // String/Text operators
  static const String contains = 'contains';
  static const String equals = 'equals';
  static const String startsWith = 'starts_with';
  static const String endsWith = 'ends_with';
  static const String isEmpty = 'is_empty';
  static const String isNotEmpty = 'is_not_empty';

  // Date/Number operators
  static const String before = 'before';
  static const String after = 'after';
  static const String onOrBefore = 'on_or_before';
  static const String onOrAfter = 'on_or_after';
  static const String is_ = 'is';
  static const String not = 'not';

  // Boolean/Select operators
  static const String isAnyOf = 'is_any_of';

  /// Text field operators
  static const List<String> textOperators = [
    contains,
    equals,
    startsWith,
    endsWith,
    isEmpty,
    isNotEmpty,
  ];

  /// Date field operators
  static const List<String> dateOperators = [
    is_,
    before,
    after,
    onOrBefore,
    onOrAfter,
    not,
    isEmpty,
    isNotEmpty,
  ];

  /// Boolean field operators
  static const List<String> booleanOperators = [
    is_,
  ];

  /// Select field operators
  static const List<String> selectOperators = [
    is_,
    isAnyOf,
  ];

  /// Number field operators
  static const List<String> numberOperators = [
    is_,
    before,
    after,
    onOrBefore,
    onOrAfter,
    not,
  ];

  /// Get human-readable label for an operator
  static String getLabel(String operator) {
    switch (operator) {
      case contains:
        return 'Contains';
      case equals:
        return 'Equals';
      case startsWith:
        return 'Starts with';
      case endsWith:
        return 'Ends with';
      case isEmpty:
        return 'Is empty';
      case isNotEmpty:
        return 'Is not empty';
      case before:
        return 'Before';
      case after:
        return 'After';
      case onOrBefore:
        return 'On or before';
      case onOrAfter:
        return 'On or after';
      case is_:
        return 'Is';
      case not:
        return 'Is not';
      case isAnyOf:
        return 'Is any of';
      default:
        return operator;
    }
  }

  /// Check if operator requires a value input
  static bool requiresValue(String operator) {
    return operator != isEmpty && operator != isNotEmpty;
  }
}


