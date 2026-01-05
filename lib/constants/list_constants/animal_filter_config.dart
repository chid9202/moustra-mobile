import 'package:moustra/constants/animal_constants.dart';
import 'package:moustra/services/models/list_query_params.dart';

/// Filter and sort configuration for the Animals list page
class AnimalFilterConfig {
  /// Available filterable fields for Animals endpoint
  static const List<FilterFieldDefinition> filterFields = [
    FilterFieldDefinition(
      field: 'physical_tag',
      label: 'Physical Tag',
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
      field: 'sex',
      label: 'Sex',
      type: FilterFieldType.select,
      operators: FilterOperators.selectOperators,
      selectOptions: [
        FilterSelectOption(value: SexConstants.male, label: 'Male'),
        FilterSelectOption(value: SexConstants.female, label: 'Female'),
        FilterSelectOption(value: SexConstants.unknown, label: 'Unknown'),
      ],
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
    FilterFieldDefinition(
      field: 'cage_tag',
      label: 'Cage Tag',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
    FilterFieldDefinition(
      field: 'genotypes',
      label: 'Genotypes',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
  ];

  /// Available sortable fields for Animals endpoint
  static const List<SortFieldDefinition> sortFields = [
    SortFieldDefinition(field: 'created_date', label: 'Created Date'),
    SortFieldDefinition(field: 'physical_tag', label: 'Physical Tag'),
    SortFieldDefinition(field: 'strain', label: 'Strain'),
    SortFieldDefinition(field: 'sex', label: 'Sex'),
    SortFieldDefinition(field: 'date_of_birth', label: 'Date of Birth'),
    SortFieldDefinition(field: 'wean_date', label: 'Wean Date'),
    SortFieldDefinition(field: 'cage_tag', label: 'Cage Tag'),
    SortFieldDefinition(field: 'owner', label: 'Owner'),
    SortFieldDefinition(field: 'end_date', label: 'End Date'),
    SortFieldDefinition(field: 'status', label: 'Status'),
  ];

  /// Default sort configuration
  static const SortParam defaultSort = SortParam(
    field: 'created_date',
    order: SortOrder.desc,
  );

  /// Get filter field definition by field name
  static FilterFieldDefinition? getFilterField(String field) {
    try {
      return filterFields.firstWhere((f) => f.field == field);
    } catch (_) {
      return null;
    }
  }

  /// Get sort field definition by field name
  static SortFieldDefinition? getSortField(String field) {
    try {
      return sortFields.firstWhere((f) => f.field == field);
    } catch (_) {
      return null;
    }
  }
}
