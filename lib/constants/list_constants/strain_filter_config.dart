import 'package:moustra/services/models/list_query_params.dart';

/// Filter and sort configuration for the Strains list page
class StrainFilterConfig {
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
      operators: FilterOperators.booleanOperators,
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
    field: 'strain_name',
    order: SortOrder.asc,
  );
}

