import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/animal_filter_config.dart';
import 'package:moustra/constants/list_constants/cage_filter_config.dart';
import 'package:moustra/services/models/list_query_params.dart';

void main() {
  group('AnimalFilterConfig', () {
    group('preparedFilters', () {
      test('should have 3 prepared filter presets', () {
        expect(AnimalFilterConfig.preparedFilters.length, 3);
      });

      test('Default preset should filter by end_date is_empty', () {
        final preset = AnimalFilterConfig.preparedFilters[0];
        expect(preset.name, 'Default');
        expect(preset.filters.length, 1);

        final endDateFilter = preset.filters[0];
        expect(endDateFilter.field, 'end_date');
        expect(endDateFilter.operator, FilterOperators.isEmpty);
        expect(endDateFilter.value, '');
      });

      test('My Animals preset should filter by end_date is_empty and owner equals CURRENT_USER', () {
        final preset = AnimalFilterConfig.preparedFilters[1];
        expect(preset.name, 'My Animals');
        expect(preset.filters.length, 2);

        final endDateFilter = preset.filters[0];
        expect(endDateFilter.field, 'end_date');
        expect(endDateFilter.operator, FilterOperators.isEmpty);
        expect(endDateFilter.value, '');

        final ownerFilter = preset.filters[1];
        expect(ownerFilter.field, 'owner');
        expect(ownerFilter.operator, FilterOperators.equals);
        expect(ownerFilter.value, currentUserPlaceholder);
      });

      test('Ended Animals preset should filter by end_date is_not_empty', () {
        final preset = AnimalFilterConfig.preparedFilters[2];
        expect(preset.name, 'Ended Animals');
        expect(preset.filters.length, 1);

        final endDateFilter = preset.filters[0];
        expect(endDateFilter.field, 'end_date');
        expect(endDateFilter.operator, FilterOperators.isNotEmpty);
        expect(endDateFilter.value, 'true');
      });

      test('all presets should sort by created_date desc', () {
        for (final preset in AnimalFilterConfig.preparedFilters) {
          expect(preset.sort, isNotNull, reason: '${preset.name} should have a sort');
          expect(preset.sort!.field, 'created_date');
          expect(preset.sort!.order, SortOrder.desc);
        }
      });
    });

    group('filterFields', () {
      test('should contain expected filter fields', () {
        final fieldNames = AnimalFilterConfig.filterFields.map((f) => f.field).toList();
        expect(fieldNames, contains('physical_tag'));
        expect(fieldNames, contains('strain'));
        expect(fieldNames, contains('sex'));
        expect(fieldNames, contains('status'));
        expect(fieldNames, contains('date_of_birth'));
        expect(fieldNames, contains('wean_date'));
        expect(fieldNames, contains('end_date'));
        expect(fieldNames, contains('created_date'));
        expect(fieldNames, contains('cage_tag'));
        expect(fieldNames, contains('genotypes'));
      });

      test('all filter fields have non-empty labels', () {
        for (final field in AnimalFilterConfig.filterFields) {
          expect(field.label, isNotEmpty, reason: '${field.field} should have a label');
        }
      });

      test('all filter fields have non-empty operators', () {
        for (final field in AnimalFilterConfig.filterFields) {
          expect(field.operators, isNotEmpty, reason: '${field.field} should have operators');
        }
      });

      test('text fields use text operators', () {
        final textFields = AnimalFilterConfig.filterFields
            .where((f) => f.type == FilterFieldType.text);
        for (final field in textFields) {
          expect(field.operators, FilterOperators.textOperators,
              reason: '${field.field} should use text operators');
        }
      });

      test('date fields use date operators', () {
        final dateFields = AnimalFilterConfig.filterFields
            .where((f) => f.type == FilterFieldType.date);
        for (final field in dateFields) {
          expect(field.operators, FilterOperators.dateOperators,
              reason: '${field.field} should use date operators');
        }
      });

      test('select fields use select operators', () {
        final selectFields = AnimalFilterConfig.filterFields
            .where((f) => f.type == FilterFieldType.select);
        for (final field in selectFields) {
          expect(field.operators, FilterOperators.selectOperators,
              reason: '${field.field} should use select operators');
        }
      });

      test('sex field has M, F, U select options', () {
        final sexField = AnimalFilterConfig.filterFields
            .firstWhere((f) => f.field == 'sex');
        expect(sexField.selectOptions, isNotNull);
        expect(sexField.selectOptions!.length, 3);
        final values = sexField.selectOptions!.map((o) => o.value).toList();
        expect(values, contains('M'));
        expect(values, contains('F'));
        expect(values, contains('U'));
      });

      test('status field has active and ended select options', () {
        final statusField = AnimalFilterConfig.filterFields
            .firstWhere((f) => f.field == 'status');
        expect(statusField.selectOptions, isNotNull);
        expect(statusField.selectOptions!.length, 2);
        final values = statusField.selectOptions!.map((o) => o.value).toList();
        expect(values, contains('active'));
        expect(values, contains('ended'));
      });
    });

    group('sortFields', () {
      test('should contain expected sort fields', () {
        final fieldNames = AnimalFilterConfig.sortFields.map((f) => f.field).toList();
        expect(fieldNames, contains('created_date'));
        expect(fieldNames, contains('physical_tag'));
        expect(fieldNames, contains('strain'));
        expect(fieldNames, contains('sex'));
        expect(fieldNames, contains('date_of_birth'));
        expect(fieldNames, contains('wean_date'));
        expect(fieldNames, contains('cage_tag'));
        expect(fieldNames, contains('owner'));
        expect(fieldNames, contains('end_date'));
        expect(fieldNames, contains('status'));
      });

      test('all sort fields have non-empty labels', () {
        for (final field in AnimalFilterConfig.sortFields) {
          expect(field.label, isNotEmpty, reason: '${field.field} should have a label');
        }
      });
    });

    group('defaultSort', () {
      test('should sort by created_date descending', () {
        expect(AnimalFilterConfig.defaultSort.field, 'created_date');
        expect(AnimalFilterConfig.defaultSort.order, SortOrder.desc);
      });
    });

    group('getFilterField', () {
      test('returns correct field definition for existing field', () {
        final field = AnimalFilterConfig.getFilterField('physical_tag');
        expect(field, isNotNull);
        expect(field!.field, 'physical_tag');
        expect(field.label, 'Physical Tag');
      });

      test('returns null for non-existent field', () {
        final field = AnimalFilterConfig.getFilterField('non_existent');
        expect(field, isNull);
      });
    });

    group('getSortField', () {
      test('returns correct field definition for existing field', () {
        final field = AnimalFilterConfig.getSortField('created_date');
        expect(field, isNotNull);
        expect(field!.field, 'created_date');
        expect(field.label, 'Created Date');
      });

      test('returns null for non-existent field', () {
        final field = AnimalFilterConfig.getSortField('non_existent');
        expect(field, isNull);
      });
    });
  });
}
