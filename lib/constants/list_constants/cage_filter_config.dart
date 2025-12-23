import 'package:moustra/services/models/list_query_params.dart';

/// Filter and sort configuration for the Cages list page
class CageFilterConfig {
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
      operators: FilterOperators.booleanOperators,
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

