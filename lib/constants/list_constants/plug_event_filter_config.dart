import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/services/models/prepared_filter.dart';

/// Filter and sort configuration for the Plug Events list page
class PlugEventFilterConfig {
  /// Prepared filter presets (replaces the separate ChoiceChip tabs)
  static const List<PreparedFilter> preparedFilters = [
    PreparedFilter(
      name: 'Active',
      filters: [
        FilterParam(
          field: 'outcome',
          operator: FilterOperators.isEmpty,
          value: '',
        ),
      ],
      sort: SortParam(field: 'plug_date', order: SortOrder.desc),
    ),
    PreparedFilter(
      name: 'Completed',
      filters: [
        FilterParam(
          field: 'outcome',
          operator: FilterOperators.isNotEmpty,
          value: '',
        ),
      ],
      sort: SortParam(field: 'plug_date', order: SortOrder.desc),
    ),
    PreparedFilter(
      name: 'All',
      filters: [],
      sort: SortParam(field: 'created_date', order: SortOrder.desc),
    ),
  ];

  /// Available filterable fields for Plug Events endpoint
  static const List<FilterFieldDefinition> filterFields = [
    FilterFieldDefinition(
      field: 'outcome',
      label: 'Outcome',
      type: FilterFieldType.select,
      operators: [FilterOperators.is_],
      selectOptions: [
        FilterSelectOption(value: 'live_birth', label: 'Live Birth'),
        FilterSelectOption(value: 'harvest', label: 'Harvest'),
        FilterSelectOption(value: 'resorption', label: 'Resorption'),
        FilterSelectOption(value: 'no_pregnancy', label: 'No Pregnancy'),
        FilterSelectOption(value: 'cancelled', label: 'Cancelled'),
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
      field: 'female_tag',
      label: 'Female Tag',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
    FilterFieldDefinition(
      field: 'plug_date',
      label: 'Plug Date',
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

  /// Available sortable fields for Plug Events endpoint
  static const List<SortFieldDefinition> sortFields = [
    SortFieldDefinition(field: 'created_date', label: 'Created Date'),
    SortFieldDefinition(field: 'plug_date', label: 'Plug Date'),
    SortFieldDefinition(field: 'current_eday', label: 'Current E-Day'),
    SortFieldDefinition(field: 'target_date', label: 'Target Date'),
    SortFieldDefinition(field: 'owner', label: 'Owner'),
  ];

  /// Default sort configuration
  static const SortParam defaultSort = SortParam(
    field: 'created_date',
    order: SortOrder.desc,
  );
}
