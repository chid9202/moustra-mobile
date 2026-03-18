import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';
import 'package:moustra/stores/allele_store.dart';

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
    alleleStore.value = null;
  });

  tearDown(() {
    alleleStore.value = null;
  });

  group('useAlleleStore', () {
    test('returns existing list when store is populated', () async {
      final alleles = [
        AlleleStoreDto(
          alleleId: 1,
          alleleUuid: 'uuid-1',
          alleleName: 'WT',
          isActive: true,
        ),
      ];
      alleleStore.value = alleles;

      final result = await useAlleleStore();
      expect(result.length, 1);
      expect(result.first.alleleUuid, 'uuid-1');
    });
  });

  group('getAllelesHook', () {
    test('returns all alleles when store is populated', () async {
      alleleStore.value = [
        AlleleStoreDto(
          alleleId: 1,
          alleleUuid: 'uuid-1',
          alleleName: 'WT',
          isActive: true,
        ),
        AlleleStoreDto(
          alleleId: 2,
          alleleUuid: 'uuid-2',
          alleleName: 'KO',
          isActive: true,
        ),
      ];

      final result = await getAllelesHook();
      expect(result.length, 2);
    });

    test('returns empty list when store is empty', () async {
      alleleStore.value = [];
      final result = await getAllelesHook();
      expect(result, isEmpty);
    });
  });

  group('getAlleleHook', () {
    test('returns null for null uuid', () async {
      alleleStore.value = [
        AlleleStoreDto(
          alleleId: 1,
          alleleUuid: 'uuid-1',
          alleleName: 'WT',
          isActive: true,
        ),
      ];

      final result = await getAlleleHook(null);
      expect(result, isNull);
    });

    test('returns null for empty uuid', () async {
      alleleStore.value = [
        AlleleStoreDto(
          alleleId: 1,
          alleleUuid: 'uuid-1',
          alleleName: 'WT',
          isActive: true,
        ),
      ];

      final result = await getAlleleHook('');
      expect(result, isNull);
    });

    test('returns matching allele when uuid exists', () async {
      alleleStore.value = [
        AlleleStoreDto(
          alleleId: 1,
          alleleUuid: 'uuid-1',
          alleleName: 'WT',
          isActive: true,
        ),
        AlleleStoreDto(
          alleleId: 2,
          alleleUuid: 'uuid-2',
          alleleName: 'KO',
          isActive: true,
        ),
      ];

      final result = await getAlleleHook('uuid-2');
      expect(result, isNotNull);
      expect(result!.alleleUuid, 'uuid-2');
      expect(result.alleleName, 'KO');
    });
  });

  group('alleleStore value', () {
    test('can be set and read', () {
      final alleles = [
        AlleleStoreDto(
          alleleId: 1,
          alleleUuid: 'uuid-1',
          alleleName: 'WT',
          isActive: true,
        ),
      ];
      alleleStore.value = alleles;

      expect(alleleStore.value, isNotNull);
      expect(alleleStore.value!.length, 1);
      expect(alleleStore.value!.first.alleleName, 'WT');
    });

    test('defaults to null', () {
      expect(alleleStore.value, isNull);
    });
  });
}
