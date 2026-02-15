import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/services/models/prepared_filter.dart';

/// Placeholder replaced at query time with the current user's account UUID
const String currentUserPlaceholder = 'CURRENT_USER';

/// Filter and sort configuration for the Cages list page
class CageFilterConfig {
  /// Prepared filter presets matching the web UI
  static const List<PreparedFilter> preparedFilters = [
    PreparedFilter(
      name: 'Default',
      filters: [],
      sort: SortParam(field: 'created_date', order: SortOrder.desc),
    ),
    PreparedFilter(
      name: 'My Cages',
      filters: [
        FilterParam(
          field: 'end_date',
          operator: FilterOperators.isEmpty,
          value: '',
        ),
        FilterParam(
          field: 'owner',
          operator: FilterOperators.equals,
          value: currentUserPlaceholder,
        ),
      ],
      sort: SortParam(field: 'created_date', order: SortOrder.desc),
    ),
    PreparedFilter(
      name: 'Ended Cages',
      filters: [
        FilterParam(
          field: 'end_date',
          operator: FilterOperators.isNotEmpty,
          value: 'true',
        ),
      ],
      sort: SortParam(field: 'created_date', order: SortOrder.desc),
    ),
  ];

  /// Available filterable fields for Cages endpoint
  static const List<FilterFieldDefinition> filterFields = [
    FilterFieldDefinition(
      field: 'cage_tag',
      label: 'Cage Tag',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
    FilterFieldDefinition(
      field: 'strain',
      label: 'Strain',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
    FilterFieldDefinition(
      field: 'status',
      label: 'Status',
      type: FilterFieldType.select,
      operators: FilterOperators.selectOperators,
      selectOptions: [
        FilterSelectOption(value: 'active', label: 'Active'),
        FilterSelectOption(value: 'ended', label: 'Ended'),
      ],
    ),
    FilterFieldDefinition(
      field: 'is_active',
      label: 'Is Active',
      type: FilterFieldType.select,
      operators: [FilterOperators.equals],
      selectOptions: [
        FilterSelectOption(value: 'true', label: 'Yes'),
        FilterSelectOption(value: 'false', label: 'No'),
      ],
    ),
    FilterFieldDefinition(
      field: 'genotypes',
      label: 'Genotypes',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
    FilterFieldDefinition(
      field: 'end_date',
      label: 'End Date',
      type: FilterFieldType.date,
      operators: FilterOperators.dateOperators,
    ),
    FilterFieldDefinition(
      field: 'created_date',
      label: 'Created Date',
      type: FilterFieldType.date,
      operators: FilterOperators.dateOperators,
    ),
  ];

  /// Available sortable fields for Cages endpoint
  static const List<SortFieldDefinition> sortFields = [
    SortFieldDefinition(field: 'created_date', label: 'Created Date'),
    SortFieldDefinition(field: 'cage_tag', label: 'Cage Tag'),
    SortFieldDefinition(field: 'strain', label: 'Strain'),
    SortFieldDefinition(field: 'status', label: 'Status'),
  ];

  /// Default sort configuration
  static const SortParam defaultSort = SortParam(
    field: 'created_date',
    order: SortOrder.desc,
  );
}

