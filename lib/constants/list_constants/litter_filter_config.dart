import 'package:moustra/services/models/list_query_params.dart';

/// Filter and sort configuration for the Litters list page
class LitterFilterConfig {
  /// Available filterable fields for Litters endpoint
  static const List<FilterFieldDefinition> filterFields = [
    FilterFieldDefinition(
      field: 'litter_tag',
      label: 'Litter Tag',
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
      field: 'date_of_birth',
      label: 'Date of Birth',
      type: FilterFieldType.date,
      operators: FilterOperators.dateOperators,
    ),
    FilterFieldDefinition(
      field: 'wean_date',
      label: 'Wean Date',
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

  /// Available sortable fields for Litters endpoint
  static const List<SortFieldDefinition> sortFields = [
    SortFieldDefinition(field: 'created_date', label: 'Created Date'),
    SortFieldDefinition(field: 'litter_tag', label: 'Litter Tag'),
    SortFieldDefinition(field: 'strain', label: 'Strain'),
    SortFieldDefinition(field: 'date_of_birth', label: 'Date of Birth'),
    SortFieldDefinition(field: 'wean_date', label: 'Wean Date'),
    SortFieldDefinition(field: 'owner', label: 'Owner'),
  ];

  /// Default sort configuration
  static const SortParam defaultSort = SortParam(
    field: 'created_date',
    order: SortOrder.desc,
  );
}

