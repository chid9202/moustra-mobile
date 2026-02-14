import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/services/models/prepared_filter.dart';

/// Placeholder replaced at query time with the current user's account UUID
const String currentUserPlaceholder = 'CURRENT_USER';

/// Filter and sort configuration for the Strains list page
class StrainFilterConfig {
  /// Prepared filter presets matching the web UI
  static const List<PreparedFilter> preparedFilters = [
    PreparedFilter(
      name: 'Default',
      filters: [],
      sort: SortParam(field: 'created_date', order: SortOrder.desc),
    ),
    PreparedFilter(
      name: 'My Strains',
      filters: [
        FilterParam(
          field: 'owner',
          operator: FilterOperators.equals,
          value: currentUserPlaceholder,
        ),
      ],
      sort: SortParam(field: 'created_date', order: SortOrder.desc),
    ),
    PreparedFilter(
      name: 'Inactive Strains',
      filters: [
        FilterParam(
          field: 'is_active',
          operator: FilterOperators.equals,
          value: 'false',
        ),
      ],
      sort: SortParam(field: 'created_date', order: SortOrder.desc),
    ),
  ];

  /// Available filterable fields for Strains endpoint
  static const List<FilterFieldDefinition> filterFields = [
    FilterFieldDefinition(
      field: 'strain_name',
      label: 'Strain Name',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
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
      field: 'created_date',
      label: 'Created Date',
      type: FilterFieldType.date,
      operators: FilterOperators.dateOperators,
    ),
  ];

  /// Available sortable fields for Strains endpoint
  static const List<SortFieldDefinition> sortFields = [
    SortFieldDefinition(field: 'strain_name', label: 'Strain Name'),
    SortFieldDefinition(field: 'owner', label: 'Owner'),
    SortFieldDefinition(field: 'created_date', label: 'Created Date'),
  ];

  /// Default sort configuration
  static const SortParam defaultSort = SortParam(
    field: 'created_date',
    order: SortOrder.desc,
  );
}

