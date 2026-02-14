import 'package:moustra/services/models/list_query_params.dart';

/// Filter and sort configuration for the Matings list page
class MatingFilterConfig {
  /// Available filterable fields for Matings endpoint
  static const List<FilterFieldDefinition> filterFields = [
    FilterFieldDefinition(
      field: 'mating_tag',
      label: 'Mating Tag',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
    FilterFieldDefinition(
      field: 'cage_tag',
      label: 'Cage Tag',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
    FilterFieldDefinition(
      field: 'litter_strain',
      label: 'Strain',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
    FilterFieldDefinition(
      field: 'male_tag',
      label: 'Male Tag',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
    FilterFieldDefinition(
      field: 'female_tag',
      label: 'Female Tag',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
    FilterFieldDefinition(
      field: 'male_genotypes',
      label: 'Male Genotypes',
      type: FilterFieldType.text,
      operators: FilterOperators.textOperators,
    ),
    FilterFieldDefinition(
      field: 'female_genotypes',
      label: 'Female Genotypes',
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
      field: 'set_up_date',
      label: 'Set Up Date',
      type: FilterFieldType.date,
      operators: FilterOperators.dateOperators,
    ),
    FilterFieldDefinition(
      field: 'disbanded_date',
      label: 'Disbanded Date',
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

  /// Available sortable fields for Matings endpoint
  static const List<SortFieldDefinition> sortFields = [
    SortFieldDefinition(field: 'created_date', label: 'Created Date'),
    SortFieldDefinition(field: 'mating_tag', label: 'Mating Tag'),
    SortFieldDefinition(field: 'cage_tag', label: 'Cage Tag'),
    SortFieldDefinition(field: 'litter_strain', label: 'Strain'),
    SortFieldDefinition(field: 'set_up_date', label: 'Set Up Date'),
    SortFieldDefinition(field: 'disbanded_date', label: 'Disbanded Date'),
    SortFieldDefinition(field: 'owner', label: 'Owner'),
    SortFieldDefinition(field: 'disbanded_by', label: 'Disbanded By'),
  ];

  /// Default sort configuration
  static const SortParam defaultSort = SortParam(
    field: 'created_date',
    order: SortOrder.desc,
  );
}

