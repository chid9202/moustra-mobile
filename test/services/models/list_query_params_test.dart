import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/models/list_query_params.dart';

void main() {
  group('FilterParam', () {
    test('equality with same values', () {
      const a = FilterParam(field: 'name', operator: 'contains', value: 'test');
      const b = FilterParam(field: 'name', operator: 'contains', value: 'test');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality with different field', () {
      const a = FilterParam(field: 'name', operator: 'contains', value: 'test');
      const b =
          FilterParam(field: 'status', operator: 'contains', value: 'test');
      expect(a, isNot(equals(b)));
    });

    test('inequality with different operator', () {
      const a = FilterParam(field: 'name', operator: 'contains', value: 'test');
      const b = FilterParam(field: 'name', operator: 'equals', value: 'test');
      expect(a, isNot(equals(b)));
    });

    test('inequality with different value', () {
      const a = FilterParam(field: 'name', operator: 'contains', value: 'abc');
      const b = FilterParam(field: 'name', operator: 'contains', value: 'xyz');
      expect(a, isNot(equals(b)));
    });

    test('equality with null values', () {
      const a = FilterParam(field: 'name', operator: 'is_empty');
      const b = FilterParam(field: 'name', operator: 'is_empty');
      expect(a, equals(b));
    });

    test('copyWith replaces field', () {
      const original =
          FilterParam(field: 'name', operator: 'contains', value: 'test');
      final copied = original.copyWith(field: 'status');
      expect(copied.field, 'status');
      expect(copied.operator, 'contains');
      expect(copied.value, 'test');
    });

    test('copyWith replaces operator', () {
      const original =
          FilterParam(field: 'name', operator: 'contains', value: 'test');
      final copied = original.copyWith(operator: 'equals');
      expect(copied.field, 'name');
      expect(copied.operator, 'equals');
    });

    test('copyWith replaces value', () {
      const original =
          FilterParam(field: 'name', operator: 'contains', value: 'old');
      final copied = original.copyWith(value: 'new');
      expect(copied.value, 'new');
    });

    test('copyWith with no arguments returns equivalent object', () {
      const original =
          FilterParam(field: 'name', operator: 'contains', value: 'test');
      final copied = original.copyWith();
      expect(copied, equals(original));
    });

    test('toString includes field, operator, and value', () {
      const param =
          FilterParam(field: 'name', operator: 'contains', value: 'test');
      final str = param.toString();
      expect(str, contains('name'));
      expect(str, contains('contains'));
      expect(str, contains('test'));
    });
  });

  group('SortParam', () {
    test('equality with same values', () {
      const a = SortParam(field: 'name', order: SortOrder.asc);
      const b = SortParam(field: 'name', order: SortOrder.asc);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality with different field', () {
      const a = SortParam(field: 'name', order: SortOrder.asc);
      const b = SortParam(field: 'date', order: SortOrder.asc);
      expect(a, isNot(equals(b)));
    });

    test('inequality with different order', () {
      const a = SortParam(field: 'name', order: SortOrder.asc);
      const b = SortParam(field: 'name', order: SortOrder.desc);
      expect(a, isNot(equals(b)));
    });

    test('default order is desc', () {
      const param = SortParam(field: 'name');
      expect(param.order, SortOrder.desc);
    });

    test('copyWith replaces field', () {
      const original = SortParam(field: 'name', order: SortOrder.asc);
      final copied = original.copyWith(field: 'date');
      expect(copied.field, 'date');
      expect(copied.order, SortOrder.asc);
    });

    test('copyWith replaces order', () {
      const original = SortParam(field: 'name', order: SortOrder.asc);
      final copied = original.copyWith(order: SortOrder.desc);
      expect(copied.order, SortOrder.desc);
    });

    test('toString includes field and order', () {
      const param = SortParam(field: 'name', order: SortOrder.asc);
      expect(param.toString(), contains('name'));
      expect(param.toString(), contains('asc'));
    });
  });

  group('ListQueryParams', () {
    test('default values', () {
      const params = ListQueryParams();
      expect(params.page, 1);
      expect(params.pageSize, 25);
      expect(params.filters, isEmpty);
      expect(params.sorts, isEmpty);
      expect(params.name, isNull);
    });

    test('hasFilters returns false when empty', () {
      const params = ListQueryParams();
      expect(params.hasFilters, false);
    });

    test('hasFilters returns true when filters present', () {
      const params = ListQueryParams(filters: [
        FilterParam(field: 'name', operator: 'contains', value: 'test'),
      ]);
      expect(params.hasFilters, true);
    });

    test('hasSorts returns false when empty', () {
      const params = ListQueryParams();
      expect(params.hasSorts, false);
    });

    test('hasSorts returns true when sorts present', () {
      const params = ListQueryParams(sorts: [
        SortParam(field: 'name'),
      ]);
      expect(params.hasSorts, true);
    });

    group('copyWith', () {
      test('replaces page', () {
        const original = ListQueryParams(page: 1);
        final copied = original.copyWith(page: 3);
        expect(copied.page, 3);
        expect(copied.pageSize, 25);
      });

      test('replaces pageSize', () {
        const original = ListQueryParams();
        final copied = original.copyWith(pageSize: 50);
        expect(copied.pageSize, 50);
      });

      test('replaces filters', () {
        const original = ListQueryParams();
        final copied = original.copyWith(filters: [
          const FilterParam(field: 'x', operator: 'eq', value: '1'),
        ]);
        expect(copied.filters.length, 1);
      });

      test('replaces sorts', () {
        const original = ListQueryParams();
        final copied = original.copyWith(sorts: [
          const SortParam(field: 'name'),
        ]);
        expect(copied.sorts.length, 1);
      });

      test('replaces name', () {
        const original = ListQueryParams();
        final copied = original.copyWith(name: 'active');
        expect(copied.name, 'active');
      });

      test('preserves all other fields when changing one', () {
        const original = ListQueryParams(
          page: 2,
          pageSize: 10,
          filters: [FilterParam(field: 'f', operator: 'op')],
          sorts: [SortParam(field: 's')],
          name: 'preset',
        );
        final copied = original.copyWith(page: 5);
        expect(copied.pageSize, 10);
        expect(copied.filters.length, 1);
        expect(copied.sorts.length, 1);
        expect(copied.name, 'preset');
      });
    });

    group('buildQueryString', () {
      test('builds basic pagination query', () {
        const params = ListQueryParams();
        expect(params.buildQueryString(), 'page=1&page_size=25');
      });

      test('builds with custom pagination', () {
        const params = ListQueryParams(page: 3, pageSize: 50);
        expect(params.buildQueryString(), 'page=3&page_size=50');
      });

      test('includes name parameter', () {
        const params = ListQueryParams(name: 'active');
        final qs = params.buildQueryString();
        expect(qs, contains('name=active'));
      });

      test('URL encodes name parameter', () {
        const params = ListQueryParams(name: 'my filter');
        final qs = params.buildQueryString();
        expect(qs, contains('name=my%20filter'));
      });

      test('omits name when null', () {
        const params = ListQueryParams(name: null);
        final qs = params.buildQueryString();
        expect(qs, isNot(contains('name=')));
      });

      test('omits name when empty', () {
        const params = ListQueryParams(name: '');
        final qs = params.buildQueryString();
        expect(qs, isNot(contains('name=')));
      });

      test('includes single filter triplet', () {
        const params = ListQueryParams(filters: [
          FilterParam(field: 'outcome', operator: 'is_empty', value: ''),
        ]);
        final qs = params.buildQueryString();
        expect(qs, contains('filter=outcome'));
        expect(qs, contains('op=is_empty'));
        expect(qs, contains('value='));
      });

      test('includes multiple filter triplets', () {
        const params = ListQueryParams(filters: [
          FilterParam(field: 'name', operator: 'contains', value: 'test'),
          FilterParam(field: 'status', operator: 'is', value: 'active'),
        ]);
        final qs = params.buildQueryString();
        expect(qs, contains('filter=name'));
        expect(qs, contains('op=contains'));
        expect(qs, contains('value=test'));
        expect(qs, contains('filter=status'));
        expect(qs, contains('op=is'));
        expect(qs, contains('value=active'));
      });

      test('omits value when filter value is null', () {
        const params = ListQueryParams(filters: [
          FilterParam(field: 'name', operator: 'is_empty'),
        ]);
        final qs = params.buildQueryString();
        expect(qs, contains('filter=name'));
        expect(qs, contains('op=is_empty'));
        // Should not contain 'value=' for this filter
        expect(qs, isNot(contains('value=')));
      });

      test('URL encodes filter field and value', () {
        const params = ListQueryParams(filters: [
          FilterParam(
              field: 'full name', operator: 'contains', value: 'hello world'),
        ]);
        final qs = params.buildQueryString();
        expect(qs, contains('filter=full%20name'));
        expect(qs, contains('value=hello%20world'));
      });

      test('includes sort and order pair', () {
        const params = ListQueryParams(sorts: [
          SortParam(field: 'name', order: SortOrder.asc),
        ]);
        final qs = params.buildQueryString();
        expect(qs, contains('sort=name'));
        expect(qs, contains('order=asc'));
      });

      test('includes multiple sorts', () {
        const params = ListQueryParams(sorts: [
          SortParam(field: 'name', order: SortOrder.asc),
          SortParam(field: 'date', order: SortOrder.desc),
        ]);
        final qs = params.buildQueryString();
        expect(qs, contains('sort=name'));
        expect(qs, contains('order=asc'));
        expect(qs, contains('sort=date'));
        expect(qs, contains('order=desc'));
      });

      test('builds full query with filters, sorts, name, and pagination', () {
        const params = ListQueryParams(
          page: 2,
          pageSize: 10,
          name: 'preset1',
          filters: [
            FilterParam(field: 'status', operator: 'is', value: 'active'),
          ],
          sorts: [
            SortParam(field: 'created', order: SortOrder.desc),
          ],
        );
        final qs = params.buildQueryString();
        expect(qs, startsWith('page=2&page_size=10'));
        expect(qs, contains('name=preset1'));
        expect(qs, contains('filter=status'));
        expect(qs, contains('sort=created'));
        expect(qs, contains('order=desc'));
      });

      test('produces correct order: pagination, name, filters, sorts', () {
        const params = ListQueryParams(
          page: 1,
          pageSize: 25,
          name: 'test',
          filters: [
            FilterParam(field: 'f', operator: 'op', value: 'v'),
          ],
          sorts: [
            SortParam(field: 's', order: SortOrder.asc),
          ],
        );
        final qs = params.buildQueryString();
        final pageIdx = qs.indexOf('page=1');
        final nameIdx = qs.indexOf('name=test');
        final filterIdx = qs.indexOf('filter=f');
        final sortIdx = qs.indexOf('sort=s');
        expect(pageIdx, lessThan(nameIdx));
        expect(nameIdx, lessThan(filterIdx));
        expect(filterIdx, lessThan(sortIdx));
      });
    });

    test('toString includes key info', () {
      const params = ListQueryParams(page: 2, pageSize: 10);
      final str = params.toString();
      expect(str, contains('page: 2'));
      expect(str, contains('pageSize: 10'));
    });
  });

  group('FilterOperators', () {
    test('getLabel returns correct label for known operators', () {
      expect(FilterOperators.getLabel('contains'), 'Contains');
      expect(FilterOperators.getLabel('equals'), 'Equals');
      expect(FilterOperators.getLabel('starts_with'), 'Starts with');
      expect(FilterOperators.getLabel('ends_with'), 'Ends with');
      expect(FilterOperators.getLabel('is_empty'), 'Is empty');
      expect(FilterOperators.getLabel('is_not_empty'), 'Is not empty');
      expect(FilterOperators.getLabel('before'), 'Before');
      expect(FilterOperators.getLabel('after'), 'After');
      expect(FilterOperators.getLabel('on_or_before'), 'On or before');
      expect(FilterOperators.getLabel('on_or_after'), 'On or after');
      expect(FilterOperators.getLabel('is'), 'Is');
      expect(FilterOperators.getLabel('not'), 'Is not');
      expect(FilterOperators.getLabel('is_any_of'), 'Is any of');
    });

    test('getLabel returns operator string for unknown operator', () {
      expect(FilterOperators.getLabel('unknown_op'), 'unknown_op');
    });

    test('requiresValue returns false for is_empty', () {
      expect(FilterOperators.requiresValue('is_empty'), false);
    });

    test('requiresValue returns false for is_not_empty', () {
      expect(FilterOperators.requiresValue('is_not_empty'), false);
    });

    test('requiresValue returns true for other operators', () {
      expect(FilterOperators.requiresValue('contains'), true);
      expect(FilterOperators.requiresValue('equals'), true);
      expect(FilterOperators.requiresValue('is'), true);
      expect(FilterOperators.requiresValue('before'), true);
    });

    test('textOperators contains expected operators', () {
      expect(FilterOperators.textOperators, contains('contains'));
      expect(FilterOperators.textOperators, contains('equals'));
      expect(FilterOperators.textOperators, contains('starts_with'));
      expect(FilterOperators.textOperators, contains('ends_with'));
      expect(FilterOperators.textOperators, contains('is_empty'));
      expect(FilterOperators.textOperators, contains('is_not_empty'));
    });

    test('dateOperators contains expected operators', () {
      expect(FilterOperators.dateOperators, contains('is'));
      expect(FilterOperators.dateOperators, contains('before'));
      expect(FilterOperators.dateOperators, contains('after'));
    });

    test('booleanOperators contains is', () {
      expect(FilterOperators.booleanOperators, contains('is'));
      expect(FilterOperators.booleanOperators.length, 1);
    });

    test('selectOperators contains is and is_any_of', () {
      expect(FilterOperators.selectOperators, contains('is'));
      expect(FilterOperators.selectOperators, contains('is_any_of'));
    });
  });

  group('FilterFieldDefinition', () {
    test('can be constructed with required fields', () {
      const def = FilterFieldDefinition(
        field: 'name',
        label: 'Name',
        type: FilterFieldType.text,
        operators: ['contains', 'equals'],
      );
      expect(def.field, 'name');
      expect(def.label, 'Name');
      expect(def.type, FilterFieldType.text);
      expect(def.operators.length, 2);
      expect(def.selectOptions, isNull);
    });

    test('can include selectOptions', () {
      const def = FilterFieldDefinition(
        field: 'status',
        label: 'Status',
        type: FilterFieldType.select,
        operators: ['is'],
        selectOptions: [
          FilterSelectOption(value: 'active', label: 'Active'),
          FilterSelectOption(value: 'inactive', label: 'Inactive'),
        ],
      );
      expect(def.selectOptions, isNotNull);
      expect(def.selectOptions!.length, 2);
      expect(def.selectOptions![0].value, 'active');
      expect(def.selectOptions![0].label, 'Active');
    });
  });

  group('SortFieldDefinition', () {
    test('can be constructed', () {
      const def = SortFieldDefinition(field: 'name', label: 'Name');
      expect(def.field, 'name');
      expect(def.label, 'Name');
    });
  });
}
