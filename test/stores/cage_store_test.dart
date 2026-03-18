import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/stores/cage_store.dart';

import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  setUp(() {
    cageStore.value = null;
  });

  tearDown(() {
    cageStore.value = null;
  });

  group('useCageStore', () {
    test('returns existing list when store is populated', () async {
      final cages = [
        CageStoreDto(cageId: 1, cageUuid: 'uuid-1', cageTag: 'C001'),
      ];
      cageStore.value = cages;

      final result = await useCageStore();
      expect(result.length, 1);
      expect(result.first.cageUuid, 'uuid-1');
    });

    // Note: testing with null store is not feasible because useCageStore
    // triggers a fire-and-forget API call that produces unhandled errors.
  });

  group('getCagesHook', () {
    test('returns all cages when store is populated', () async {
      cageStore.value = [
        CageStoreDto(cageId: 1, cageUuid: 'uuid-1', cageTag: 'C001'),
        CageStoreDto(cageId: 2, cageUuid: 'uuid-2', cageTag: 'C002'),
      ];

      final result = await getCagesHook();
      expect(result.length, 2);
    });

    test('returns empty list when store is empty', () async {
      cageStore.value = [];
      final result = await getCagesHook();
      expect(result, isEmpty);
    });
  });

  group('getCageHook', () {
    test('returns null for null uuid', () async {
      cageStore.value = [
        CageStoreDto(cageId: 1, cageUuid: 'uuid-1', cageTag: 'C001'),
      ];

      final result = await getCageHook(null);
      expect(result, isNull);
    });

    test('returns null for empty uuid', () async {
      cageStore.value = [
        CageStoreDto(cageId: 1, cageUuid: 'uuid-1', cageTag: 'C001'),
      ];

      final result = await getCageHook('');
      expect(result, isNull);
    });

    test('returns matching cage when uuid exists', () async {
      cageStore.value = [
        CageStoreDto(cageId: 1, cageUuid: 'uuid-1', cageTag: 'C001'),
        CageStoreDto(cageId: 2, cageUuid: 'uuid-2', cageTag: 'C002'),
      ];

      final result = await getCageHook('uuid-2');
      expect(result, isNotNull);
      expect(result!.cageUuid, 'uuid-2');
      expect(result.cageTag, 'C002');
    });

    test('returns null when uuid does not match any cage', () async {
      cageStore.value = [
        CageStoreDto(cageId: 1, cageUuid: 'uuid-1', cageTag: 'C001'),
      ];

      final result = await getCageHook('non-existent');
      expect(result, isNull);
    });

    test('returns null when store has empty list', () async {
      cageStore.value = [];

      final result = await getCageHook('uuid-1');
      expect(result, isNull);
    });
  });

  group('cageStore value', () {
    test('can be set and read', () {
      final cages = [
        CageStoreDto(cageId: 1, cageUuid: 'uuid-1', cageTag: 'C001'),
      ];
      cageStore.value = cages;

      expect(cageStore.value, isNotNull);
      expect(cageStore.value!.length, 1);
      expect(cageStore.value!.first.cageTag, 'C001');
    });

    test('defaults to null', () {
      expect(cageStore.value, isNull);
    });
  });
}
