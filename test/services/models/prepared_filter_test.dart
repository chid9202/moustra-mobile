import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/models/list_query_params.dart';
import 'package:moustra/services/models/prepared_filter.dart';

void main() {
  group('PreparedFilter', () {
    group('findMatchingPreset', () {
      final presets = [
        const PreparedFilter(
          name: 'Active Animals',
          filters: [
            FilterParam(field: 'status', operator: 'is', value: 'active'),
          ],
          sort: SortParam(field: 'name', order: SortOrder.asc),
        ),
        const PreparedFilter(
          name: 'No Outcome',
          filters: [
            FilterParam(field: 'outcome', operator: 'is_empty', value: ''),
          ],
        ),
        const PreparedFilter(
          name: 'Multi Filter',
          filters: [
            FilterParam(field: 'status', operator: 'is', value: 'active'),
            FilterParam(field: 'name', operator: 'contains', value: 'test'),
          ],
        ),
      ];

      test('returns index when filters and sort match exactly', () {
        const filters = [
          FilterParam(field: 'status', operator: 'is', value: 'active'),
        ];
        const sort = SortParam(field: 'name', order: SortOrder.asc);
        expect(PreparedFilter.findMatchingPreset(presets, filters, sort), 0);
      });

      test('returns -1 when no match', () {
        const filters = [
          FilterParam(field: 'other', operator: 'is', value: 'x'),
        ];
        expect(
            PreparedFilter.findMatchingPreset(presets, filters, null), -1);
      });

      test('returns -1 when filters match but sort differs', () {
        const filters = [
          FilterParam(field: 'status', operator: 'is', value: 'active'),
        ];
        const sort = SortParam(field: 'name', order: SortOrder.desc);
        expect(PreparedFilter.findMatchingPreset(presets, filters, sort), -1);
      });

      test('returns -1 when sort matches but filters differ', () {
        const filters = [
          FilterParam(field: 'name', operator: 'is', value: 'active'),
        ];
        const sort = SortParam(field: 'name', order: SortOrder.asc);
        expect(PreparedFilter.findMatchingPreset(presets, filters, sort), -1);
      });

      test('returns -1 when filter count differs', () {
        const filters = [
          FilterParam(field: 'status', operator: 'is', value: 'active'),
          FilterParam(field: 'extra', operator: 'is', value: 'yes'),
        ];
        const sort = SortParam(field: 'name', order: SortOrder.asc);
        expect(PreparedFilter.findMatchingPreset(presets, filters, sort), -1);
      });

      test('matches empty filters and null sort', () {
        final presetsWithEmpty = [
          const PreparedFilter(name: 'Empty', filters: [], sort: null),
        ];
        expect(
          PreparedFilter.findMatchingPreset(presetsWithEmpty, [], null),
          0,
        );
      });

      test('matches preset with multiple filters in same order', () {
        const filters = [
          FilterParam(field: 'status', operator: 'is', value: 'active'),
          FilterParam(field: 'name', operator: 'contains', value: 'test'),
        ];
        expect(
            PreparedFilter.findMatchingPreset(presets, filters, null), 2);
      });

      test(
          'ignores value for operators that do not require value (is_empty)',
          () {
        // Preset has value='', applied has value='true' - should still match
        const filters = [
          FilterParam(
              field: 'outcome', operator: 'is_empty', value: 'true'),
        ];
        expect(
            PreparedFilter.findMatchingPreset(presets, filters, null), 1);
      });

      test(
          'ignores value for operators that do not require value (is_not_empty)',
          () {
        final presetsWithNotEmpty = [
          const PreparedFilter(
            name: 'Has Outcome',
            filters: [
              FilterParam(
                  field: 'outcome', operator: 'is_not_empty', value: ''),
            ],
          ),
        ];
        const filters = [
          FilterParam(
              field: 'outcome', operator: 'is_not_empty', value: 'true'),
        ];
        expect(
          PreparedFilter.findMatchingPreset(presetsWithNotEmpty, filters, null),
          0,
        );
      });

      test(
          'KNOWN BUG: same filters in different order does not match',
          () {
        // This verifies the known bug where _filtersMatch compares by index,
        // so same filters in different order won't match.
        const filtersReversed = [
          FilterParam(field: 'name', operator: 'contains', value: 'test'),
          FilterParam(field: 'status', operator: 'is', value: 'active'),
        ];
        // Preset index 2 has [status/is/active, name/contains/test] in that order
        // But filtersReversed has them reversed
        final result =
            PreparedFilter.findMatchingPreset(presets, filtersReversed, null);
        // The bug: it should match (index 2) but doesn't because comparison is positional
        expect(result, -1,
            reason:
                '_filtersMatch compares by index, so reordered filters fail to match');
      });
    });

    group('_filtersMatch edge cases', () {
      test('both empty lists match', () {
        final presets = [
          const PreparedFilter(name: 'Empty', filters: []),
        ];
        expect(
            PreparedFilter.findMatchingPreset(presets, [], null), 0);
      });

      test('value-requiring operators must have matching values', () {
        final presets = [
          const PreparedFilter(
            name: 'Test',
            filters: [
              FilterParam(field: 'name', operator: 'contains', value: 'abc'),
            ],
          ),
        ];
        const filters = [
          FilterParam(field: 'name', operator: 'contains', value: 'xyz'),
        ];
        expect(
            PreparedFilter.findMatchingPreset(presets, filters, null), -1);
      });

      test('field mismatch returns no match', () {
        final presets = [
          const PreparedFilter(
            name: 'Test',
            filters: [
              FilterParam(field: 'name', operator: 'contains', value: 'abc'),
            ],
          ),
        ];
        const filters = [
          FilterParam(field: 'other', operator: 'contains', value: 'abc'),
        ];
        expect(
            PreparedFilter.findMatchingPreset(presets, filters, null), -1);
      });

      test('operator mismatch returns no match', () {
        final presets = [
          const PreparedFilter(
            name: 'Test',
            filters: [
              FilterParam(field: 'name', operator: 'contains', value: 'abc'),
            ],
          ),
        ];
        const filters = [
          FilterParam(field: 'name', operator: 'equals', value: 'abc'),
        ];
        expect(
            PreparedFilter.findMatchingPreset(presets, filters, null), -1);
      });
    });

    group('PreparedFilter construction', () {
      test('can be constructed with required name', () {
        const pf = PreparedFilter(name: 'Test');
        expect(pf.name, 'Test');
        expect(pf.filters, isEmpty);
        expect(pf.sort, isNull);
      });

      test('can be constructed with all fields', () {
        const pf = PreparedFilter(
          name: 'Full',
          filters: [
            FilterParam(field: 'f', operator: 'op', value: 'v'),
          ],
          sort: SortParam(field: 's', order: SortOrder.asc),
        );
        expect(pf.name, 'Full');
        expect(pf.filters.length, 1);
        expect(pf.sort, isNotNull);
      });
    });
  });
}
