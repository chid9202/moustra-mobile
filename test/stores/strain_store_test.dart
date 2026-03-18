import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/stores/strain_store.dart';

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
    strainStore.value = null;
  });

  tearDown(() {
    strainStore.value = null;
  });

  group('useStrainStore', () {
    test('returns existing list when store is populated', () async {
      final strains = [
        StrainStoreDto(
          strainId: 1,
          strainUuid: 'uuid-1',
          strainName: 'C57BL/6',
          genotypes: [],
        ),
      ];
      strainStore.value = strains;

      final result = await useStrainStore();
      expect(result.length, 1);
      expect(result.first.strainUuid, 'uuid-1');
    });

    // Note: testing with null store is not feasible because useStrainStore
    // triggers a fire-and-forget API call that produces unhandled errors.
  });

  group('getStrainsHook', () {
    test('returns all strains when store is populated', () async {
      strainStore.value = [
        StrainStoreDto(
          strainId: 1,
          strainUuid: 'uuid-1',
          strainName: 'C57BL/6',
          genotypes: [],
        ),
        StrainStoreDto(
          strainId: 2,
          strainUuid: 'uuid-2',
          strainName: 'BALB/c',
          genotypes: [],
        ),
      ];

      final result = await getStrainsHook();
      expect(result.length, 2);
    });

    test('returns empty list when store is empty', () async {
      strainStore.value = [];
      final result = await getStrainsHook();
      expect(result, isEmpty);
    });
  });

  group('getStrainHook', () {
    test('returns null for null uuid', () async {
      strainStore.value = [
        StrainStoreDto(
          strainId: 1,
          strainUuid: 'uuid-1',
          strainName: 'C57BL/6',
          genotypes: [],
        ),
      ];

      final result = await getStrainHook(null);
      expect(result, isNull);
    });

    test('returns null for empty uuid', () async {
      strainStore.value = [
        StrainStoreDto(
          strainId: 1,
          strainUuid: 'uuid-1',
          strainName: 'C57BL/6',
          genotypes: [],
        ),
      ];

      final result = await getStrainHook('');
      expect(result, isNull);
    });

    test('returns matching strain when uuid exists', () async {
      strainStore.value = [
        StrainStoreDto(
          strainId: 1,
          strainUuid: 'uuid-1',
          strainName: 'C57BL/6',
          genotypes: [],
        ),
        StrainStoreDto(
          strainId: 2,
          strainUuid: 'uuid-2',
          strainName: 'BALB/c',
          genotypes: [],
        ),
      ];

      final result = await getStrainHook('uuid-2');
      expect(result, isNotNull);
      expect(result!.strainUuid, 'uuid-2');
      expect(result.strainName, 'BALB/c');
    });

    test('returns null when uuid does not match any strain', () async {
      strainStore.value = [
        StrainStoreDto(
          strainId: 1,
          strainUuid: 'uuid-1',
          strainName: 'C57BL/6',
          genotypes: [],
        ),
      ];

      final result = await getStrainHook('non-existent');
      expect(result, isNull);
    });

    test('returns null when store has empty list', () async {
      strainStore.value = [];

      final result = await getStrainHook('uuid-1');
      expect(result, isNull);
    });
  });

  group('strainStore value', () {
    test('can be set and read', () {
      final strains = [
        StrainStoreDto(
          strainId: 1,
          strainUuid: 'uuid-1',
          strainName: 'C57BL/6',
          genotypes: [],
        ),
      ];
      strainStore.value = strains;

      expect(strainStore.value, isNotNull);
      expect(strainStore.value!.length, 1);
      expect(strainStore.value!.first.strainName, 'C57BL/6');
    });

    test('defaults to null', () {
      expect(strainStore.value, isNull);
    });
  });
}
