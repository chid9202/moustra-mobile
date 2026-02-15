import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/cage_filter_config.dart';
import 'package:moustra/services/models/list_query_params.dart';

void main() {
  group('CageFilterConfig', () {
    group('preparedFilters', () {
      test('should have 3 prepared filter presets', () {
        expect(CageFilterConfig.preparedFilters.length, 3);
      });

      test('Default preset should have no filters', () {
        final preset = CageFilterConfig.preparedFilters[0];
        expect(preset.name, 'Default');
        expect(preset.filters, isEmpty);
        expect(preset.sort, isNotNull);
        expect(preset.sort!.field, 'created_date');
        expect(preset.sort!.order, SortOrder.desc);
      });

      test('My Cages preset should filter by end_date is_empty and owner equals CURRENT_USER', () {
        final preset = CageFilterConfig.preparedFilters[1];
        expect(preset.name, 'My Cages');
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

      test('Ended Cages preset should filter by end_date is_not_empty', () {
        final preset = CageFilterConfig.preparedFilters[2];
        expect(preset.name, 'Ended Cages');
        expect(preset.filters.length, 1);

        final endDateFilter = preset.filters[0];
        expect(endDateFilter.field, 'end_date');
        expect(endDateFilter.operator, FilterOperators.isNotEmpty);
        expect(endDateFilter.value, 'true');
      });

      test('all presets should sort by created_date desc', () {
        for (final preset in CageFilterConfig.preparedFilters) {
          expect(preset.sort, isNotNull, reason: '${preset.name} should have a sort');
          expect(preset.sort!.field, 'created_date');
          expect(preset.sort!.order, SortOrder.desc);
        }
      });
    });

    group('filterFields', () {
      test('should contain expected filter fields', () {
        final fieldNames = CageFilterConfig.filterFields.map((f) => f.field).toList();
        expect(fieldNames, contains('cage_tag'));
        expect(fieldNames, contains('strain'));
        expect(fieldNames, contains('status'));
        expect(fieldNames, contains('end_date'));
        expect(fieldNames, contains('created_date'));
      });
    });

    group('sortFields', () {
      test('should contain expected sort fields', () {
        final fieldNames = CageFilterConfig.sortFields.map((f) => f.field).toList();
        expect(fieldNames, contains('created_date'));
        expect(fieldNames, contains('cage_tag'));
        expect(fieldNames, contains('strain'));
        expect(fieldNames, contains('status'));
      });
    });

    group('defaultSort', () {
      test('should sort by created_date descending', () {
        expect(CageFilterConfig.defaultSort.field, 'created_date');
        expect(CageFilterConfig.defaultSort.order, SortOrder.desc);
      });
    });
  });
}
